library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import 'aether/aether_config_parser.dart';

/// Persists and reads Aether's last-known-good transport/endpoint
/// (SharedPreferences + aether config files on disk).
///
/// ⚠️ تغییرات مهم:
///   1. IPهای private (172.16.x.x, 10.x.x.x, 192.168.x.x) به عنوان
///      endpoint ذخیره نمی‌شوند. دلیل: این IPها در لاگ Aether
///      به عنوان gateway داخلی WARP ظاهر می‌شوند، نه endpoint واقعی.
///   2. اگر endpoint ذخیره‌شده fail شد، بلافاصله پاک می‌شود تا
///      بار بعد دوباره تلاش نکنیم.
///   3. endpoint واقعی از خط `using cloudflare edge X.X.X.X:PORT`
///      در لاگ Aether استخراج می‌شود.
class AetherEndpointStore {
  final AppSettings settings;
  final void Function(String) log;

  AetherEndpointStore({required this.settings, required this.log});

  static const String _autoTransportKey = 'aetherAutoTransport';
  static const String _lastEndpointKey = 'aetherLastSuccessfulEndpoint';
  static const String _lastProtocolKey = 'aetherLastProtocol';
  static const String _lastMasqueKey = 'aetherLastMasque';

  /// بازه‌های IP خصوصی که نباید به عنوان endpoint ذخیره شوند.
  static final List<RegExp> _privateIpPatterns = [
    RegExp(r'^10\.'),
    RegExp(r'^172\.(1[6-9]|2\d|3[0-1])\.'),
    RegExp(r'^192\.168\.'),
    RegExp(r'^127\.'),
    RegExp(r'^169\.254\.'), // link-local
    RegExp(r'^0\.'),
    RegExp(r'^255\.'),
  ];

  /// آیا این IP یک IP private است؟
  bool _isPrivateIp(String ip) {
    for (final pattern in _privateIpPatterns) {
      if (pattern.hasMatch(ip)) return true;
    }
    return false;
  }

  /// آیا این endpoint قابل اعتماد است؟
  bool _isValidPublicEndpoint(String endpoint) {
    if (endpoint.isEmpty) return false;
    final idx = endpoint.lastIndexOf(':');
    if (idx <= 0) return false;
    final ip = endpoint.substring(0, idx);
    final port = int.tryParse(endpoint.substring(idx + 1));
    if (port == null || port < 1 || port > 65535) return false;
    if (_isPrivateIp(ip)) return false;
    return true;
  }

  /// Last successful endpoint: SharedPreferences first, config file second.
  ///
  /// ⚠️ اگر مقدار ذخیره‌شده private باشد، نادیده گرفته می‌شود.
  Future<String?> getLastSuccessfulEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_lastEndpointKey);
      if (saved != null && saved.isNotEmpty) {
        if (_isValidPublicEndpoint(saved)) {
          return saved;
        }
        // پاک کردن مقدار نامعتبر
        log('→ Discarding invalid saved endpoint: $saved');
        await prefs.remove(_lastEndpointKey);
      }
    } catch (_) {}

    // fallback: از فایل config
    final proto =
        settings.aetherProtocol == 'auto' ? 'masque' : settings.aetherProtocol;
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

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ فقط endpoint معتبر (public) ذخیره می‌شود.
      //  اگر endpoint ورودی private باشد، از config یک مقدار
      //  معتبر استخراج می‌کنیم.
      // ═══════════════════════════════════════════════════════════
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
        // تلاش برای استخراج از config
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
    if (found != null &&
        found.isNotEmpty &&
        _isValidPublicEndpoint(found)) {
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
  //  API جدید: استخراج endpoint واقعی از لاگ Aether
  //
  //  Aether در لاگ این خط را چاپ می‌کند:
  //    [+] using cloudflare edge 188.114.98.62:987
  //
  //  این endpoint واقعی است (public IP). باید همین را ذخیره
  //  کنیم، نه چیزی که در aether.toml است.
  // ═══════════════════════════════════════════════════════════════
  static final RegExp _edgeRegex = RegExp(
    r'using (?:cloudflare )?edge (\d+\.\d+\.\d+\.\d+):(\d+)',
    caseSensitive: false,
  );

  /// استخراج endpoint واقعی از یک خط لاگ Aether.
  /// اگر خط شامل endpoint نبود، null.
  String? extractRealEndpointFromLog(String line) {
    final match = _edgeRegex.firstMatch(line);
    if (match == null) return null;
    final ip = match.group(1)!;
    final port = match.group(2)!;
    final endpoint = '$ip:$port';
    if (!_isValidPublicEndpoint(endpoint)) return null;
    return endpoint;
  }

  /// ذخیرهٔ endpoint واقعی (از لاگ) — این را از process listener صدا بزن.
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
