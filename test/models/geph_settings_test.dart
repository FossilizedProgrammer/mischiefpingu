// test/models/geph_settings_test.dart
//
// تست تنظیمات گف: ماندگاری فیلدها در JSON، نرمال‌سازی مقادیر نامعتبر
// و منبع لاگ Geph در لیست پیش‌فرض.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';

void main() {
  test('geph fields survive a json round-trip', () {
    final s = AppSettings()
      ..gephSocksPort = 19909
      ..gephHttpPort = 19910
      ..gephCountry = 'nl'
      ..gephCountryFilter = 'plus'
      ..gephShareLan = true
      ..gephUpstreamType = 4
      ..gephProxyType = 'socks5h'
      ..gephProxyIp = '10.0.0.3'
      ..gephProxyPort = 2081
      ..gephProxyUser = 'u'
      ..gephProxyPass = 'p'
      ..gephAccountSource = AppSettings.gephAccountSourceCode
      ..gephAccountFile = '  /tmp/x/account.txt  '
      ..gephAccountCode = '  gg_code  ';

    final back = AppSettings.fromJson(
      Map<String, dynamic>.from(s.toJson() as Map),
    );

    expect(back.gephSocksPort, 19909);
    expect(back.gephHttpPort, 19910);
    // بارگذاری، کد کشور را نرمال می‌کند ('nl' → 'NL').
    expect(back.gephCountry, 'NL');
    expect(back.gephCountryFilter, 'plus');
    expect(back.gephShareLan, isTrue);
    expect(back.gephUpstreamType, 4);
    expect(back.gephProxyType, 'socks5h');
    expect(back.gephProxyIp, '10.0.0.3');
    expect(back.gephProxyPort, 2081);
    expect(back.gephProxyUser, 'u');
    expect(back.gephProxyPass, 'p');
    expect(back.gephAccountSource, AppSettings.gephAccountSourceCode);
    // بارگذاری، مسیر و کد را trim می‌کند.
    expect(back.gephAccountFile, '/tmp/x/account.txt');
    expect(back.gephAccountCode, 'gg_code');
  });

  test('geph defaults match the CLI defaults', () {
    final s = AppSettings();
    expect(s.gephSocksPort, 9909);
    expect(s.gephHttpPort, 9910);
    expect(s.gephCountry, 'auto');
    expect(s.gephCountryFilter, 'all');
    expect(s.gephShareLan, isFalse);
    expect(s.gephUpstreamType, 0);
    expect(s.gephProxyType, 'socks5');
    expect(s.gephAccountSource, AppSettings.gephAccountSourceFile);
    expect(s.gephAccountFile, '');
    expect(s.gephAccountCode, '');
  });

  test('validation normalizes invalid geph values', () {
    final s = AppSettings()
      ..gephSocksPort = 0
      ..gephHttpPort = 70000
      ..gephCountry = ' netherlands '
      ..gephCountryFilter = 'nonsense'
      ..gephUpstreamType = 2 // Aether حذف‌شده
      ..gephProxyType = 'ftp'
      ..gephProxyIp = '  10.0.0.9  '
      ..gephProxyPort = 99999
      ..gephAccountSource = 'nonsense'
      ..gephAccountFile = '  /tmp/a.txt  ';

    SettingsValidation.validateAndNormalize(s);

    expect(s.gephSocksPort, 9909);
    expect(s.gephHttpPort, 9910);
    expect(s.gephCountry, 'auto');
    expect(s.gephCountryFilter, 'all');
    expect(s.gephUpstreamType, 0);
    expect(s.gephProxyType, 'socks5');
    expect(s.gephProxyIp, '10.0.0.9');
    expect(s.gephProxyPort, 1080);
    expect(s.gephAccountSource, AppSettings.gephAccountSourceFile);
    expect(s.gephAccountFile, '/tmp/a.txt');
  });

  test('a valid country filter is kept as-is', () {
    final s = AppSettings()..gephCountryFilter = 'free';
    SettingsValidation.validateAndNormalize(s);
    expect(s.gephCountryFilter, 'free');
  });

  test('a two-letter country code is upper-cased', () {
    final s = AppSettings()..gephCountry = 'nl';
    SettingsValidation.validateAndNormalize(s);
    expect(s.gephCountry, 'NL');
  });

  test('HTTP port 0 is allowed (listener disabled)', () {
    final s = AppSettings()..gephHttpPort = 0;
    SettingsValidation.validateAndNormalize(s);
    expect(s.gephHttpPort, 0);
  });

  test('Geph is a valid log source and part of the defaults', () {
    final s = AppSettings();
    expect(s.enabledLogSources, contains('Geph'));

    final dirty = AppSettings()
      ..enabledLogSources = ['Geph', 'NotASource'];
    SettingsValidation.validateAndNormalize(dirty);
    expect(dirty.enabledLogSources, ['Geph']);
  });
}
