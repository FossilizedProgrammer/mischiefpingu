import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_browser_login.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_service.dart';

const token =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

Map<String, Object?> loginMessage({String sessionToken = token}) => {
      'id': 'account_updates',
      'message': {
        'command': 'fxaccounts:login',
        'data': {'sessionToken': sessionToken, 'email': 'user@example.com'},
      },
    };

class FakeWebview implements Webview {
  JavaScriptMessageHandler? handler;
  final closed = Completer<void>();
  final launched = Completer<void>();
  final loadErrors = StreamController<WebviewLoadError>.broadcast();
  final replies = <Object?>[];
  String? url;
  String? script;
  bool isClosed = false;
  Future<void> Function()? duringLaunch;

  @override
  Future<void> get onClose => closed.future;
  @override
  Stream<WebviewLoadError> get onLoadError => loadErrors.stream;
  @override
  void addJavaScriptHandler(String name, JavaScriptMessageHandler handler) {
    this.handler = handler;
  }

  @override
  void removeJavaScriptHandler(String name) => handler = null;
  @override
  Future<void> setOnUrlRequestCallback(OnUrlRequestCallback? callback) async {}
  @override
  Future<void> setApplicationNameForUserAgent(String name) async {}
  @override
  Future<void> addScriptToExecuteOnDocumentCreated(String script) async {
    this.script = script;
  }

  @override
  Future<void> launch(String url,
      {bool triggerOnUrlRequestEvent = true}) async {
    this.url = url;
    launched.complete();
    await duringLaunch?.call();
  }

  @override
  Future<void> postMessage(String name, Object? data,
      {String? targetOrigin}) async {
    expect(targetOrigin, FfvpnBrowserLogin.origin);
    replies.add(data);
  }

  @override
  Future<void> close() async {
    isClosed = true;
    if (!closed.isCompleted) closed.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirefoxProcess implements Process {
  final exited = Completer<int>();
  bool isKilled = false;

  @override
  Future<int> get exitCode => exited.future;
  @override
  Stream<List<int>> get stdout => const Stream.empty();
  @override
  Stream<List<int>> get stderr => const Stream.empty();
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    isKilled = true;
    if (!exited.isCompleted) exited.complete(0);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('reads only a valid Firefox account session from the private profile',
      () {
    expect(
        FfvpnBrowserLogin.readFirefoxSession({
          'version': 1,
          'accountData': {
            'sessionToken': token.toUpperCase(),
            'email': 'a@b.test'
          },
        })?.token,
        token);
    for (final data in [
      null,
      {'sessionToken': token},
      {'accountData': null},
      {
        'accountData': {'sessionToken': 'g' * 64}
      },
    ]) {
      expect(FfvpnBrowserLogin.readFirefoxSession(data), isNull);
    }
  });

  test('Firefox uses an isolated profile and returns only a confirmed session',
      () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final browser = FakeFirefoxProcess();
    final verifying = Completer<void>();
    final verified = Completer<void>();
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (path, url) async {
        expect(path, profile.path);
        expect(url.queryParameters['email'], 'user@example.com');
        await File('$path/signedInUser.json').writeAsString(jsonEncode({
          'accountData': {'sessionToken': token, 'email': 'user@example.com'},
        }));
        return browser;
      },
      verifyToken: (received) async {
        expect(received, token);
        verifying.complete();
        await verified.future;
      },
      profilePollInterval: Duration.zero,
    );
    final result = login.signIn(
        email: 'user@example.com', title: 'Mozilla', onConfirming: () {});
    await verifying.future;
    expect(browser.isKilled, false);
    verified.complete();
    expect((await result)?.token, token);
    expect(browser.isKilled, true);
    expect(await profile.exists(), false);
  });

