// test/models/ffvpn_settings_test.dart
//
// تست تنظیمات Firefox VPN: ماندگاری فیلتر نمایش کشورها در JSON، نرمال‌سازی
// مقدار نامعتبر و مهاجرت از بولین قدیمی `ffvpnShowPremiumCountries`.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';

void main() {
  test('the country filter survives a json round-trip', () {
    final s = AppSettings()..ffvpnCountryFilter = 'plus';

    final back = AppSettings.fromJson(
      Map<String, dynamic>.from(s.toJson() as Map),
    );

    expect(back.ffvpnCountryFilter, 'plus');
  });

  test('the default filter hides premium countries like Firefox', () {
    final s = AppSettings();
    expect(s.ffvpnCountryFilter, 'free');
  });

  test('validation normalizes an invalid country filter', () {
    final s = AppSettings()..ffvpnCountryFilter = 'nonsense';
    SettingsValidation.validateAndNormalize(s);
    expect(s.ffvpnCountryFilter, 'free');
  });

  test('each valid filter value is kept as-is', () {
    for (final v in <String>['all', 'free', 'plus']) {
      final s = AppSettings()..ffvpnCountryFilter = v;
      SettingsValidation.validateAndNormalize(s);
      expect(s.ffvpnCountryFilter, v, reason: 'input $v');
    }
  });

  test('a settings map without the key falls back to the default', () {
    final back = AppSettings.fromJson(<String, dynamic>{'ffvpnHttpPort': 8083});
    expect(back.ffvpnCountryFilter, 'free');
  });

  test('the legacy premium switch migrates to the filter', () {
    // کاربر قدیمی که کلید «نمایش کشورهای پرمیوم» را روشن کرده بود.
    final on = AppSettings.fromJson(<String, dynamic>{
      'ffvpnShowPremiumCountries': true,
    });
    expect(on.ffvpnCountryFilter, 'all');

    // و کسی که خاموش گذاشته بود → فقط رایگان (رفتار قبلی حفظ می‌شود).
    final off = AppSettings.fromJson(<String, dynamic>{
      'ffvpnShowPremiumCountries': false,
    });
    expect(off.ffvpnCountryFilter, 'free');
  });

  test('an explicit filter wins over the legacy switch', () {
    final back = AppSettings.fromJson(<String, dynamic>{
      'ffvpnShowPremiumCountries': false,
      'ffvpnCountryFilter': 'plus',
    });
    expect(back.ffvpnCountryFilter, 'plus');
  });

  test('the legacy switch is no longer written back', () {
    final json = AppSettings().toJson() as Map;
    expect(json.containsKey('ffvpnShowPremiumCountries'), isFalse);
    expect(json['ffvpnCountryFilter'], 'free');
  });
}
