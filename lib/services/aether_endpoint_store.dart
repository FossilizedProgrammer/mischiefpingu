library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import 'aether/aether_config_parser.dart';
import 'aether/util/endpoint_parser.dart';

/// Persists and reads Aether's last-known-good transport/endpoint
/// (SharedPreferences + aether config files on disk).
///
/// ⚠️ تغییرات مهم:
///   1. IPهای private به عنوان endpoint ذخیره نمی‌شوند.
///   2. اگر endpoint ذخیره‌شده fail شد، بلافاصله پاک می‌شود.
///   3. endpoint واقعی از خط `using cloudflare edge X.X.X.X:PORT`
///      در لاگ Aether استخراج می‌شود.
///
///  ⚠️ بازآرایی: منطق parse/isPrivate/isValidPublicEndpoint به
///  `EndpointParser` منتقل شد تا در چهار جای مختلف تکرار نشود.
class AetherEndpointStore {
  final AppSettings settings;
  final void Function(String) log;

  AetherEndpointStore({required this.settings, required this.log});

  static const String _autoTransportKey = 'aetherAutoTransport';
  static const String _lastEndpointKey = 'aetherLastSuccessfulEndpoint';
  static const String _lastProtocolKey = 'aetherLastProtocol';
  static const String _lastMasqueKey = 'aetherLastMasque';

  // ─── delegate به EndpointParser ───
  bool _isValidPublicEndpoint(String endpoint) =>
      EndpointParser.isValidPublicEndpoint(endpoint);

  /// Last successful endpoint: SharedPreferences first, config file second.
  Future<String?> getLastSuccessfulEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_lastEndpointKey);
      if (saved != null && saved.isNotEmpty) {
        if (_isValidPublicEndpoint(saved)) {
          return saved;
        }
        log('→ Discarding invalid saved endpoint: $saved');
        await prefs.remove(_lastEndpointKey);
      }
    } catch (_) {}

    final proto = settings.aetherProtocol == 'auto'
        ? 'masque'
        : settings.aetherProtocol;
    final fromConfig = await AetherConfigParser.extractEndpoint(proto);
    if (fromConfig != null &&
        fromConfig.isNotEmpty &&
        _isValidPublicEndpoint(fromConfig)) {
      return fromConfig;
    }
    return null;
  }

  /// پاک کردن endpoint ذخیره‌شده (مثلاً بعد از fail).
  Future<void> clearLastEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastEndpointKey);
      log('→ Cleared last saved endpoint (was invalid or failed)');
    } catch (_) {}
  }

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

      if (endpoint.isNotEmpty && _isValidPublicEndpoint(endpoint)) {
        await prefs.setString(_lastEndpointKey, endpoint);
        await prefs.setString(_lastProtocolKey, protocol);
        await prefs.setString(_lastMasqueKey, masque);
        log('★ Saved last endpoint: $endpoint');
      } else if (endpoint.isNotEmpty) {
        log(
          '⚠ Skipped saving private endpoint: $endpoint '
          '(likely internal WARP gateway, not a real endpoint)',
        );
        await _tryExtractAndSaveFromConfig(prefs, protocol, masque);
      } else {
        await _tryExtractAndSaveFromConfig(prefs, protocol, masque);
      }
    } catch (_) {}
  }

  Future<void> _tryExtractAndSaveFromConfig(
    SharedPreferences prefs,
    String protocol,
    String masque,
  ) async {
    final found = await AetherConfigParser.extractEndpoint(protocol);
    if (found != null && found.isNotEmpty && _isValidPublicEndpoint(found)) {
      await prefs.setString(_lastEndpointKey, found);
      await prefs.setString(_lastProtocolKey, protocol);
      await prefs.setString(_lastMasqueKey, masque);
      log('★ Saved last endpoint from config: $found');
    } else if (found != null && found.isNotEmpty) {
      log('⚠ Config endpoint is private, not saving: $found');
    }
  }

  static String _transportLabel(String proto, String masque) =>
      proto == 'masque' ? 'MASQUE/$masque' : proto.toUpperCase();

  // ═══════════════════════════════════════════════════════════════
  //  استخراج endpoint واقعی از لاگ Aether
  //
  //  Aether در لاگ این خط را چاپ می‌کند:
  //    [+] using cloudflare edge 188.114.98.62:987
  // ═══════════════════════════════════════════════════════════════
  static final RegExp _edgeRegex = RegExp(
    r'using (?:cloudflare )?edge (\d+\.\d+\.\d+\.\d+):(\d+)',
    caseSensitive: false,
  );

  /// استخراج endpoint واقعی از یک خط لاگ Aether.
  String? extractRealEndpointFromLog(String line) {
    final match = _edgeRegex.firstMatch(line);
    if (match == null) return null;
    final ip = match.group(1)!;
    final port = match.group(2)!;
    final endpoint = '$ip:$port';
    if (!_isValidPublicEndpoint(endpoint)) return null;
    return endpoint;
  }

  /// ذخیرهٔ endpoint واقعی (از لاگ).
  Future<void> saveRealEndpointFromLog(
    String endpoint, {
    required String protocol,
    required String masque,
  }) async {
    if (!_isValidPublicEndpoint(endpoint)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastEndpointKey, endpoint);
      await prefs.setString(_lastProtocolKey, protocol);
      await prefs.setString(_lastMasqueKey, masque);
      await prefs.setString(
        _autoTransportKey,
        protocol == 'masque' ? 'masque:$masque' : protocol,
      );
      log('★ Saved real endpoint from log: $endpoint');
    } catch (_) {}
  }
}
