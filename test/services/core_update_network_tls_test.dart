import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/services/core_update/core_update_network.dart';
import 'package:mischiefpingu/services/core_update/network/core_update_curl.dart';

class _SocksProxy {
  final ServerSocket server;
  final sockets = <Socket>[];
  final requestedPorts = <int>[];

  _SocksProxy(this.server) {
    server.listen(_accept);
  }

  static Future<_SocksProxy> start() async =>
      _SocksProxy(await ServerSocket.bind(InternetAddress.loopbackIPv4, 0));

  String get address => '127.0.0.1:${server.port}';

  void _accept(Socket socket) {
    sockets.add(socket);
    final buffer = <int>[];
    var stage = 0;
    Socket? upstream;
    socket.listen(
        (data) {
          if (stage == 3) {
            upstream!.add(data);
            return;
          }
          buffer.addAll(data);
          if (stage == 0) {
            if (buffer.length < 2 || buffer.length < 2 + buffer[1]) return;
            buffer.removeRange(0, 2 + buffer[1]);
            socket.add([5, 0]);
            stage = 1;
          }
          if (stage != 1 || buffer.length < 5) return;
          final domain = buffer[3] == 3;
          final addressLength = domain ? buffer[4] : 4;
          final offset = domain ? 5 : 4;
          final length = offset + addressLength + 2;
          if (buffer.length < length) return;
          final host = domain
              ? utf8.decode(buffer.sublist(offset, offset + addressLength))
              : buffer.sublist(offset, offset + addressLength).join('.');
          final port = (buffer[length - 2] << 8) | buffer[length - 1];
          buffer.removeRange(0, length);
          requestedPorts.add(port);
          stage = 2;
          if (host != '127.0.0.1') {
            socket.destroy();
            return;
          }
          Socket.connect(host, port).then((remote) {
            sockets.add(remote);
            upstream = remote;
            socket.add([5, 0, 0, 1, 127, 0, 0, 1, 0, 0]);
            remote.add(buffer);
            buffer.clear();
            stage = 3;
            remote.listen(socket.add,
                onDone: socket.destroy,
                onError: (Object _) => socket.destroy());
          }, onError: (Object _) => socket.destroy());
        },
        onDone: () => upstream?.destroy(),
        onError: (Object _) {
          upstream?.destroy();
          socket.destroy();
        });
  }

  Future<void> close() async {
    for (final socket in sockets) {
      socket.destroy();
    }
    await server.close();
  }
}

