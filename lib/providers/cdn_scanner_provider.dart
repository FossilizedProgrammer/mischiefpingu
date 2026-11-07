library;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cdn_ip_checker.dart';
import '../cdn_sni_scout.dart';  // 🆕 اضافه شد
import '../services/ip_range_parser.dart';
import '../cdn_presets.dart';

part 'cdn_scanner/cdn_scanner_persistence.dart';
part 'cdn_scanner/cdn_scanner_presets.dart';

class CdnScannerProvider extends ChangeNotifier {
  final CdnIpChecker _checker;
  final CdnSniScout _sniScout = CdnSniScout();  // 🆕 اضافه شد

  static const String prefsCustomIps = 'cdnScannerCustomIps';
  static const String prefsCustomSnis = 'cdnScannerCustomSnis';
  static const String prefsSelectedPreset = 'cdnScannerSelectedPreset';
  static const String prefsScanMode = 'cdnScannerScanMode';

  String customInput = '';
  List<String> snis = [];
  int concurrency = 8;
  bool isRunning = false;
  String status = 'Idle';
  int scanned = 0;
  int total = 0;
  final List<CdnCheckResult> results = [];
  final List<CdnCheckResult> good = [];
  bool cancel = false;
  bool isLoaded = false;

  /// 🆕 وضعیت scout
  bool isScouting = false;
  int scoutDone = 0;
  int scoutTotal = 0;

  IpScanMode scanMode = IpScanMode.balanced;

  /// ⚠️ SNIهای عمومی‌تر اول
  final List<String> defaultSnis = [
    'www.cloudflare.com',
    '1.1.1.1',
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'www.microsoft.com',
    ...CdnPresets.akamaiSnis,
  ];

  String? selectedPresetId;
  List<String> _customIps = [];

  List<String> get customIps => List.unmodifiable(_customIps);

  set customIpsInternal(List<String> v) => _customIps = v;

  CdnScannerProvider({CdnIpChecker? checker})
      : _checker = checker ?? CdnIpChecker() {
    snis = List.from(defaultSnis);
    loadFromPrefs();
  }

  void touch() => notifyListeners();