  test('Firefox cancellation ignores late confirmation and removes the profile',
      () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final browser = FakeFirefoxProcess();
    final verifying = Completer<void>();
    final verified = Completer<void>();
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (path, _) async {
        await File('$path/signedInUser.json').writeAsString(jsonEncode({
          'accountData': {'sessionToken': token},
        }));
        return browser;
      },
      verifyToken: (_) async {
        verifying.complete();
        await verified.future;
      },
      profilePollInterval: Duration.zero,
    );
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await verifying.future;
    login.cancel();
    expect(await result, isNull);
    verified.complete();
    await Future<void>.delayed(Duration.zero);
    expect(browser.isKilled, true);
    expect(await profile.exists(), false);
  });

  test('closing Firefox cancels without changing the session', () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final browser = FakeFirefoxProcess();
    final launched = Completer<void>();
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (_, __) async {
        launched.complete();
        return browser;
      },
      profilePollInterval: Duration.zero,
    );
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await launched.future;
    browser.exited.complete(0);
    expect(await result, isNull);
    expect(await profile.exists(), false);
  });

  test(
      'Firefox waits for a complete account file instead of saving partial data',
      () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final browser = FakeFirefoxProcess();
    final launched = Completer<void>();
    final account = File('${profile.path}/signedInUser.json');
    await account.writeAsString('{"accountData":');
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (_, __) async {
        launched.complete();
        return browser;
      },
      verifyToken: (_) async {},
      profilePollInterval: Duration.zero,
    );
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await launched.future;
    await Future<void>.delayed(Duration.zero);
    await account.writeAsString(jsonEncode({
      'accountData': {'sessionToken': token},
    }));
    expect((await result)?.token, token);
    expect(await profile.exists(), false);
  });

  test('missing Firefox reports a localized-capable error and cleans up',
      () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (_, __) async =>
          throw const ProcessException('firefox', []),
    );
    await expectLater(
        login.signIn(email: '', title: '', onConfirming: () {}),
        throwsA(isA<FfvpnException>()
            .having((e) => e.kind, 'kind', FfvpnErrorKind.signInUnsupported)));
    expect(await profile.exists(), false);
  });

  test('cancelling before profile creation never launches Firefox', () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final created = Completer<Directory>();
    var launched = false;
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () => created.future,
      startFirefox: (_, __) async {
        launched = true;
        return FakeFirefoxProcess();
      },
    );
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    login.cancel();
    created.complete(profile);
    expect(await result, isNull);
    expect(launched, false);
    expect(await profile.exists(), false);
  });

  test('cancelling a pending Firefox launch suppresses its later failure',
      () async {
    final profile = await Directory.systemTemp.createTemp('ffvpn-test-');
    final started = Completer<void>();
    final launch = Completer<Process>();
    final login = FfvpnBrowserLogin(
      createFirefoxProfile: () async => profile,
      startFirefox: (_, __) {
        started.complete();
        return launch.future;
      },
    );
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await started.future;
    login.cancel();
    launch.completeError(const ProcessException('firefox', []));
    expect(await result, isNull);
    expect(await profile.exists(), false);
  });

  test('uses the Mozilla Sync browser flow for login and registration', () {
    final url = FfvpnBrowserLogin.loginUrl(' a+b@example.com ');
    expect(url.origin, FfvpnBrowserLogin.origin);
    expect(url.queryParameters, {
      'context': 'fx_desktop_v3',
      'service': 'sync',
      'action': 'email',
      'email': 'a+b@example.com',
    });
    expect(FfvpnBrowserLogin.loginUrl('').queryParameters.containsKey('email'),
        false);
  });

  test('accepts only Mozilla-origin valid session messages', () {
    final message = loginMessage(sessionToken: token.toUpperCase());
    expect(
        FfvpnBrowserLogin.readSession(message, FfvpnBrowserLogin.origin)?.token,
        token);
    for (final origin in [
      'http://accounts.firefox.com',
      'https://evil.test',
      'https://accounts.firefox.com.evil.test',
      'null'
    ]) {
      expect(FfvpnBrowserLogin.readSession(message, origin), isNull);
    }
    for (final invalid in ['', 'a' * 63, 'g' * 64]) {
      expect(
          FfvpnBrowserLogin.readSession(
              loginMessage(sessionToken: invalid), FfvpnBrowserLogin.origin),
          isNull);
    }
    expect(
        FfvpnBrowserLogin.readSession(
            {'message': 'invalid'}, FfvpnBrowserLogin.origin),
        isNull);
  });

  test('keeps the browser open until the session is confirmed', () async {
    final web = FakeWebview();
    var calls = 0;
    var confirming = false;
    final login = FfvpnBrowserLogin(
      createWindow: (_) async => web,
      confirmRetry: Duration.zero,
      verifyToken: (_) async {
        calls++;
        if (calls == 1) {
          expect(web.isClosed, false);
          throw const FfvpnException(
              FfvpnErrorKind.other, 'errno 138: unconfirmed session');
        }
      },
    );
    final result = login.signIn(
        email: '', title: 'Mozilla', onConfirming: () => confirming = true);
    await web.launched.future;
    web.handler!(loginMessage(), FfvpnBrowserLogin.origin);
    web.handler!(loginMessage(), FfvpnBrowserLogin.origin);
    final session = await result;
    expect(session?.token, token);
    expect(session?.email, 'user@example.com');
    expect(confirming, true);
    expect(calls, 2);
    expect(web.isClosed, true);
    expect(web.script, contains('WebChannelMessageToChrome'));
  });

  test('answers Firefox status/link requests only on the trusted origin',
      () async {
    final web = FakeWebview();
    final login = FfvpnBrowserLogin(createWindow: (_) async => web);
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await web.launched.future;
    final status = {
      'id': 'account_updates',
      'message': {
        'command': 'fxaccounts:fxa_status',
        'messageId': 4,
      }
    };
    web.handler!(status, 'https://evil.test');
    expect(web.replies, isEmpty);
    web.handler!(status, FfvpnBrowserLogin.origin);
    expect(web.replies.single, {
      'id': 'account_updates',
      'message': {
        'command': 'fxaccounts:fxa_status',
        'messageId': 4,
        'data': {'capabilities': {}, 'signedInUser': null},
      },
    });
    login.cancel();
    expect(await result, isNull);
    expect(web.isClosed, true);
  });

  test('cancelling during confirmation cannot return a late token', () async {
    final web = FakeWebview();
    final verification = Completer<void>();
    final login = FfvpnBrowserLogin(
        createWindow: (_) async => web,
        verifyToken: (_) => verification.future);
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await web.launched.future;
    web.handler!(loginMessage(), FfvpnBrowserLogin.origin);
    login.cancel();
    expect(await result, isNull);
    verification.complete();
    await Future<void>.delayed(Duration.zero);
    expect(web.isClosed, true);
  });

  test('closing the browser cancels without saving a session', () async {
    final web = FakeWebview();
    final login = FfvpnBrowserLogin(createWindow: (_) async => web);
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await web.launched.future;
    await web.close();
    expect(await result, isNull);
  });

  test('does not retry permanent failures or save rejected tokens', () async {
    final web = FakeWebview();
    var calls = 0;
    final login = FfvpnBrowserLogin(
        createWindow: (_) async => web,
        verifyToken: (_) async {
          calls++;
          throw const FfvpnException(FfvpnErrorKind.badToken, 'HTTP 401');
        });
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await web.launched.future;
    final assertion = expectLater(result, throwsA(isA<FfvpnException>()));
    web.handler!(loginMessage(), FfvpnBrowserLogin.origin);
    await assertion;
    expect(calls, 1);
    expect(web.isClosed, true);
  });

  test('handles a page error while browser launch is still pending', () async {
    final web = FakeWebview();
    web.duringLaunch = () async {
      web.loadErrors.add(WebviewLoadError(
        url: FfvpnBrowserLogin.loginUrl('').toString(),
        kind: WebviewLoadErrorKind.connection,
        description: 'connection refused',
      ));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
    };
    final login = FfvpnBrowserLogin(createWindow: (_) async => web);
    final result = login.signIn(email: '', title: '', onConfirming: () {});
    await expectLater(
        result,
        throwsA(isA<FfvpnException>()
            .having((error) => error.kind, 'kind', FfvpnErrorKind.network)));
    expect(web.isClosed, true);
  });

  test('recognizes unconfirmed sessions and unverified new accounts', () {
    for (final error in [
      'errno 138',
      'errno 201',
      'Unconfirmed session',
      'not verified'
    ]) {
      expect(FfvpnBrowserLogin.looksUnconfirmed(error), true);
    }
    expect(FfvpnBrowserLogin.looksUnconfirmed('errno 1380'), false);
    expect(FfvpnBrowserLogin.looksUnconfirmed('HTTP 401'), false);
  });
}
