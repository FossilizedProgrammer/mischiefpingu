// test/services/upstream_chain_test.dart
//
// هر تونل باید بتواند از تونل‌های دیگر به‌عنوان آپ‌استریم استفاده کند.
// این تست گزینه‌های تازه‌افزوده‌شده (Firefox VPN / Lantern / Geph) را برای
// Psiphon، SSTP و Tor و همچنین محدودهٔ مجازِ اعتبارسنجی را بررسی می‌کند.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_upstream_builder.dart';
import 'package:mischiefpingu/services/geph/geph_upstream_builder.dart';
import 'package:mischiefpingu/services/lantern/lantern_upstream_builder.dart';
import 'package:mischiefpingu/services/psiphon/psiphon_upstream_builder.dart';
import 'package:mischiefpingu/services/process_service.dart';
import 'package:mischiefpingu/services/sstp/sstp_upstream_builder.dart';
import 'package:mischiefpingu/services/tor/tor_bridge_resolver.dart';

void main() {
  late AppSettings settings;
  late ProcessService ps;

  setUp(() {
    settings = AppSettings();
    ps = ProcessService();
  });

  group('Psiphon upstream', () {
    test('new built-in tunnels set UpstreamProxyURL to their SOCKS port', () {
      final cases = <int, int>{
        PsiphonUpstreamBuilder.ffvpn: settings.ffvpnSocksPort,
        PsiphonUpstreamBuilder.lantern: settings.lanternSocksPort,
        PsiphonUpstreamBuilder.geph: settings.gephSocksPort,
        PsiphonUpstreamBuilder.npv: settings.npvSocksPort,
      };

      for (final entry in cases.entries) {
        final s = AppSettings()..upstreamType = entry.key;
        final builder = PsiphonUpstreamBuilder(
          settings: s,
          processService: ps,
        );
        final config = <String, dynamic>{};
        expect(builder.hasOverride, isTrue);
        builder.apply(config);
        expect(config['UpstreamProxyURL'], 'socks5://127.0.0.1:${entry.value}');
      }
    });

    test('direct leaves the config untouched', () {
      final builder = PsiphonUpstreamBuilder(
        settings: AppSettings()..upstreamType = PsiphonUpstreamBuilder.direct,
        processService: ps,
      );
      final config = <String, dynamic>{};
      expect(builder.hasOverride, isFalse);
      builder.apply(config);
      expect(config, isEmpty);
    });

    test('Aether is not a Psiphon upstream option', () {
      // ۲ (آپ‌استریم اتر) از رابط Psiphon حذف شده؛ مقدار ذخیره‌شدهٔ
      // قدیمی هم به «مستقیم» برمی‌گردد.
      final s = AppSettings()..upstreamType = 2;
      SettingsValidation.validateAndNormalize(s);
      expect(s.upstreamType, 0);

      final builder = PsiphonUpstreamBuilder(
        settings: AppSettings()..upstreamType = 2,
        processService: ps,
      );
      final config = <String, dynamic>{};
      expect(builder.hasOverride, isFalse);
      builder.apply(config);
      expect(config, isEmpty);
    });

    test('Psiphon presets are Fronting / Conduit / Direct', () {
      for (final entry in const {1: 0, 2: 3, 3: 0}.entries) {
        final s = AppSettings()..upstreamType = 99;
        s.applyPreset(entry.key);
        expect(s.upstreamType, entry.value, reason: 'preset ${entry.key}');
      }
      final fronting = AppSettings();
      fronting.applyPreset(1);
      expect(fronting.isFronted, isTrue);
      expect(fronting.useSunAndLion, isTrue);
    });

    // باگ قدیم: preset «Direct» مقدار ۴ (Tor) را می‌نوشت و UI آن را Direct
    // نشان می‌داد، پس Psiphon پشت یک SOCKS خاموش بی‌پایان retry می‌کرد.
    test('the Direct preset writes no upstream proxy at all', () {
      final s = AppSettings();
      s.applyPreset(3);
      final builder = PsiphonUpstreamBuilder(settings: s, processService: ps);
      expect(builder.hasOverride, isFalse);
      final config = <String, dynamic>{};
      builder.apply(config);
      expect(config['UpstreamProxyURL'], isNull);
    });

    test('Tor upstream stays visible as 4, not masked to direct', () {
      final s = AppSettings()..upstreamType = 4;
      SettingsValidation.validateAndNormalize(s);
      expect(s.upstreamType, 4);
      final config = <String, dynamic>{};
      PsiphonUpstreamBuilder(settings: s, processService: ps).apply(config);
      expect(
          config['UpstreamProxyURL'], 'socks5://127.0.0.1:${s.torSocksPort}');
    });
  });

  group('SSTP upstream', () {
    test('new built-in tunnels add -proxy with their SOCKS port', () {
      final cases = <int, int>{
        SstpUpstreamBuilder.ffvpn: settings.ffvpnSocksPort,
        SstpUpstreamBuilder.lantern: settings.lanternSocksPort,
        SstpUpstreamBuilder.geph: settings.gephSocksPort,
        SstpUpstreamBuilder.npv: settings.npvSocksPort,
      };

      for (final entry in cases.entries) {
        final s = AppSettings()..sstpUpstreamType = entry.key;
        final builder = SstpUpstreamBuilder(
          settings: s,
          processService: ps,
        );
        final args = <String>[];
        builder.apply(args);
        expect(args, ['-proxy', 'socks5://127.0.0.1:${entry.value}']);
      }
    });

    test('direct adds no proxy argument', () {
      final builder = SstpUpstreamBuilder(
        settings: AppSettings()..sstpUpstreamType = SstpUpstreamBuilder.direct,
        processService: ps,
      );
      final args = <String>[];
      builder.apply(args);
      expect(args, isEmpty);
    });
  });

  group('Aether upstream in the other cores', () {
    test('every core with an upstream setting can chain through Aether', () {
      final s = AppSettings();
      final expected = 'socks5://127.0.0.1:${s.aetherLocalPort}';

      final ffvpn = FfvpnUpstreamBuilder(
        settings: s..ffvpnUpstreamType = FfvpnUpstreamBuilder.aether,
        processService: ps,
      );
      final ffvpnArgs = <String>[];
      ffvpn.apply(ffvpnArgs);
      expect(ffvpn.label, 'Aether');
      expect(ffvpnArgs, ['--dial-proxy', expected]);

      final lantern = LanternUpstreamBuilder(
        settings: s..lanternUpstreamType = LanternUpstreamBuilder.aether,
        processService: ps,
      );
      final lanternArgs = <String>[];
      lantern.apply(lanternArgs);
      expect(lantern.label, 'Aether');
      expect(lanternArgs, ['--upstream-proxy', expected]);

      final geph = GephUpstreamBuilder(
        settings: s..gephUpstreamType = GephUpstreamBuilder.aether,
        processService: ps,
      );
      final gephArgs = <String>[];
      geph.apply(gephArgs);
      expect(geph.label, 'Aether');
      expect(gephArgs, ['--upstream', expected]);
    });

    test('Aether (2) survives validation for all three cores', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = 2
        ..lanternUpstreamType = 2
        ..gephUpstreamType = 2;
      SettingsValidation.validateAndNormalize(s);

      expect(s.ffvpnUpstreamType, 2);
      expect(s.lanternUpstreamType, 2);
      expect(s.gephUpstreamType, 2);
    });
  });

  group('Tor upstream', () {
    test('every built-in tunnel maps to its local SOCKS port', () {
      final cases = <String, int>{
        'psiphon': settings.socksPort,
        'sstp': settings.sstpSocksPort,
        'wireguard': settings.wireguardSocksPort,
        'ffvpn': settings.ffvpnSocksPort,
        'lantern': settings.lanternSocksPort,
        'geph': settings.gephSocksPort,
        'npv': settings.npvSocksPort,
      };

      for (final entry in cases.entries) {
        final s = AppSettings()..torTransport = entry.key;
        final decision = TorBridgeResolver.resolve(
          settings: s,
          psiphonSocks: s.socksPort,
          sstpSocks: s.sstpSocksPort,
          wireguardSocks: s.wireguardSocksPort,
          ffvpnSocks: s.ffvpnSocksPort,
          lanternSocks: s.lanternSocksPort,
          gephSocks: s.gephSocksPort,
          npvSocks: s.npvSocksPort,
        );
        expect(
          decision.upstreamSocks,
          entry.value,
          reason: 'tor transport ${entry.key}',
        );
      }
    });

    test('direct has no upstream SOCKS', () {
      final s = AppSettings()..torTransport = 'direct';
      final decision = TorBridgeResolver.resolve(
        settings: s,
        psiphonSocks: s.socksPort,
      );
      expect(decision.upstreamSocks, isNull);
    });
  });

  group('validation', () {
    test('the new upstream values are kept', () {
      final s = AppSettings()
        ..upstreamType = 9 // Psiphon → Geph
        ..ffvpnUpstreamType = 9 // Firefox VPN → Geph
        ..lanternUpstreamType = 7 // Lantern → Firefox VPN
        ..gephUpstreamType = 8 // Geph → Lantern
        ..sstpUpstreamType = 6 // SSTP → Firefox VPN
        ..torTransport = 'geph';
      SettingsValidation.validateAndNormalize(s);

      expect(s.upstreamType, 9);
      expect(s.ffvpnUpstreamType, 9);
      expect(s.lanternUpstreamType, 7);
      expect(s.gephUpstreamType, 8);
      expect(s.sstpUpstreamType, 6);
      expect(s.torTransport, 'geph');
    });

    test('NPV (10) is kept as an upstream hop for every tunnel', () {
      final s = AppSettings()
        ..upstreamType = 10
        ..sstpUpstreamType = 10
        ..ffvpnUpstreamType = 10
        ..lanternUpstreamType = 10
        ..gephUpstreamType = 10;
      SettingsValidation.validateAndNormalize(s);

      expect(s.upstreamType, 10);
      expect(s.sstpUpstreamType, 10);
      expect(s.ffvpnUpstreamType, 10);
      expect(s.lanternUpstreamType, 10);
      expect(s.gephUpstreamType, 10);
    });

    test('a tunnel cannot be its own upstream', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = 7
        ..lanternUpstreamType = 8
        ..gephUpstreamType = 9;
      SettingsValidation.validateAndNormalize(s);

      expect(s.ffvpnUpstreamType, 0);
      expect(s.lanternUpstreamType, 0);
      expect(s.gephUpstreamType, 0);
    });

    test('out-of-range upstream values fall back to direct', () {
      // ۱۱ هیچ‌جا آپ‌استریم مجاز نیست (۱۰ = NPV).
      final s = AppSettings()
        ..upstreamType = 11
        ..ffvpnUpstreamType = 11
        ..lanternUpstreamType = 11
        ..gephUpstreamType = 11
        ..sstpUpstreamType = 9
        ..torTransport = 'nonsense';
      SettingsValidation.validateAndNormalize(s);

      expect(s.upstreamType, 0);
      expect(s.ffvpnUpstreamType, 0);
      expect(s.lanternUpstreamType, 0);
      expect(s.gephUpstreamType, 0);
      expect(s.sstpUpstreamType, 0);
      expect(s.torTransport, 'direct');
    });

    test('new tor transports survive a round-trip', () {
      for (final t in ['ffvpn', 'lantern', 'geph']) {
        final s = AppSettings()..torTransport = t;
        final back = AppSettings.fromJson(
          Map<String, dynamic>.from(s.toJson() as Map),
        );
        expect(back.torTransport, t);
      }
    });
  });
}
