library;

import 'vpngate_country_extractor.dart';
import 'vpngate_row_parser.dart';
import '../vpngate_scraper_service.dart';

class VpngateFullPageParser {
  VpngateFullPageParser._();

  static final _sstpRegex = RegExp(
    r'SSTP\s+Hostname\s*:[\s\S]{0,120}?'
    r'([a-zA-Z0-9][a-zA-Z0-9\.\-]{2,60}\.opengw\.net)'
    r'(?::(\d{2,5}))?',
    caseSensitive: false,
  );

  static final _ipRegex = RegExp(r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b');

  static List<SstpServer> parse(String html) {
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
        if (VpngateRowParser.isValidIp(candidate)) {
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
}
