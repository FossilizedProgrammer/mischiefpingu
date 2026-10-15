// test/services/lantern_upstream_builder_test.dart
//
// تست تبدیل تنظیمات آپ‌استریم لنترن به URL فلگ `--upstream-proxy`.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/lantern/lantern_upstream_builder.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  late AppSettings settings;
  late ProcessService ps;
  late LanternUpstreamBuilder builder;

  setUp(() {
    settings = AppSettings();
    ps = ProcessService();
    builder = LanternUpstreamBuilder(settings: settings, processService: ps);
  });

  test('direct builds no upstream', () {
    expect(builder.hasUpstream, isFalse);
    expect(builder.buildUrl(), isEmpty);
    expect(builder.isAvailable, isTrue);

    final args = <String>[];
    builder.apply(args);
    expect(args, isEmpty);
  });

  test('internal tunnels map to their local SOCKS port', () {
    settings.lanternUpstreamType = LanternUpstreamBuilder.psiphon;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.socksPort}');
    expect(builder.socksPort, settings.socksPort);

    settings.lanternUpstreamType = LanternUpstreamBuilder.tor;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.torSocksPort}');

    settings.lanternUpstreamType = LanternUpstreamBuilder.sstp;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.sstpSocksPort}');

    settings.lanternUpstreamType = LanternUpstreamBuilder.wireguard;
    expect(
      builder.buildUrl(),
      'socks5://127.0.0.1:${settings.wireguardSocksPort}',
    );
  });

  test('manual upstream needs host and port', () {
    settings.lanternUpstreamType = LanternUpstreamBuilder.manual;
    expect(builder.buildUrl(), isEmpty);
    expect(builder.isAvailable, isFalse);

    settings
      ..lanternProxyIp = '10.0.0.5'
      ..lanternProxyPort = 1080;
    expect(builder.buildUrl(), 'socks5://10.0.0.5:1080');
    expect(builder.isAvailable, isTrue);

    settings
      ..lanternProxyType = 'http'
      ..lanternProxyUser = 'user'
      ..lanternProxyPass = 'secret';
    expect(builder.buildUrl(), 'http://user:secret@10.0.0.5:1080');
  });

  test('apply adds --upstream-proxy and masks credentials in the log', () {
    settings
      ..lanternUpstreamType = LanternUpstreamBuilder.manual
      ..lanternProxyType = 'http'
      ..lanternProxyIp = '10.0.0.5'
      ..lanternProxyPort = 1080
      ..lanternProxyUser = 'user'
      ..lanternProxyPass = 'secret';

    final args = <String>[];
    builder.apply(args);

    expect(args, ['--upstream-proxy', 'http://user:secret@10.0.0.5:1080']);
    expect(builder.describeUrl(), 'http://user:****@10.0.0.5:1080');

    final lastLog = ps.fullLog.last;
    expect(lastLog, contains('Lantern upstream: Manual'));
    expect(lastLog, contains('http://user:****@10.0.0.5:1080'));
    expect(lastLog, isNot(contains('secret')));
  });

  test('internal tunnel upstream is only available while it runs', () {
    settings.lanternUpstreamType = LanternUpstreamBuilder.tor;
    expect(builder.isAvailable, isFalse);

    ps.isTorRunning = true;
    expect(builder.isAvailable, isTrue);
  });

  test('maskCredentials leaves passwordless URLs alone', () {
    expect(
      LanternUpstreamBuilder.maskCredentials('socks5://10.0.0.5:1080'),
      'socks5://10.0.0.5:1080',
    );
    expect(LanternUpstreamBuilder.maskCredentials(''), isEmpty);
  });
}
