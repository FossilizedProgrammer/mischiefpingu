library;

import '../../models/settings_model.dart';

class AetherArgsBuilder {
  final AppSettings settings;
  const AetherArgsBuilder(this.settings);

  List<String> build({
    required String protocol,
    required String masqueOption,
    required int port,
    String endpointOverride = '',
    bool forceFragmentH2 = false,
  }) {
    final bindHost = settings.aetherShareLan ? '0.0.0.0' : '127.0.0.1';

    final protocolFlags = <String>[];
    switch (protocol) {
      case 'masque':
        protocolFlags.add('--masque');
        break;
      case 'wireguard':
        protocolFlags.add('--wg');
        break;
      case 'gool':
        protocolFlags.add('--gool');
        break;
      case 'mim':
        protocolFlags.add('--mim');
        break;
    }

    final isMasqueFamily = protocol == 'masque' || protocol == 'mim';
    final isH2 = isMasqueFamily && masqueOption == 'HTTP-2';
    final fragmentActive = isH2 && forceFragmentH2;

    final args = <String>[
      '--bind',
      '$bindHost:$port',
      ...protocolFlags,
      if (settings.ipType == 'ipv4') '-4',
      if (settings.ipType == 'ipv6') '-6',
      if (settings.ipType == 'both') '--dual',
      if (isH2) '--h2',
      if (fragmentActive) '--fragment',
      if (settings.obfuscation != 'off') ...['--noize', settings.obfuscation],
      if (settings.aetherQuickReconnect)
        '--quick-reconnect'
      else
        '--no-quick-reconnect',
    ];

    final endpoint = endpointOverride.isNotEmpty
        ? endpointOverride
        : settings.aetherCustomEndpoint.trim();

    if (endpoint.isNotEmpty) {
      switch (protocol) {
        case 'gool':
          args.addAll(['--wiw-outer', endpoint]);
          break;
        case 'mim':
          args.addAll(['--mim-outer', endpoint]);
          break;
        default:
          args.addAll(['--peer', endpoint]);
          break;
      }
    } else {
      args.addAll(['--scan', settings.aetherScanMode]);
    }

    return args;
  }
}
