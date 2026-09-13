// lib/services/vpngate/vpngate_country_extractor.dart
library;

import 'vpngate_country_maps.dart';

class VpngateCountryExtractor {
  VpngateCountryExtractor._();

  /// استخراج نام و کد کشور از HTML یک ردیف.
  static ({String name, String code}) extract(String row) {
    // روش ۱: پرچم با title
    final flagWithTitle = RegExp(
      r'<img[^>]*src="[^"]*flags/([a-z]{2})\.(?:gif|png|jpg)"[^>]*title="([^"]+)"',
      caseSensitive: false,
    ).firstMatch(row);

    if (flagWithTitle != null) {
      final code = flagWithTitle.group(1)!.toUpperCase();
      final name = flagWithTitle.group(2)!.trim();
      return (
        name: name.isNotEmpty ? name : VpngateCountryMaps.nameFromCode(code),
        code: code,
      );
    }

    // روش ۲: title قبل از src
    final titleFirst = RegExp(
      r'<img[^>]*title="([^"]+)"[^>]*src="[^"]*flags/([a-z]{2})\.(?:gif|png|jpg)"',
      caseSensitive: false,
    ).firstMatch(row);

    if (titleFirst != null) {
      final code = titleFirst.group(2)!.toUpperCase();
      final name = titleFirst.group(1)!.trim();
      return (
        name: name.isNotEmpty ? name : VpngateCountryMaps.nameFromCode(code),
        code: code,
      );
    }

    // روش ۳: فقط کد پرچم
    final flagCodeOnly = RegExp(
      r'src="[^"]*flags/([a-z]{2})\.(?:gif|png|jpg)"',
      caseSensitive: false,
    ).firstMatch(row);

    if (flagCodeOnly != null) {
      final code = flagCodeOnly.group(1)!.toUpperCase();
      return (name: VpngateCountryMaps.nameFromCode(code), code: code);
    }

    // روش ۴: alt
    final altMatch =
        RegExp(r'<img[^>]*alt="([^"]+)"', caseSensitive: false).firstMatch(row);
    if (altMatch != null) {
      final alt = altMatch.group(1)!.trim();
      if (alt.length == 2) {
        final code = alt.toUpperCase();
        return (name: VpngateCountryMaps.nameFromCode(code), code: code);
      }
      if (alt.length > 2) {
        return (name: alt, code: VpngateCountryMaps.codeFromName(alt));
      }
    }

    // روش ۵: نام کشور در متن
    final countryNameMatch =
        VpngateCountryMaps.countryNamePattern.firstMatch(row);
    if (countryNameMatch != null) {
      final name = countryNameMatch.group(1)!;
      return (name: name, code: VpngateCountryMaps.codeFromName(name));
    }

    return (name: '', code: '');
  }
}