  bool _isPublicIp(String ip) {
    if (ip.isEmpty) return false;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    if (ip.startsWith('10.')) return false;
    if (ip.startsWith('172.')) {
      final second = int.tryParse(parts[1]) ?? 0;
      if (second >= 16 && second <= 31) return false;
    }
    if (ip.startsWith('192.168.')) return false;
    if (ip.startsWith('127.')) return false;
    if (ip.startsWith('169.254.')) return false;
    final first = int.tryParse(parts[0]) ?? 0;
    if (first >= 224) return false;
    if (first == 0) return false;
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  //  🆕 SNI Scout — قبل از اسکن SNIهای سالم رو پیدا کن
  //
  //  این متد رو قبل از start() صدا بزنید یا از دکمه Scout.
  //  اگه پیدا نشد، می‌تونید از SNIهای پیش‌فرض استفاده کنید.
  // ═══════════════════════════════════════════════════════════════
  Future<void> scoutSnis() async {
    if (isScouting || isRunning) return;

    final cdnId = selectedPresetId ?? 'cloudflare';

    isScouting = true;
    scoutDone = 0;
    scoutTotal = 0;
    status = 'Scouting working SNIs for $cdnId…';
    touch();

    try {
      final result = await _sniScout.scoutFor(
        cdnId: cdnId,
        concurrency: 5,
        onProgress: (done, total) {
          scoutDone = done;
          scoutTotal = total;
          status = 'Scouting SNIs: $done/$total…';
          touch();
        },
      );

      if (result.error != null) {
        status = 'Scout failed: ${result.error}';
        touch();
        return;
      }

      if (result.working.isEmpty) {
        status = 'No working SNI found for $cdnId — '
            'ISP may be blocking everything';
        touch();
        return;
      }

      // ⚠️ فقط SNIهای سالم رو نگه دار
      snis = result.working.map((e) => e.sni).toList();

      final top = snis.take(3).join(', ');
      status = 'Found ${snis.length} working SNI(s): $top'
          '${snis.length > 3 ? " …" : ""}';
      touch();
    } catch (e) {
      status = 'Scout error: $e';
      touch();
    } finally {
      isScouting = false;
      touch();
    }
  }

  ExpansionResult _parseEffective() {
    final input = _resolveEffectiveInput();
    return IpRangeParser.expandWithDiagnostics(input, mode: scanMode);
  }

  int effectiveIpCount() => _parseEffective().ips.length;

  List<String> effectiveIpPreview({int max = 5}) =>
      _parseEffective().ips.take(max).toList();

  List<String> effectiveWarnings() => _parseEffective().warnings;

  String _resolveEffectiveInput() {
    if (selectedPresetId == 'custom') {
      if (_customIps.isNotEmpty) {
        return _customIps.join('\n');
      }
      return '';
    }
    return customInput;
  }

  // ═══════════════════════════════════════════════════════════════
  //  start — شروع اسکن
  //
  //  ⚠️ نکته مهم: اگه snis خالی باشه یا فقط SNIهای مشکوک داشته
  //  باشه، از scout خودکار استفاده می‌کنیم. کاربر می‌تونه از
  //  دکمه Scout قبل از اسکن استفاده کنه.
  // ═══════════════════════════════════════════════════════════════
  Future<void> start() async {
    if (isRunning) return;

    // ─── اگه SNIها خالی هستن، scout بزن ───
    if (snis.isEmpty) {
      await scoutSnis();
      if (snis.isEmpty) {
        status = 'No working SNI found — cannot scan';
        touch();
        return;
      }
    }

    final String effectiveInput = _resolveEffectiveInput();

    if (selectedPresetId == 'custom' && effectiveInput.trim().isEmpty) {
      status = 'Custom IP list is empty — add or save IPs first';
      isRunning = false;
      touch();
      return;
    }

    final parsed = IpRangeParser.expandWithDiagnostics(
      effectiveInput,
      mode: scanMode,
    );

    final ips = parsed.ips.where(_isPublicIp).toList();

    if (ips.isEmpty) {
      status = 'No valid public IPs found (check IPs / CIDR / Ranges)';
      isRunning = false;
      touch();
      return;
    }

    if (parsed.warnings.isNotEmpty) {
      for (final w in parsed.warnings.take(5)) {
        debugPrint('[CDN Scanner] $w');
      }
    }

    final modeLabel = scanMode.name;
    final snisToUse = snis.isNotEmpty ? snis : defaultSnis;
    if (selectedPresetId == 'custom') {
      status = 'Scanning ${ips.length} custom IP(s) [$modeLabel] '
          'with ${snisToUse.length} SNI(s)…';
    } else {
      status = 'Scanning ${ips.length} IPs ($selectedPresetId) [$modeLabel] '
          'with ${snisToUse.length} SNI(s)…';
    }
    touch();

    isRunning = true;
    cancel = false;
    results.clear();
    good.clear();
    scanned = 0;
    total = ips.length;

    final queue = List<String>.from(ips);
    var next = 0;

    Future<String?> takeNext() async {
      if (cancel || next >= queue.length) return null;
      return queue[next++];
    }

    Future<void> worker() async {
      while (!cancel) {
        final ip = await takeNext();
        if (ip == null) return;

        final r = await _checker.checkFull(ip, snisToUse);

        if (cancel) return;

        results.add(r);
        if (r.ok) good.add(r);

        scanned++;
        final goodCount = good.length;
        status = 'Scanned $scanned/$total · $goodCount usable · '
            'last: ${r.ip} → ${r.message}';
        touch();
      }
    }

    final n = concurrency.clamp(1, 20);
    await Future.wait(List.generate(n, (_) => worker()));

    good.sort((a, b) => b.score.compareTo(a.score));

    if (cancel) {
      status = good.isEmpty
          ? 'Stopped · No usable IPs found (out of $scanned/$total)'
          : 'Stopped · ${good.length} usable so far (out of $scanned/$total)';
    } else {
      status = 'Done · ${good.length} usable out of $total';
    }
    isRunning = false;
    touch();
  }

  void stop() {
    if (!isRunning) return;
    cancel = true;
    isRunning = false;
    good.sort((a, b) => b.score.compareTo(a.score));
    status = good.isEmpty
        ? 'Stopped · No usable IPs found (out of $scanned/$total)'
        : 'Stopped · ${good.length} usable so far (out of $scanned/$total)';
    touch();
  }

  List<String> get topIps => good.take(20).map((e) => e.ip).toList();
  String? get bestSni => good.isNotEmpty ? good.first.sni : null;

  Future<void> setScanMode(IpScanMode mode) async {
    if (scanMode == mode) return;
    scanMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsScanMode, mode.id);
    } catch (_) {}
    touch();
  }
}
