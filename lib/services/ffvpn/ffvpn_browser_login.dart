import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:path/path.dart' as p;

import '../app_data_service.dart';
import 'ffvpn_service.dart';

class FfvpnBrowserSession {
  const FfvpnBrowserSession(this.token, this.email);

  final String token;
  final String email;
}

class FfvpnBrowserLogin {
  FfvpnBrowserLogin({
    Future<Webview> Function(String title)? createWindow,
    Future<void> Function(String token)? verifyToken,
    Future<Process> Function(String profile, Uri url)? startFirefox,
    Future<Directory> Function()? createFirefoxProfile,
    this.confirmRetry = const Duration(seconds: 4),
    this.confirmAttempts = 60,
    this.profilePollInterval = const Duration(milliseconds: 500),
  })  : _createWindow = createWindow ?? _openWindow,
        _verifyToken = verifyToken ?? _verify,
        _startFirefox = startFirefox ?? _launchFirefox,
        _createFirefoxProfile = createFirefoxProfile ??
            (() => Directory.systemTemp.createTemp('ffvpn-firefox-')),
        _useFirefox =
            startFirefox != null || (Platform.isLinux && createWindow == null);

  static const origin = 'https://accounts.firefox.com';
  final Future<Webview> Function(String title) _createWindow;
  final Future<void> Function(String token) _verifyToken;
  final Future<Process> Function(String profile, Uri url) _startFirefox;
  final Future<Directory> Function() _createFirefoxProfile;
  final bool _useFirefox;
  final Duration confirmRetry;
  final int confirmAttempts;
  final Duration profilePollInterval;
  Completer<FfvpnBrowserSession?>? _result;

  static Future<Webview> _openWindow(String title) async {
    if (!await WebviewWindow.isWebviewAvailable()) {
      throw const FfvpnException(
        FfvpnErrorKind.signInUnsupported,
        'Microsoft Edge WebView2 Runtime is required',
      );
    }
    return WebviewWindow.create(
      configuration: CreateConfiguration(
        title: title,
        windowWidth: 520,
        windowHeight: 760,
        windows: WindowsWebviewOptions(
          userDataFolder:
              p.join(await AppDataService.getDataDir(), 'ffvpn-browser'),
          denyCameraAndMicrophone: true,
        ),
      ),
    );
  }

  static Future<void> _verify(String token) async {
    await FfvpnService.fetchUsage(sessionToken: token);
  }

  static Future<Process> _launchFirefox(String profile, Uri url) async {
    await File(p.join(profile, 'user.js')).writeAsString([
      'user_pref("browser.startup.homepage_override.mstone", "ignore");',
      'user_pref("browser.aboutwelcome.enabled", false);',
      'user_pref("browser.shell.checkDefaultBrowser", false);',
      'user_pref("signon.rememberSignons", false);',
      // The temporary profile must not download the account's Sync data.
      for (final engine in [
        'addons',
        'addresses',
        'bookmarks',
        'creditcards',
        'history',
        'passwords',
        'prefs',
        'tabs',
      ])
        'user_pref("services.sync.engine.$engine", false);',
    ].join('\n'));
    final startPage = File(p.join(profile, 'sign-in.html'));
    // Keep the optional account email out of the process argument list.
    await startPage.writeAsString(
      '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" '
      'content="0;url=${const HtmlEscape().convert(url.toString())}">',
    );
    return Process.start('firefox', [
      '--no-remote',
      '--new-instance',
      '--profile',
      profile,
      '--new-window',
      startPage.uri.toString(),
    ]);
  }

  static FfvpnBrowserSession? readFirefoxSession(Object? data,
      {String email = ''}) {
    if (data is! Map) return null;
    return readSession({
      'message': {'command': 'fxaccounts:login', 'data': data['accountData']},
    }, origin, email: email);
  }

