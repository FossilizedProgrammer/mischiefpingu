library;

import '../models/settings_model.dart';
import 'aether/aether_args_builder.dart';

class EndpointAttempt {
  final String label;
  final String protocol;
  final String masque;
  final String endpoint;
  final bool fragmentH2;

  EndpointAttempt({
    required this.label,
    required this.protocol,
    required this.masque,
    required this.endpoint,
    this.fragmentH2 = false,
  });
}

class AetherAttemptPlanner {
  final AppSettings settings;
  late final AetherArgsBuilder _argsBuilder = AetherArgsBuilder(settings);

  AetherAttemptPlanner(this.settings);

  static String _labelFor(ProfileCandidate c) {
    switch (c.protocol) {
      case 'masque':
        return 'MASQUE/${c.masque}${c.fragmentH2 ? "+fragment" : ""}';
      case 'mim':
        return 'MIM/${c.masque}${c.fragmentH2 ? "+fragment" : ""}';
      case 'gool':
        return 'GOOL (WARP-in-WARP)';
      case 'wireguard':
        return 'WIREGUARD';
      default:
        return c.protocol.toUpperCase();
    }
  }

  List<EndpointAttempt> buildCandidates({
    MapEntry<String, String>? autoWinner,
  }) {
    final list = <EndpointAttempt>[];
    final seen = <String>{};

    void add(EndpointAttempt a) {
      final key = '${a.protocol}|${a.masque}|${a.endpoint}|${a.fragmentH2}';
      if (seen.add(key)) list.add(a);
    }

    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isNotEmpty) {
      final proto = resolveProtocolForEndpoint(
        settings.isAetherProfileAutomatic
            ? 'auto'
            : settings.aetherProtocol,
        custom,
      );
      final masque =
          (proto == 'masque' || proto == 'mim') ? settings.masqueOption : '';
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

    if (settings.isAetherProfileAutomatic) {
      final profile = settings.activeAetherProfile;
      final candidates = profile?.candidates ?? const <ProfileCandidate>[];

      if (candidates.isEmpty) {
        add(EndpointAttempt(
            label: 'MASQUE/HTTP-3',
            protocol: 'masque',
            masque: 'HTTP-3',
            endpoint: ''));
        add(EndpointAttempt(
            label: 'MASQUE/HTTP-2',
            protocol: 'masque',
            masque: 'HTTP-2',
            endpoint: ''));
        add(EndpointAttempt(
            label: 'WIREGUARD', protocol: 'wireguard', masque: '', endpoint: ''));
        add(EndpointAttempt(
            label: 'GOOL (WARP-in-WARP)',
            protocol: 'gool',
            masque: '',
            endpoint: ''));
        return list;
      }

      for (final c in candidates) {
        add(EndpointAttempt(
          label: _labelFor(c),
          protocol: c.protocol,
          masque: c.masque,
          endpoint: '',
          fragmentH2: c.fragmentH2,
        ));
      }
      return list;
    }

    final proto = settings.aetherProtocol;
    final masque =
        (proto == 'masque' || proto == 'mim') ? settings.masqueOption : '';
    final frag = settings.aetherProfile == 'strict' && masque == 'HTTP-2';
    add(EndpointAttempt(
      label: _labelFor(ProfileCandidate(
        protocol: proto,
        masque: masque,
        fragmentH2: frag,
      )),
      protocol: proto,
      masque: masque,
      endpoint: '',
      fragmentH2: frag,
    ));
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
    bool forceFragmentH2 = false,
  }) =>
      _argsBuilder.build(
        protocol: protocol,
        masqueOption: masqueOption,
        port: port,
        endpointOverride: endpointOverride,
        forceFragmentH2: forceFragmentH2,
      );
}
