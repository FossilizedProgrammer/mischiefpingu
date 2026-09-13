library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import 'aether/aether_config_parser.dart';

/// Persists and reads Aether's last-known-good transport/endpoint
/// (SharedPreferences + aether config files on disk).
class AetherEndpointStore {
  final AppSettings settings;
  final void Function(String) log;

  AetherEndpointStore({required this.settings, required this.log});

  static const String _autoTransportKey = 'aetherAutoTransport';
  static const String _lastEndpointKey = 'aetherLastSuccessfulEndpoint';
  static const String _lastProtocolKey = 'aetherLastProtocol';
  static const String _lastMasqueKey = 'aetherLastMasque';

  /// Last successful endpoint: SharedPreferences first, config file second.
  Future<String?> getLastSuccessfulEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_lastEndpointKey);
      if (saved != null && saved.isNotEmpty) return saved;
    } catch (_) {}

    final proto =
        settings.aetherProtocol == 'auto' ? 'masque' : settings.aetherProtocol;
    return AetherConfigParser.extractEndpoint(proto);
  }

  // ═══════════════════════════════════════════
  //  بارگذاری «برندهٔ قبلی auto» از SharedPreferences
  // ═══════════════════════════════════════════
  Future<MapEntry<String, String>?> loadAutoWinner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_autoTransportKey);
      if (s == null) return null;
      if (s.startsWith('masque:')) {
        return MapEntry('masque', s.split(':').last);
      }
      if (s == 'wireguard') return const MapEntry('wireguard', '');
      if (s == 'gool') return const MapEntry('gool', '');
    } catch (_) {}
    return null;
  }

  // ═══════════════════════════════════════════
  //  ذخیرهٔ وضعیت موفق (endpoint + پروتکل)
  // ═══════════════════════════════════════════
  Future<void> saveSuccessState({
    required String protocol,
    required String masque,
    required String endpoint,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _autoTransportKey,
        protocol == 'masque' ? 'masque:$masque' : protocol,
      );
      log(
        '★ Auto: remembered working transport → '
        '${_transportLabel(protocol, masque)}',
      );

      if (endpoint.isNotEmpty) {
        await prefs.setString(_lastEndpointKey, endpoint);
        await prefs.setString(_lastProtocolKey, protocol);
        await prefs.setString(_lastMasqueKey, masque);
        log('★ Saved last endpoint: $endpoint');
      } else {
        final found = await AetherConfigParser.extractEndpoint(protocol);
        if (found != null && found.isNotEmpty) {
          await prefs.setString(_lastEndpointKey, found);
          await prefs.setString(_lastProtocolKey, protocol);
          await prefs.setString(_lastMasqueKey, masque);
          log('★ Saved last endpoint from config: $found');
        }
      }
    } catch (_) {}
  }

  static String _transportLabel(String proto, String masque) =>
      proto == 'masque' ? 'MASQUE/$masque' : proto.toUpperCase();
}
