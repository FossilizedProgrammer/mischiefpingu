// lib/services/aether_attempts.dart
library;

import '../models/settings_model.dart';

/// One way to bring Aether up (protocol + masque + optional endpoint).
class EndpointAttempt {
  final String label;
  final String protocol;
  final String masque;
  final String endpoint;

  EndpointAttempt({
    required this.label,
    required this.protocol,
    required this.masque,
    required this.endpoint,
  });
}

/// Builds the ordered candidate/argument lists for the auto-test.
class AetherAttemptPlanner {
  final AppSettings settings;
  AetherAttemptPlanner(this.settings);

  List<EndpointAttempt> buildCandidates({
    MapEntry<String, String>? autoWinner,
  }) {
    final list = <EndpointAttempt>[];
    final seen = <String>{};

    void add(EndpointAttempt a) {
      final key = '${a.protocol}|${a.masque}|${a.endpoint}';
      if (seen.add(key)) list.add(a);
    }

    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isNotEmpty) {
      final proto = resolveProtocolForEndpoint(
        settings.aetherProtocol,
        custom,
      );
      final masque = (proto == 'masque') ? settings.masqueOption : '';
      add(EndpointAttempt(
        label: 'Custom Endpoint ($custom)',
        protocol: proto,
        masque: masque,
        endpoint: custom,
      ));
      return list;
    }

    if (settings.aetherTryLastEndpointFirst && autoWinner != null) {
      add(EndpointAttempt(
        label: 'Last remembered (${autoWinner.key})',
        protocol: autoWinner.key,
        masque: autoWinner.value,
        endpoint: '',
      ));
    }

    if (settings.aetherProtocol != 'auto') {
      add(EndpointAttempt(
        label: settings.aetherProtocol.toUpperCase(),
        protocol: settings.aetherProtocol,
        masque:
            settings.aetherProtocol == 'masque' ? settings.masqueOption : '',
        endpoint: '',
      ));
    } else {
      add(EndpointAttempt(
        label: 'MASQUE/HTTP-3',
        protocol: 'masque',
        masque: 'HTTP-3',
        endpoint: '',
      ));
      add(EndpointAttempt(
        label: 'MASQUE/HTTP-2',
        protocol: 'masque',
        masque: 'HTTP-2',
        endpoint: '',
      ));
      add(EndpointAttempt(
        label: 'WIREGUARD',
        protocol: 'wireguard',
        masque: '',
        endpoint: '',
      ));
      add(EndpointAttempt(
        label: 'GOOL (WARP-in-WARP)',
        protocol: 'gool',
        masque: '',
        endpoint: '',
      ));
    }

    return list;
  }

  String resolveProtocolForEndpoint(String userChoice, String endpoint) {
    if (userChoice != 'auto') return userChoice;
    return 'masque';
  }

  List<String> argsFor({
    required String protocol,
    required String masqueOption,
    required int port,
    String endpointOverride = '',
  }) {
    // Aether binds natively: 0.0.0.0 for LAN share, 127.0.0.1 otherwise.
    // Unlike Psiphon/Tor, it does not need a Dart TCP forwarder.
    final bindHost = settings.aetherShareLan ? '0.0.0.0' : '127.0.0.1';
    final args = <String>[
      '--bind',
      '$bindHost:$port',
      if (protocol == 'wireguard') '--wg',
      if (protocol == 'gool') '--gool',
      if (protocol == 'masque') '--masque',
      if (settings.ipType == 'ipv4') '-4',
      if (settings.ipType == 'ipv6') '-6',
      if (settings.ipType == 'both') '--dual',
      if (protocol == 'masque' && masqueOption == 'HTTP-2') '--h2',
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
      if (protocol == 'gool') {
        args.addAll(['--wiw-outer', endpoint]);
      } else {
        args.addAll(['--peer', endpoint]);
      }
    } else {
      args.addAll(['--scan', settings.aetherScanMode]);
    }

    return args;
  }
}
