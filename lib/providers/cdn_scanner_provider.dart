import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cdn_ip_checker.dart';
import '../services/ip_range_parser.dart';
import '../cdn_presets.dart';

class CdnScannerProvider extends ChangeNotifier {
  final _checker = CdnIpChecker();

  static const String _prefsCustomIps = 'cdnScannerCustomIps';
  static const String _prefsCustomSnis = 'cdnScannerCustomSnis';
  static const String _prefsSelectedPreset = 'cdnScannerSelectedPreset';

  String customInput = '';
  List<String> snis = [];
  int concurrency = 12;
  bool isRunning = false;
  String status = 'Idle';
  int scanned = 0;
  int total = 0;
  final List<CdnCheckResult> results = [];
  final List<CdnCheckResult> good = [];
  bool _cancel = false;

  /// وقتی true بشه یعنی load از SharedPreferences کامل شده.
  bool isLoaded = false;

  final List<String> defaultSnis = [
    ...CdnPresets.akamaiSnis,
    'microsoft.com',
    'google.com',
    'cloudflare.com',
  ];

  String? selectedPresetId;

  // ─── Custom IPs (ذخیره‌شده در SharedPreferences) ───
  List<String> _customIps = [];
  List<String> get customIps => List.unmodifiable(_customIps);

  CdnScannerProvider() {
    snis = List.from(defaultSnis);
    _loadFromPrefs();
  }

  // ═══════════════════════════════════════════
  //  Persistence
  // ═══════════════════════════════════════════
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customIps = prefs.getStringList(_prefsCustomIps) ?? [];
      final savedSnis = prefs.getStringList(_prefsCustomSnis);
      final savedPreset = prefs.getString(_prefsSelectedPreset);

      if (savedPreset != null) {
        selectedPresetId = savedPreset;
        if (savedPreset == 'custom') {
          // ✅ مهم: customInput رو از _customIps پر کن
          customInput = _customIps.join('\n');
          if (savedSnis != null && savedSnis.isNotEmpty) {
            snis = List.from(savedSnis);
          } else {
            snis = List.from(CdnPresets.akamaiSnis);
          }
        } else {
          final preset = CdnPresets.byId(savedPreset);
          if (preset != null) {
            snis = List.from(preset.snis);
            customInput = preset.ranges.join('\n');
          } else {
            applyPreset('akamai');
          }
        }
      } else {
        applyPreset('akamai');
      }
    } catch (_) {
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _persistCustomIps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsCustomIps, _customIps);
    } catch (_) {}
  }

  Future<void> _persistSelectedPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (selectedPresetId != null) {
        await prefs.setString(_prefsSelectedPreset, selectedPresetId!);
      }
      if (selectedPresetId == 'custom') {
        await prefs.setStringList(_prefsCustomSnis, snis);
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════
  //  Preset management
  // ═══════════════════════════════════════════
  void applyPreset(String presetId) {
    final preset = CdnPresets.byId(presetId);
    if (preset == null) return;

    selectedPresetId = presetId;

    if (presetId == 'custom') {
      customInput = _customIps.join('\n');
      if (snis.isEmpty) {
        snis = List.from(CdnPresets.akamaiSnis);
      }
    } else {
      snis = List.from(preset.snis);
      customInput = preset.ranges.join('\n');
    }

    _persistSelectedPreset();
    notifyListeners();
  }

  Future<void> saveCustomIps(List<String> ips) async {
    _customIps = ips
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    await _persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = _customIps.join('\n');
    }
    notifyListeners();
  }

  Future<void> addCustomIps(List<String> ips) async {
    final merged = <String>{..._customIps, ...ips};
    _customIps = merged.toList();
    await _persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = _customIps.join('\n');
    }
    notifyListeners();
  }

  Future<void> removeCustomIp(String ip) async {
    _customIps.remove(ip);
    await _persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = _customIps.join('\n');
    }
    notifyListeners();
  }

  Future<void> clearCustomIps() async {
    _customIps.clear();
    await _persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = '';
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════
  //  Scan
  // ═══════════════════════════════════════════
  Future<void> start() async {
    if (isRunning) return;

    final parsed = IpRangeParser.expandWithDiagnostics(customInput);
    final ips = parsed.ips;

    if (ips.isEmpty) {
      status = 'No valid IPs found (check IPs / CIDR / Ranges)';
      isRunning = false;
      notifyListeners();
      return;
    }

    isRunning = true;
    _cancel = false;
    results.clear();
    good.clear();
    scanned = 0;
    total = ips.length;
    status = 'Scanning $total IPs…';
    notifyListeners();

    final queue = List<String>.from(ips);
    var next = 0;

    Future<String?> takeNext() async {
      if (_cancel || next >= queue.length) return null;
      return queue[next++];
    }

    Future<void> worker() async {
      while (!_cancel) {
        final ip = await takeNext();
        if (ip == null) return;

        final r = await _checker.checkFull(
          ip,
          snis.isNotEmpty ? snis : defaultSnis,
        );

        if (_cancel) return;
        results.add(r);
        if (r.ok) good.add(r);
        scanned++;
        status =
            'Scanned $scanned/$total · ${good.length} usable · last: ${r.ip} ${r.message}';
        notifyListeners();
      }
    }

    final n = concurrency.clamp(1, 20);
    await Future.wait(List.generate(n, (_) => worker()));
    good.sort((a, b) => b.score.compareTo(a.score));

    if (_cancel) {
      status = good.isEmpty
          ? 'Stopped · No usable IPs found'
          : 'Stopped · ${good.length} usable so far (out of $scanned/$total)';
    } else {
      status = 'Done · ${good.length} usable out of $total';
    }

    isRunning = false;
    notifyListeners();
  }

  void stop() {
    if (!isRunning) return;
    _cancel = true;
    isRunning = false;
    good.sort((a, b) => b.score.compareTo(a.score));

    status = good.isEmpty
        ? 'Stopped · No usable IPs found'
        : 'Stopped · ${good.length} usable so far (out of $scanned/$total)';

    notifyListeners();
  }

  List<String> get topIps => good.take(20).map((e) => e.ip).toList();
  String? get bestSni => good.isNotEmpty ? good.first.sni : null;
}
