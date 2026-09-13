// lib/services/vpngate/vpngate_country_maps.dart
//
// ═══════════════════════════════════════════════════════════════
//  منطق نگاشت کد ↔ نام کشور — داده در vpngate_country_codes.dart
// ═══════════════════════════════════════════════════════════════
library;

import 'vpngate_country_codes.dart';

class VpngateCountryMaps {
  VpngateCountryMaps._();

  static String nameFromCode(String code) =>
      kCountryCodeToName[code.toUpperCase()] ?? code.toUpperCase();

  static String codeFromName(String name) {
    final lower = name.toLowerCase().trim();

    for (final e in kCountryCodeToName.entries) {
      if (e.value.toLowerCase() == lower) return e.key;
    }

    if (lower.contains('korea')) return 'KR';
    if (lower.contains('united states') || lower == 'usa') return 'US';
    if (lower.contains('united kingdom') || lower == 'uk') return 'GB';
    if (lower.contains('russian')) return 'RU';
    if (lower.contains('viet')) return 'VN';
    if (lower.contains('emirates') || lower.contains('uae')) return 'AE';
    if (lower.contains('taiwan')) return 'TW';
    if (lower.contains('hong kong')) return 'HK';
    if (lower.contains('czech')) return 'CZ';

    return '';
  }

  static final RegExp countryNamePattern = RegExp(
    r'\b(Japan|Korea Republic of|United States|Russian Federation|United Kingdom|'
    r'Germany|France|Netherlands|Canada|Australia|Hong Kong|Taiwan|Vietnam|'
    r'Thailand|Indonesia|Malaysia|Singapore|India|Brazil|Italy|Spain|'
    r'Poland|Ukraine|Romania|Turkey|Iran|Iraq|United Arab Emirates|'
    r'Argentina|Mexico|South Africa|Egypt|Pakistan|Sweden|Norway|'
    r'Finland|Denmark|Switzerland|Austria|Belgium|Portugal|Greece|'
    r'Czech Republic|Hungary|Slovakia|Bulgaria|Croatia|Serbia|'
    r'China|Philippines|Saudi Arabia|Israel|New Zealand)\b',
    caseSensitive: false,
  );
}
