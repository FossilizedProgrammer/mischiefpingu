// test/models/settings_validation_test.dart
//
// تست نرمال‌سازی تنظیمات Firefox VPN (SNI و آپ‌استریم).

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';

void main() {
  group('normalizeFfvpnSni', () {
    test('keeps a bare hostname', () {
      expect(SettingsValidation.normalizeFfvpnSni('  edge.example.com '),
          'edge.example.com');
    });

    test('strips scheme, path and port', () {
      expect(
        SettingsValidation.normalizeFfvpnSni('https://edge.example.com:443/x'),
        'edge.example.com',
      );
      expect(SettingsValidation.normalizeFfvpnSni('edge.example.com:8443'),
          'edge.example.com');
      expect(SettingsValidation.normalizeFfvpnSni(''), '');
    });
  });

  group('_validateFfvpn', () {
    test('removed and out-of-range upstream values fall back to direct', () {
      for (final bad in <int>[2, -1, 7, 99]) {
        final s = AppSettings()..ffvpnUpstreamType = bad;
        SettingsValidation.validateAndNormalize(s);
        expect(s.ffvpnUpstreamType, 0, reason: 'input $bad');
      }

      final s = AppSettings()..ffvpnUpstreamType = 6;
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnUpstreamType, 6);
    });

    test('manual upstream only accepts SOCKS5 schemes', () {
      final s = AppSettings()
        ..ffvpnUpstreamType = 1
        ..ffvpnProxyType = 'http';
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnProxyType, 'socks5');

      s.ffvpnProxyType = 'socks5h';
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnProxyType, 'socks5h');
    });

    test('bad local ports fall back to the defaults', () {
      final s = AppSettings()
        ..ffvpnSocksPort = 0
        ..ffvpnHttpPort = 70000
        ..ffvpnProxyPort = 70000;
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnSocksPort, 1083);
      expect(s.ffvpnHttpPort, 8083);
      expect(s.ffvpnProxyPort, 1080);
    });

    test('a pasted URL as SNI is reduced to the hostname', () {
      final s = AppSettings()
        ..ffvpnSni = 'https://www.example.com/path';
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnSni, 'www.example.com');
    });
  });
}