void main() {
  const live = bool.fromEnvironment('CORE_UPDATE_LIVE_TLS');
  const releaseNotes = 'Release notes: فارسی — Español — Русский';
  const releaseUrl = 'https://api.github.com/repos/'
      'FossilizedProgrammer/firefox-vpn-go/releases/latest';
  late Directory temp;
  late HttpServer plain;
  late HttpServer untrusted;
  late _SocksProxy socks;
  late CoreUpdateNetwork network;
  var receivedUntrustedRequests = 0;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('core_update_tls_test_');
    network = CoreUpdateNetwork();
    socks = await _SocksProxy.start();
    plain = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    plain.listen((request) async {
      if (request.uri.path == '/empty') {
        request.response.contentLength = 0;
      } else if (request.uri.path == '/missing') {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        request.response.headers.contentType = ContentType.json;
        final body = utf8.encode(jsonEncode({
          'tag_name': 'v1.0.25',
          'body': releaseNotes,
        }));
        request.response.contentLength = body.length;
        if (request.method != 'HEAD') request.response.add(body);
      }
      await request.response.close();
    });
    final context = SecurityContext()
      ..useCertificateChain('test/fixtures/core_update_untrusted_cert.pem')
      ..usePrivateKey('test/fixtures/core_update_untrusted_key.pem');
    untrusted =
        await HttpServer.bindSecure(InternetAddress.loopbackIPv4, 0, context);
    receivedUntrustedRequests = 0;
    untrusted.listen((request) async {
      receivedUntrustedRequests++;
      request.response.write('untrusted');
      await request.response.close();
    }, onError: (Object _) {});
  });

  tearDown(() async {
    await socks.close();
    await plain.close(force: true);
    await untrusted.close(force: true);
    await temp.delete(recursive: true);
  });

  test('Windows uses system curl with Windows trust, never PATH curl',
      () async {
    await network.ensureCurl();
    if (Platform.isWindows) {
      expect(CoreUpdateCurl.executable,
          '${Platform.environment['SystemRoot']}\\System32\\curl.exe');
      final version = await Process.run(
          CoreUpdateCurl.executable, ['--disable', '--version']);
      expect(
          CoreUpdateCurl.usesWindowsCertificateStore(version.stdout as String),
          isTrue);
    }
  });

  test('Windows trust recognizes Schannel and the legacy WinSSL name', () {
    for (final version in [
      'curl 7.55.1 (Windows) libcurl/7.55.1 WinSSL\n'
          'Release-Date: 2017-11-14, security patched: 2019-11-05\n'
          'Protocols: dict file ftp ftps http https imap imaps pop3 pop3s '
          'smtp smtps telnet tftp\n'
          'Features: AsynchDNS IPv6 Largefile SSPI Kerberos SPNEGO NTLM SSL',
      'curl 8.14.1 (Windows) libcurl/8.14.1 Schannel',
      'curl 7.55.1 (Windows) libcurl/7.55.1 winssl',
      'curl 8.14.1 (Windows) libcurl/8.14.1 schannel',
    ]) {
      expect(CoreUpdateCurl.usesWindowsCertificateStore(version), isTrue,
          reason: version);
    }
  });

  test('Windows trust rejects other backends and misleading names', () {
    for (final version in [
      'curl 8.14.1 (Windows) libcurl/8.14.1 OpenSSL/3.5.0',
      'curl 8.14.1 (Windows) libcurl/8.14.1 LibreSSL/4.0.0',
      'curl 8.14.1 (Windows) libcurl/8.14.1 WinSSLHelper',
      'curl 8.14.1 (Windows) libcurl/8.14.1 SchannelHelper',
      'curl 8.14.1 (Windows) libcurl/8.14.1 OpenSSL/3.5.0\n'
          'Features: Schannel',
      '',
    ]) {
      expect(CoreUpdateCurl.usesWindowsCertificateStore(version), isFalse,
          reason: version);
    }
  });

  test('curl ignores configuration, ambient proxies and CA overrides', () {
    expect(CoreUpdateCurl.arguments(null).first, '--disable');
    expect(CoreUpdateCurl.arguments(null), containsAllInOrder(['--proxy', '']));
    expect(
        CoreUpdateCurl.arguments(null), containsAllInOrder(['--noproxy', '*']));
    expect(
        CoreUpdateCurl.arguments(socks.address),
        containsAllInOrder(
            ['--noproxy', '', '--socks5-hostname', socks.address]));
    expect(CoreUpdateCurl.arguments(null),
        containsAllInOrder(['--proto-redir', '=https']));
    for (final name in CoreUpdateCurl.environment.keys) {
      expect(
          name.toLowerCase(),
          isNot(isIn([
            'http_proxy',
            'https_proxy',
            'all_proxy',
            'no_proxy',
            'curl_ca_bundle',
            'ssl_cert_file',
            'ssl_cert_dir',
            'curl_ssl_backend',
          ])));
    }
  });

  for (final viaProxy in [false, true]) {
    final route = viaProxy ? 'SOCKS proxy' : 'direct';

    test('$route: metadata, HEAD and download succeed', () async {
      final proxy = viaProxy ? socks.address : null;
      final url = 'http://127.0.0.1:${plain.port}/release';
      final release = await network.getJson(url, proxy);
      expect(release['tag_name'], 'v1.0.25');
      expect(release['body'], releaseNotes);
      expect((await network.headRequest(url, proxy))?.status, 200);
      final file = File('${temp.path}/download.json');
      final progress = <int>[];
      await network.download(url, file.path,
          proxy: proxy,
          totalHint: utf8.encode(jsonEncode(release)).length,
          onProgress: progress.add);
      final downloaded = jsonDecode(await file.readAsString());
      expect(downloaded['tag_name'], 'v1.0.25');
      expect(downloaded['body'], releaseNotes);
      expect(progress, isNotEmpty);
      if (viaProxy) {
        expect(socks.requestedPorts, [plain.port, plain.port, plain.port]);
      } else {
        expect(socks.requestedPorts, isEmpty);
      }
    });

    test('$route: untrusted TLS is rejected before HTTP', () async {
      final proxy = viaProxy ? socks.address : null;
      final url = 'https://127.0.0.1:${untrusted.port}/release';
      await expectLater(network.getJson(url, proxy), throwsA(isA<Exception>()));
      expect(await network.headRequest(url, proxy), isNull);
      await expectLater(
          network.download(url, '${temp.path}/untrusted.bin', proxy: proxy),
          throwsA(isA<Exception>()));
      expect(receivedUntrustedRequests, 0);
    });

    test('$route: HTTP failures and empty downloads are rejected', () async {
      final proxy = viaProxy ? socks.address : null;
      final root = 'http://127.0.0.1:${plain.port}';
      await expectLater(network.getJson('$root/missing', proxy),
          throwsA(isA<HttpException>()));
      await expectLater(
          network.download('$root/missing', '${temp.path}/missing',
              proxy: proxy),
          throwsA(isA<HttpException>()));
      await expectLater(
          network.download('$root/empty', '${temp.path}/empty', proxy: proxy),
          throwsStateError);
    });
  }

  test('curl does not load an insecure user configuration', () async {
    final curlHome = await Directory('${temp.path}/curl-home').create();
    for (final name in ['.curlrc', '_curlrc']) {
      await File('${curlHome.path}/$name').writeAsString('insecure\n');
    }
    final result = await Process.run(
      CoreUpdateCurl.executable,
      [
        ...CoreUpdateCurl.arguments(null),
        '--max-time',
        '10',
        '--url',
        'https://127.0.0.1:${untrusted.port}/release',
      ],
      environment: {
        ...CoreUpdateCurl.environment,
        'CURL_HOME': curlHome.path,
      },
      includeParentEnvironment: false,
    );
    expect(result.exitCode, isNot(0));
    expect(receivedUntrustedRequests, 0);
  });

  test('explicit dead proxy is not bypassed or replaced with direct', () async {
    final reserved = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = '127.0.0.1:${reserved.port}';
    await reserved.close();
    final url = 'http://127.0.0.1:${plain.port}/release';
    await expectLater(
        network.getJson(url, proxy), throwsA(isA<HttpException>()));
    await expectLater(network.download(url, '${temp.path}/dead', proxy: proxy),
        throwsA(isA<HttpException>()));
  });

  test('cancelled curl download does not start a connection', () async {
    await expectLater(
        network.download(
            'http://127.0.0.1:${plain.port}/release', '${temp.path}/cancelled',
            proxy: socks.address, onCancelCheck: () => true),
        throwsStateError);
    expect(socks.requestedPorts, isEmpty);
  });

  test('live GitHub TLS: check, HEAD and download use valid certificates',
      () async {
    final release = await network.getJson(releaseUrl, null);
    expect(release['tag_name'], isNotEmpty);
    expect(release['assets'], isNotEmpty);
    expect((await network.headRequest(releaseUrl, null))?.status, 200);
    final file = File('${temp.path}/github-release.json');
    await network.download(releaseUrl, file.path);
    expect(
        jsonDecode(await file.readAsString())['tag_name'], release['tag_name']);
  }, skip: !live, timeout: const Timeout(Duration(minutes: 3)));
}
