library;

import 'vpngate_full_page_parser.dart';
import 'vpngate_row_parser.dart';
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

  List<SstpServer> parse(String html) {
    log('→ HTML length: ${html.length}', source: 'Vpngate');

    final tables = _tableRegex.allMatches(html).toList();
    log('→ Found ${tables.length} tables with id=vg_hosts_table_id',
        source: 'Vpngate');

    if (tables.isEmpty) {
      log('→ No table found, using full page fallback', source: 'Vpngate');
      return VpngateFullPageParser.parse(html);
    }

    final targetTable = tables.length >= 3 ? tables[2] : tables.last;
    final tableHtml = targetTable.group(1) ?? '';

    log('→ Using table #${tables.length >= 3 ? 3 : tables.length}',
        source: 'Vpngate');

    final rows = _rowRegex.allMatches(tableHtml).toList();
    log('→ Found ${rows.length} rows', source: 'Vpngate');

    final servers = <SstpServer>[];
    final seen = <String>{};

    for (final rowMatch in rows) {
      final row = rowMatch.group(1) ?? '';
      final server = VpngateRowParser.parse(row);
      if (server == null) continue;
      if (seen.add(server.key)) servers.add(server);
    }

    if (servers.isEmpty) {
      log('→ Table returned 0 — trying full page', source: 'Vpngate');
      return VpngateFullPageParser.parse(html);
    }

    final non443 = servers.where((s) => s.port != 443).length;
    log('→ Non-443 ports found: $non443', source: 'Vpngate');

    return servers;
  }
}