  Future<FfvpnBrowserSession?> _signInFirefox(
    String email,
    Completer<FfvpnBrowserSession?> result,
    void Function(FfvpnBrowserSession) onSession,
  ) async {
    Directory? profile;
    Process? browser;
    try {
      profile = await _createFirefoxProfile();
      if (result.isCompleted) return await result.future;
      try {
        browser = await _startFirefox(profile.path, loginUrl(email));
      } catch (error) {
        if (result.isCompleted) return await result.future;
        if (error is ProcessException) {
          throw const FfvpnException(
            FfvpnErrorKind.signInUnsupported,
            'Firefox is required for Mozilla browser sign-in on Linux',
          );
        }
        rethrow;
      }
      unawaited(browser.stdout.drain<void>());
      unawaited(browser.stderr.drain<void>());
      unawaited(browser.exitCode.then((code) {
        if (result.isCompleted) return;
        if (code == 0) {
          result.complete(null);
        } else {
          result.completeError(const FfvpnException(
            FfvpnErrorKind.other,
            'Firefox closed before sign-in completed',
          ));
        }
      }));
      final account = File(p.join(profile.path, 'signedInUser.json'));
      while (!result.isCompleted) {
        try {
          if (await account.exists()) {
            final session = readFirefoxSession(
                jsonDecode(await account.readAsString()),
                email: email);
            if (!result.isCompleted && session != null) onSession(session);
          }
        } on FileSystemException {
          // Firefox can replace its account file while it is being read.
        } on FormatException {
          // An account write may not have finished yet.
        }
        if (!result.isCompleted) {
          await Future.any([
            Future<void>.delayed(profilePollInterval),
            result.future.then((_) {}),
          ]);
        }
      }
      return await result.future;
    } finally {
      if (browser != null) {
        browser.kill();
        await browser.exitCode.timeout(const Duration(seconds: 5),
            onTimeout: () {
          browser!.kill(ProcessSignal.sigkill);
          return browser.exitCode;
        });
      }
      await profile?.delete(recursive: true);
    }
  }

  static Uri loginUrl(String email) => Uri.parse(origin).replace(
        path: '/',
        queryParameters: {
          'context': 'fx_desktop_v3',
          'service': 'sync',
          'action': 'email',
          if (email.trim().isNotEmpty) 'email': email.trim(),
        },
      );

  static FfvpnBrowserSession? readSession(Object? data, String sourceOrigin,
      {String email = ''}) {
    if (sourceOrigin != origin || data is! Map) return null;
    final message = data['message'];
    if (message is! Map ||
        !['fxaccounts:login', 'fxaccounts:oauth_login']
            .contains(message['command'])) {
      return null;
    }
    final session = message['data'];
    if (session is! Map) return null;
    final token = session['sessionToken'] ?? session['token'];
    if (token is! String || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(token)) {
      return null;
    }
    final account = session['email'];
    return FfvpnBrowserSession(
      token.toLowerCase(),
      account is String && account.isNotEmpty ? account : email.trim(),
    );
  }

  static bool looksUnconfirmed(String problem) =>
      RegExp(r'errno\s+(138|201)\b').hasMatch(problem) ||
      RegExp(r'unconfirmed|unverified|not verified', caseSensitive: false)
          .hasMatch(problem);

  void cancel() {
    final result = _result;
    if (result != null && !result.isCompleted) result.complete(null);
  }

