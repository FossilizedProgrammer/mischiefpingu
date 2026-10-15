// test/models/lantern_settings_test.dart
//
// تست تنظیمات لنترن: ماندگاری فیلدها در JSON، نرمال‌سازی مقادیر نامعتبر
// و منبع لاگ Lantern در لیست پیش‌فرض.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';

void main() {
  test('lantern fields survive a json round-trip', () {
    final s = AppSettings()
      ..lanternSocksPort = 21071
      ..lanternHttpPort = 21070
      ..lanternUpstreamType = 4
      ..lanternProxyType = 'socks5h'
      ..lanternProxyIp = '10.0.0.2'
      ..lanternProxyPort = 2080
      ..lanternProxyUser = 'u'
      ..lanternProxyPass = 'p';

    final back = AppSettings.fromJson(
      Map<String, dynamic>.from(s.toJson() as Map),
    );

    expect(back.lanternSocksPort, 21071);
    expect(back.lanternHttpPort, 21070);
    expect(back.lanternUpstreamType, 4);
    expect(back.lanternProxyType, 'socks5h');
    expect(back.lanternProxyIp, '10.0.0.2');
    expect(back.lanternProxyPort, 2080);
    expect(back.lanternProxyUser, 'u');
    expect(back.lanternProxyPass, 'p');
  });

  test('lantern defaults match the CLI defaults', () {
    final s = AppSettings();
    expect(s.lanternSocksPort, 18071);
    expect(s.lanternHttpPort, 18070);
    expect(s.lanternUpstreamType, 0);
    expect(s.lanternProxyType, 'socks5');
  });

  test('validation normalizes invalid lantern values', () {
    final s = AppSettings()
      ..lanternSocksPort = 0
      ..lanternHttpPort = 70000
      ..lanternUpstreamType = 2 // Aether حذف‌شده
      ..lanternProxyType = 'ftp'
      ..lanternProxyIp = '  10.0.0.9  '
      ..lanternProxyPort = 99999;

    SettingsValidation.validateAndNormalize(s);

    expect(s.lanternSocksPort, 18071);
    expect(s.lanternHttpPort, 18070);
    expect(s.lanternUpstreamType, 0);
    expect(s.lanternProxyType, 'socks5');
    expect(s.lanternProxyIp, '10.0.0.9');
    expect(s.lanternProxyPort, 1080);
  });

  test('HTTP port 0 is allowed (listener disabled)', () {
    final s = AppSettings()..lanternHttpPort = 0;
    SettingsValidation.validateAndNormalize(s);
    expect(s.lanternHttpPort, 0);
  });

  test('Lantern is a valid log source and part of the defaults', () {
    final s = AppSettings();
    expect(s.enabledLogSources, contains('Lantern'));

    // یک لیست قدیمی بدون Lantern باید معتبر بماند.
    final old = AppSettings()
      ..enabledLogSources = ['Psiphon', 'Tor', 'SSTP', 'WireGuard', 'App', 'System'];
    SettingsValidation.validateAndNormalize(old);
    expect(old.enabledLogSources, contains('Psiphon'));

    // نامعتبرها حذف می‌شوند.
    final dirty = AppSettings()
      ..enabledLogSources = ['Lantern', 'NotASource'];
    SettingsValidation.validateAndNormalize(dirty);
    expect(dirty.enabledLogSources, ['Lantern']);
  });
}
