library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cdn_ip_checker.dart';
import '../services/ip_range_parser.dart';
import '../cdn_presets.dart';

part 'cdn_scanner/cdn_scanner_persistence.dart';
part 'cdn_scanner/cdn_scanner_presets.dart';

class CdnScannerProvider extends ChangeNotifier {
  final _checker = CdnIpChecker();

  static const String prefsCustomIps = 'cdnScannerCustomIps';
  static const String prefsCustomSnis = 'cdnScannerCustomSnis';
  static const String prefsSelectedPreset = 'cdnScannerSelectedPreset';

  String customInput = '';
  List<String> snis = [];
  int concurrency = 12;
  bool isRunning = false;
  String status = 'Idle';
  int scanned = 0;
  int total = 0;
  final List<CdnCheckResult> results = [];
  final List<CdnCheckResult> good = [];
  bool cancel = false;
  bool isLoaded = false;

  final List<String> defaultSnis = [
    ...CdnPresets.akamaiSnis,
    'microsoft.com',
    'google.com',
    'cloudflare.com',
  ];

  String? selectedPresetId;

  List<String> _customIps = [];
  List<String> get customIps => List.unmodifiable(_customIps);

  /// ✅ برای set کردن از extensionها (چون _customIps private است).
  set customIpsInternal(List<String> v) => _customIps = v;

  CdnScannerProvider() {
    snis = List.from(defaultSnis);
    loadFromPrefs();
  }

  /// ✅ برای استفاده در extensionها.
  void touch() => notifyListeners();

  Future<void> start() async {
    if (isRunning) return;

    final parsed = IpRangeParser.expandWithDiagnostics(customInput);
    final ips = parsed.ips;

    if (ips.isEmpty) {
      status = 'No valid IPs found (check IPs / CIDR / Ranges)';
      isRunning = false;
      touch();
      return;
    }

    isRunning = true;
    cancel = false;
    results.clear();
    good.clear();
    scanned = 0;
    total = ips.length;
    status = 'Scanning $total IPs…';
    touch();

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

        final r = await _checker.checkFull(
          ip,
          snis.isNotEmpty ? snis : defaultSnis,
        );

        if (cancel) return;
        results.add(r);
        if (r.ok) good.add(r);
        scanned++;
        status =
            'Scanned $scanned/$total · ${good.length} usable · last: ${r.ip} ${r.message}';
        touch();
      }
    }

    final n = concurrency.clamp(1, 20);
    await Future.wait(List.generate(n, (_) => worker()));
    good.sort((a, b) => b.score.compareTo(a.score));

    if (cancel) {
      status = good.isEmpty
          ? 'Stopped · No usable IPs found'
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
        ? 'Stopped · No usable IPs found'
        : 'Stopped · ${good.length} usable so far (out of $scanned/$total)';

    touch();
  }

  List<String> get topIps => good.take(20).map((e) => e.ip).toList();
  String? get bestSni => good.isNotEmpty ? good.first.sni : null;
}