  Future<FfvpnBrowserSession?> signIn({
    required String email,
    required String title,
    required void Function() onConfirming,
  }) async {
    if (_result != null) return null;
    final result = Completer<FfvpnBrowserSession?>();
    // Native callbacks can fail before browser setup has finished awaiting.
    unawaited(result.future
        .then<void>((_) {}, onError: (Object error, StackTrace stack) {}));
    _result = result;
    Webview? web;
    StreamSubscription<WebviewLoadError>? errors;
    var lastToken = '';

    Future<void> confirm(FfvpnBrowserSession session) async {
      onConfirming();
      try {
        for (var attempt = 0; attempt < confirmAttempts; attempt++) {
          if (result.isCompleted || lastToken != session.token) return;
          try {
            await _verifyToken(session.token);
            if (!result.isCompleted && lastToken == session.token) {
              result.complete(session);
            }
            return;
          } on FfvpnException catch (e) {
            if (!looksUnconfirmed(e.detail) || attempt == confirmAttempts - 1) {
              rethrow;
            }
          }
          await Future.any([
            Future<void>.delayed(confirmRetry),
            result.future.then((_) {}),
          ]);
        }
      } catch (e, stack) {
        if (!result.isCompleted && lastToken == session.token) {
          result.completeError(e, stack);
        }
      }
    }

    void onSession(FfvpnBrowserSession session) {
      if (!result.isCompleted && session.token != lastToken) {
        lastToken = session.token;
        unawaited(confirm(session));
      }
    }

    try {
      if (_useFirefox) {
        return await _signInFirefox(email, result, onSession);
      }
      web = await _createWindow(title);
      final browser = web;
      if (result.isCompleted) return null;
      unawaited(browser.onClose.then((_) {
        if (!result.isCompleted) result.complete(null);
      }));
      errors = browser.onLoadError.listen((error) {
        if (!result.isCompleted) {
          result.completeError(FfvpnException(
            FfvpnErrorKind.network,
            'Mozilla sign-in page could not load: ${error.kind.name}',
          ));
        }
      });
      browser.addJavaScriptHandler('fxa', (data, sourceOrigin) {
        if (result.isCompleted || sourceOrigin != origin || data is! Map) {
          return;
        }
        final message = data['message'];
        if (message is! Map) return;
        final command = message['command'];
        final id = data['id'];
        final messageId = message['messageId'];
        if (id is! String ||
            (messageId != null && messageId is! String && messageId is! num)) {
          return;
        }
        if (command == 'fxaccounts:fxa_status' ||
            command == 'fxaccounts:can_link_account') {
          unawaited(browser
              .postMessage(
                  'fxaReply',
                  {
                    'id': id,
                    'message': {
                      'messageId': messageId,
                      'command': command,
                      'data': command == 'fxaccounts:fxa_status'
                          ? {
                              'capabilities': <String, Object?>{},
                              'signedInUser': null
                            }
                          : {'ok': true},
                    },
                  },
                  targetOrigin: origin)
              .catchError((Object e, StackTrace stack) {
            if (!result.isCompleted) result.completeError(e, stack);
          }));
        }
        final session = readSession(data, sourceOrigin, email: email);
        if (session != null) onSession(session);
      });
      await browser.setOnUrlRequestCallback(
          (url) => Uri.tryParse(url)?.scheme == 'https');
      // Mozilla exposes its Sync WebChannel only to Firefox user agents.
      await browser.setApplicationNameForUserAgent(' Firefox/145.0');
      await browser.addScriptToExecuteOnDocumentCreated(hookJavaScript);
      await browser.launch(loginUrl(email).toString());
      return await result.future;
    } finally {
      cancel();
      await errors?.cancel();
      web?.removeJavaScriptHandler('fxa');
      try {
        await web?.close();
      } finally {
        _result = null;
      }
    }
  }

  static final hookJavaScript = '''
(function () {
  if (location.origin !== ${jsonEncode(origin)} || window !== window.top || window.__fxaHooked) return;
  window.__fxaHooked = true;
  var onChannel = function (e) {
    var d = e.detail;
    if (typeof d === 'string') { try { d = JSON.parse(d); } catch (_) { return; } }
    if (d && d.message) window.desktopWebview.postMessage('fxa', d);
  };
  window.addEventListener('WebChannelMessageToChrome', onChannel);
  document.addEventListener('WebChannelMessageToChrome', onChannel);
  window.desktopWebview.addEventListener('fxaReply', function (e) {
    if (location.origin !== ${jsonEncode(origin)}) return;
    window.dispatchEvent(new CustomEvent('WebChannelMessageToContent', { detail: e }));
    document.dispatchEvent(new CustomEvent('WebChannelMessageToContent', { detail: e }));
  });
})();
''';
}
