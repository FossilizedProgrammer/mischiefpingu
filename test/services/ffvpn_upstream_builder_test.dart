// test/services/ffvpn_upstream_builder_test.dart
//
// تست تبدیل تنظیمات آپ‌استریم Firefox VPN به فلگ `--dial-proxy` باینری Go.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_upstream_builder.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  late ProcessService processService;

  FfvpnUpstreamBuilder builderFor(AppSettings s) => FfvpnUpstreamBuilder(
        settings: s,
        processService: processService,
      );

  setUp(() => processService = ProcessService());

  group('buildUrl', () {
    test('direct has no upstream', () {
      final b = builderFor(AppSettings());
      expect(b.hasUpstream, isFalse);
      expect(b.buildUrl(), isEmpty);
      expect(b.socksPort, isNull);
    });

    test('built-in tunnels map to their local SOCKS ports', () {
      final cases = <int, String>{
        FfvpnUpstreamBuilder.psiphon: 'socks5://127.0.0.1:1080',
        FfvpnUpstreamBuilder.tor: 'socks5://127.0.0.1:19050',
        FfvpnUpstreamBuilder.sstp: 'socks5://127.0.0.1:1082',
        FfvpnUpstreamBuilder.wireguard: 'socks5://127.0.0.1:1085',
        FfvpnUpstreamBuilder.lantern: 'socks5://127.0.0.1:18071',
        FfvpnUpstreamBuilder.geph: 'socks5://127.0.0.1:9909',
      };
      for (final entry in cases.entries) {
        final s = AppSettings()..ffvpnUpstreamType = entry.key;
        final b = builderFor(s);
        expect(b.hasUpstream, isTrue, reason: b.label);
        expect(b.buildUrl(), entry.value, reason: b.label);
        expect(b.label, isNot('Direct'));
      }
    });

    test('manual without host/port is treated as unconfigured', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = FfvpnUpstreamBuilder.manual
        ..ffvpnProxyIp = ''
        ..ffvpnProxyPort = 1080;
      expect(builderFor(s).buildUrl(), isEmpty);

      s.ffvpnProxyIp = '10.0.0.1';
      s.ffvpnProxyPort = 0;
      expect(builderFor(s).buildUrl(), isEmpty);
    });

    test('manual builds a socks5 URL with encoded credentials', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = FfvpnUpstreamBuilder.manual
        ..ffvpnProxyType = 'socks5'
        ..ffvpnProxyIp = '10.0.0.1'
        ..ffvpnProxyPort = 9050
        ..ffvpnProxyUser = 'alice'
        ..ffvpnProxyPass = 'p@ss:w/rd';
      expect(
        builderFor(s).buildUrl(),
        'socks5://alice:p%40ss%3Aw%2Frd@10.0.0.1:9050',
      );
    });

    test('manual without credentials has no userinfo', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = FfvpnUpstreamBuilder.manual
        ..ffvpnProxyIp = '10.0.0.1'
        ..ffvpnProxyPort = 9050;
      expect(builderFor(s).buildUrl(), 'socks5://10.0.0.1:9050');
    });
  });

  group('apply', () {
    test('adds --dial-proxy and logs the masked URL', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = FfvpnUpstreamBuilder.manual
        ..ffvpnProxyIp = '10.0.0.1'
        ..ffvpnProxyPort = 9050
        ..ffvpnProxyUser = 'alice'
        ..ffvpnProxyPass = 'hunter2';
      final args = <String>[];
      builderFor(s).apply(args);

      expect(args, ['--dial-proxy', 'socks5://alice:hunter2@10.0.0.1:9050']);
      final log = processService.fullLog.join('\n');
      expect(log, contains('Firefox VPN upstream: Manual'));
      expect(log, isNot(contains('hunter2')));
      expect(log, contains('alice:****@10.0.0.1:9050'));
    });

    test('direct adds nothing', () {
      final args = <String>[];
      builderFor(AppSettings()).apply(args);
      expect(args, isEmpty);
    });

    test('unconfigured manual warns and connects directly', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = FfvpnUpstreamBuilder.manual;
      final args = <String>[];
      builderFor(s).apply(args);

      expect(args, isEmpty);
      expect(processService.fullLog.join('\n'), contains('connecting directly'));
    });
  });

  group('maskCredentials', () {
    test('hides the password', () {
      expect(
        FfvpnUpstreamBuilder.maskCredentials(
          'socks5://alice:hunter2@10.0.0.1:1080',
        ),
        'socks5://alice:****@10.0.0.1:1080',
      );
    });

    test('leaves URLs without credentials untouched', () {
      expect(
        FfvpnUpstreamBuilder.maskCredentials('socks5://127.0.0.1:1080'),
        'socks5://127.0.0.1:1080',
      );
      expect(
        FfvpnUpstreamBuilder.maskCredentials('socks5://alice@10.0.0.1:1080'),
        'socks5://alice@10.0.0.1:1080',
      );
      expect(FfvpnUpstreamBuilder.maskCredentials(''), isEmpty);
    });
  });
}
