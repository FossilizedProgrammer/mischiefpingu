library;

import 'dart:io';

import 'vpngate/vpngate_fetcher.dart';
import 'vpngate/vpngate_html_parser.dart';

class SstpServer {
  final String ip;
  final int port;
  final String country;
  final String countryShort;
  final int ping;
  final int speed;
  final String operator;

  const SstpServer({
    required this.ip,
    required this.port,
    required this.country,
    required this.countryShort,
    required this.ping,
    required this.speed,
    required this.operator,
  });

  String get key => '$ip:$port';

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'port': port,
    'country': country,
    'countryShort': countryShort,
    'ping': ping,
    'speed': speed,
    'operator': operator,
  };

  factory SstpServer.fromJson(Map<String, dynamic> j) => SstpServer(
    ip: j['ip'] as String? ?? '',
    port: j['port'] as int? ?? 443,
    country: j['country'] as String? ?? '',
    countryShort: j['countryShort'] as String? ?? '',
    ping: j['ping'] as int? ?? 0,
    speed: j['speed'] as int? ?? 0,
    operator: j['operator'] as String? ?? '',
  );

  @override
  String toString() => '$ip:$port ($country)';
}

class VpngateScrapeResult {
  final List<SstpServer> servers;
  final String rawHtmlLength;
  final String message;
  final bool ok;

  const VpngateScrapeResult({
    required this.servers,
    required this.rawHtmlLength,
    required this.message,
    required this.ok,
  });
}

class VpngateScraperService {
  final void Function(String message, {String source}) log;

  late final VpngateFetcher _fetcher = VpngateFetcher(log: log);
  late final VpngateHtmlParser _parser = VpngateHtmlParser(log: log);

  VpngateScraperService({required this.log});

  static const String _htmlUrl = 'https://www.vpngate.net/en/';
  static const bool _debugSaveHtml = false;

  Future<VpngateScrapeResult> fetchAndParse({String? proxy}) async {
    log(
      '→ Fetching vpngate.net${proxy != null ? ' via $proxy' : ' (direct)'}',
      source: 'Vpngate',
    );

    final html = await _fetcher.fetch(_htmlUrl, proxy: proxy);
    if (html == null || html.isEmpty) {
      return const VpngateScrapeResult(
        servers: [],
        rawHtmlLength: '0',
        message: 'Failed to fetch page',
        ok: false,
      );
    }

    if (_debugSaveHtml) {
      try {
        await File('/tmp/vpngate_debug.html').writeAsString(html);
        log('→ Debug HTML saved', source: 'Vpngate');
      } catch (_) {}
    }

    final servers = _parser.parse(html);
    log('→ Parsed ${servers.length} SSTP server(s)', source: 'Vpngate');

    return VpngateScrapeResult(
      servers: servers,
      rawHtmlLength: html.length.toString(),
      message: servers.isEmpty
          ? 'No SSTP servers found'
          : 'Found ${servers.length} SSTP server(s)',
      ok: servers.isNotEmpty,
    );
  }
}
