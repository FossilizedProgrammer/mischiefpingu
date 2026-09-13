library;

import '../models/settings_model.dart';
import 'process_service.dart';
import 'tor_bridges.dart';

class TorConfigBuilder {
  final AppSettings settings;
  final ProcessService processService;
  TorConfigBuilder({required this.settings, required this.processService});

  /// Result of [build]: torrc text + env overrides for the Tor process.
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
    final bridges = TorBridges.parseBridges(
      settings.torTransport == 'bridge' ||
              settings.torTransport == 'aether' ||
              settings.torTransport == 'psiphon' ||
              settings.torTransport == 'sstp'
          ? settings.torBridges
          : '',
    );
    // 'direct' mode never uses bridges even if text is present.
    final effectiveBridges =
        settings.torTransport == 'direct' ? <String>[] : bridges;

    // Determine which upstream proxy to use (if any)
    final useAether = settings.torTransport == 'aether' && aetherSocks != null;
    final usePsiphon =
        settings.torTransport == 'psiphon' && psiphonSocks != null;
    final useSstp = settings.torTransport == 'sstp' && sstpSocks != null;

    final sb = StringBuffer();
    sb.writeln('SocksPort 127.0.0.1:$socksPort');

    // ─── Upstream SOCKS proxy configuration ───
    // For direct Tor with no bridges: use Socks5Proxy
    // For Tor with bridges: use TOR_PT_PROXY env (pluggable transports)
    int? upstreamSocks;
    if (useAether) {
      upstreamSocks = aetherSocks;
    } else if (usePsiphon) {
      upstreamSocks = psiphonSocks;
    } else if (useSstp) {
      upstreamSocks = sstpSocks;
    }

    if (upstreamSocks != null && effectiveBridges.isEmpty) {
      sb.writeln('Socks5Proxy 127.0.0.1:$upstreamSocks');
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
    if (effectiveBridges.isNotEmpty) {
      sb.writeln('UseBridges 1');
      final pt = lyrebirdPath ?? 'lyrebird';
      sb.writeln(
          'ClientTransportPlugin obfs4,meek_lite,webtunnel,scramblesuit,snowflake exec ${_p(pt)}');
      if (conjurePath != null && conjurePath.isNotEmpty) {
        sb.writeln('ClientTransportPlugin conjure exec ${_p(conjurePath)}');
      }
      for (final b in effectiveBridges) {
        sb.writeln('Bridge $b');
      }
    }
    Map<String, String>? env;
    if (upstreamSocks != null) {
      // Pluggable transports honour TOR_PT_PROXY; direct Tor uses Socks5Proxy.
      env = {'TOR_PT_PROXY': 'socks5://127.0.0.1:$upstreamSocks'};
    }
    final torrc = sb.toString();
    processService.addLog(
      '→ Tor torrc generated (${torrc.length} bytes, transport=${settings.torTransport}, bridges=${effectiveBridges.length}${upstreamSocks != null ? ', upstream socks5:127.0.0.1:$upstreamSocks' : ''})',
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
