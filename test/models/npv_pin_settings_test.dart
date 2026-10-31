// test/models/npv_pin_settings_test.dart
//
// پین کانفیگ NPV باید بعد از ری‌استارت برنامه سرِ جایش بماند و اگر
// مقدارش خراب بود (دست‌نویس، عدد منفی، فایلِ دیگری) به حالت خودکار
// برگردد، نه اینکه `-s` بی‌معنی به هسته پاس داده شود.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/models/settings_validation.dart';

void main() {
  test('auto mode is the default', () {
    final s = AppSettings();
    expect(s.npvPinnedIndex, '');
    expect(s.npvPinnedRemark, '');
  });

  test('the pin survives a save/load round trip', () {
    final s = AppSettings()
      ..npvPinnedIndex = '12'
      ..npvPinnedRemark = 'paris-2';
    final back = AppSettings.fromJson(s.toJson());
    expect(back.npvPinnedIndex, '12');
    expect(back.npvPinnedRemark, 'paris-2');
  });

  test('a number is trimmed, not rejected', () {
    final s = AppSettings()
      ..npvPinnedIndex = ' 12 '
      ..npvPinnedRemark = ' paris-2 ';
    SettingsValidation.validateAndNormalize(s);
    expect(s.npvPinnedIndex, '12');
    expect(s.npvPinnedRemark, 'paris-2');
  });

  test('a pin that is not a config number falls back to auto', () {
    for (final bad in ['abc', '', '-3', '0', '1.5']) {
      final s = AppSettings()
        ..npvPinnedIndex = bad
        ..npvPinnedRemark = 'paris-2';
      SettingsValidation.validateAndNormalize(s);
      expect(s.npvPinnedIndex, '', reason: 'bad pin "$bad" must clear');
      expect(s.npvPinnedRemark, '', reason: 'bad pin "$bad" must clear');
    }
  });
}
