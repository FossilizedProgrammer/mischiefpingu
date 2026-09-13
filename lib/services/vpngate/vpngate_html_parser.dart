// lib/services/vpngate/vpngate_html_parser.dart
library;

import 'vpngate_country_extractor.dart';
import '../vpngate_scraper_service.dart';

class VpngateHtmlParser {
  final void Function(String message, {String source}) log;
  VpngateHtmlParser({required this.log});

  static final _tableRegex = RegExp(
    r'''<table[^>]*id\s*=\s*["']vg_hosts_table_id["'][^>]*>([\s\S]*?)</table>''',
    caseSensitive: false,
  );

  static final _rowRegex =
      RegExp(r'<tr[^>]*>([\s\S]*?)</tr>', caseSensitive: false);

  static final _sstpRegex = RegExp(
    r'SSTP\s+Hostname\s*:[\s\S]{0,120}?'
    r'([a-zA-Z0-9][a-zA-Z0-9\.\-]{2,60}\.opengw\.net)'
    r'(?::(\d{2,5}))?',
    caseSensitive: false,
  );

  static final _ipRegex =
      RegExp(r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b');

  List<SstpServer> parse(String html) {
    final servers = <SstpServer>[];
    final seen = <String>{};

    log('→ HTML length: ${html.length}', source: 'Vpngate');

    final tables = _tableRegex.allMatches(html).toList();
    log('→ Found ${tables.length} tables with id=vg_hosts_table_id',
        source: 'Vpngate');

    if (tables.isEmpty) {
      log('→ No table found, using full page fallback', source: 'Vpngate');
      return _parseFromFullPage(html);
    }

    final targetTable = tables.length >= 3 ? tables[2] : tables.last;
    final tableHtml = targetTable.group(1) ?? '';

    log('→ Using table #${tables.length >= 3 ? 3 : tables.length}',
        source: 'Vpngate');

    final rows = _rowRegex.allMatches(tableHtml).toList();
    log('→ Found ${rows.length} rows', source: 'Vpngate');

    for (final rowMatch in rows) {
      final row = rowMatch.group(1) ?? '';
      final lowerRow = row.toLowerCase();

      if (lowerRow.contains('country') &&
          lowerRow.contains('physical location')) {
        continue;
      }
      if (!lowerRow.contains('sstp hostname')) continue;

      final sstpMatch = _sstpRegex.firstMatch(row);
      if (sstpMatch == null) continue;

      final host = sstpMatch.group(1)?.trim() ?? '';
      if (host.isEmpty) continue;

      int port = 443;
      if (sstpMatch.group(2) != null) {
        final p = int.tryParse(sstpMatch.group(2)!);
        if (p != null && p >= 1 && p <= 65535) port = p;
      }

      final ipMatch = _ipRegex.firstMatch(row);
      if (ipMatch == null) continue;
      final ip = ipMatch.group(1)!;
      if (!_isValidIp(ip)) continue;

      final countryInfo = VpngateCountryExtractor.extract(row);

      int ping = 0;
      final pingMatch =
          RegExp(r'(\d+)\s*ms', caseSensitive: false).firstMatch(row);
      if (pingMatch != null) ping = int.tryParse(pingMatch.group(1)!) ?? 0;

      int speed = 0;
      final speedMatch =
          RegExp(r'([\d.,]+)\s*Mbps', caseSensitive: false).firstMatch(row);
      if (speedMatch != null) {
        final s = speedMatch.group(1)!.replaceAll(',', '');
        speed = (double.tryParse(s) ?? 0).round();
      }

      String operator = '';
      final opMatch =
          RegExp(r'\*By\s+([^<*\n]{2,50})', caseSensitive: false)
              .firstMatch(row);
      if (opMatch != null) operator = opMatch.group(1)!.trim();

      final key = '$ip:$port';
      if (seen.add(key)) {
        servers.add(SstpServer(
          ip: ip,
          port: port,
          country: countryInfo.name,
          countryShort: countryInfo.code,
          ping: ping,
          speed: speed,
          operator: operator,
        ));
      }
    }

    if (servers.isEmpty) {
      log('→ Table returned 0 — trying full page', source: 'Vpngate');
      return _parseFromFullPage(html);
    }

    final non443 = servers.where((s) => s.port != 443).length;
    log('→ Non-443 ports found: $non443', source: 'Vpngate');

    return servers;
  }

  List<SstpServer> _parseFromFullPage(String html) {
    final servers = <SstpServer>[];
    final seen = <String>{};

    for (final m in _sstpRegex.allMatches(html)) {
      final host = (m.group(1) ?? '').trim();
      if (host.isEmpty) continue;

      int port = 443;
      if (m.group(2) != null) {
        final p = int.tryParse(m.group(2)!);
        if (p != null && p >= 1 && p <= 65535) port = p;
      }

      final start = (m.start - 2000).clamp(0, html.length);
      final context = html.substring(start, m.end + 80);

      final ipMatches = _ipRegex.allMatches(context).toList();
      if (ipMatches.isEmpty) continue;

      String? ip;
      for (var i = ipMatches.length - 1; i >= 0; i--) {
        final candidate = ipMatches[i].group(1)!;
        if (_isValidIp(candidate)) {
          ip = candidate;
          break;
        }
      }
      if (ip == null) continue;

      final key = '$ip:$port';
      if (seen.add(key)) {
        final countryInfo = VpngateCountryExtractor.extract(context);
        servers.add(SstpServer(
          ip: ip,
          port: port,
          country: countryInfo.name,
          countryShort: countryInfo.code,
          ping: 0,
          speed: 0,
          operator: '',
        ));
      }
    }
    return servers;
  }

  bool _isValidIp(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
