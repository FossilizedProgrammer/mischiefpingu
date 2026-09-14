// lib/services/vpngate/vpngate_row_parser.dart
//
// ═══════════════════════════════════════════════════════════════
//  VpngateRowParser — پارس یک ردیف جدول به SstpServer
//  (تفکیک شده از vpngate_html_parser.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'vpngate_country_extractor.dart';
import '../vpngate_scraper_service.dart';

class VpngateRowParser {
  VpngateRowParser._();

  static final _sstpRegex = RegExp(
    r'SSTP\s+Hostname\s*:[\s\S]{0,120}?'
    r'([a-zA-Z0-9][a-zA-Z0-9\.\-]{2,60}\.opengw\.net)'
    r'(?::(\d{2,5}))?',
    caseSensitive: false,
  );

  static final _ipRegex =
      RegExp(r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b');

  /// پارس یک ردیف جدول. null اگر ردیف نامعتبر باشد.
  static SstpServer? parse(String row) {
    final lowerRow = row.toLowerCase();

    // رد کردن ردیف header
    if (lowerRow.contains('country') &&
        lowerRow.contains('physical location')) {
      return null;
    }
    if (!lowerRow.contains('sstp hostname')) return null;

    final sstpMatch = _sstpRegex.firstMatch(row);
    if (sstpMatch == null) return null;

    final host = sstpMatch.group(1)?.trim() ?? '';
    if (host.isEmpty) return null;

    int port = 443;
    if (sstpMatch.group(2) != null) {
      final p = int.tryParse(sstpMatch.group(2)!);
      if (p != null && p >= 1 && p <= 65535) port = p;
    }

    final ipMatch = _ipRegex.firstMatch(row);
    if (ipMatch == null) return null;
    final ip = ipMatch.group(1)!;
    if (!isValidIp(ip)) return null;

    final countryInfo = VpngateCountryExtractor.extract(row);

    return SstpServer(
      ip: ip,
      port: port,
      country: countryInfo.name,
      countryShort: countryInfo.code,
      ping: _parsePing(row),
      speed: _parseSpeed(row),
      operator: _parseOperator(row),
    );
  }

  static int _parsePing(String row) {
    final m = RegExp(r'(\d+)\s*ms', caseSensitive: false).firstMatch(row);
    return m != null ? (int.tryParse(m.group(1)!) ?? 0) : 0;
  }

  static int _parseSpeed(String row) {
    final m =
        RegExp(r'([\d.,]+)\s*Mbps', caseSensitive: false).firstMatch(row);
    if (m == null) return 0;
    final s = m.group(1)!.replaceAll(',', '');
    return (double.tryParse(s) ?? 0).round();
  }

  static String _parseOperator(String row) {
    final m = RegExp(r'\*By\s+([^<*\n]{2,50})', caseSensitive: false)
        .firstMatch(row);
    return m != null ? m.group(1)!.trim() : '';
  }

  static bool isValidIp(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
