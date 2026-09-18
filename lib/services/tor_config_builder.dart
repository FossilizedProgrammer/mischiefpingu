library;

import '../models/settings_model.dart';
import 'process_service.dart';
import 'tor_bridges.dart';
import 'tor/tor_bridge_resolver.dart';

class TorConfigBuilder {
  final AppSettings settings;
  final ProcessService processService;
  TorConfigBuilder({required this.settings, required this.processService});

  TorConfigResult build({
    required int socksPort,
    required int httpPort,
    required String torDataDir,
    String? geoipPath,
    String? geoip6Path,
    String? lyrebirdPath,
    String? conjurePath,
    int? aetherSocks,
    int? psiphonSocks,
    int? sstpSocks,
  }) {
    final decision = TorBridgeResolver.resolve(
      settings: settings,
      aetherSocks: aetherSocks,
      psiphonSocks: psiphonSocks,
      sstpSocks: sstpSocks,
    );

    final sb = StringBuffer();
    sb.writeln('SocksPort 127.0.0.1:$socksPort');

    if (decision.upstreamSocks != null && decision.bridges.isEmpty) {
      sb.writeln('Socks5Proxy 127.0.0.1:${decision.upstreamSocks}');
    }

    sb.writeln('HTTPTunnelPort 127.0.0.1:$httpPort');
    sb.writeln('DataDirectory ${_p(torDataDir)}');
    if (geoipPath != null && geoipPath.isNotEmpty) {
      sb.writeln('GeoIPFile ${_p(geoipPath)}');
    }
    if (geoip6Path != null && geoip6Path.isNotEmpty) {
      sb.writeln('GeoIPv6File ${_p(geoip6Path)}');
    }
    sb.writeln('Log notice stdout');
    sb.writeln('ClientOnly 1');
    sb.writeln('AvoidDiskWrites 1');

    final exit = TorBridges.normalizeExitCountry(settings.torExitCountry);
    if (exit.length == 2) {
      sb.writeln('ExitNodes {$exit}');
      sb.writeln('StrictNodes 1');
      sb.writeln('MaxCircuitDirtiness 60');
    }

    if (decision.bridges.isNotEmpty) {
      sb.writeln('UseBridges 1');
      final pt = lyrebirdPath ?? 'lyrebird';
      sb.writeln(
        'ClientTransportPlugin obfs4,meek_lite,webtunnel,scramblesuit,snowflake exec ${_p(pt)}',
      );
      if (conjurePath != null && conjurePath.isNotEmpty) {
        sb.writeln('ClientTransportPlugin conjure exec ${_p(conjurePath)}');
      }
      for (final b in decision.bridges) {
        sb.writeln('Bridge $b');
      }
    }

    Map<String, String>? env;
    if (decision.upstreamSocks != null) {
      env = {'TOR_PT_PROXY': 'socks5://127.0.0.1:${decision.upstreamSocks}'};
    }

    final torrc = sb.toString();
    processService.addLog(
      '→ Tor torrc generated (${torrc.length} bytes, '
      'transport=${settings.torTransport}, '
      'bridges=${decision.bridges.length}'
      '${decision.upstreamSocks != null ? ', upstream socks5:127.0.0.1:${decision.upstreamSocks}' : ''})',
      source: LogSource.tor,
    );
    return TorConfigResult(torrc: torrc, env: env);
  }

  static String _p(String path) => path.replaceAll('\\', '/');
}

class TorConfigResult {
  final String torrc;
  final Map<String, String>? env;
  const TorConfigResult({required this.torrc, this.env});
}
