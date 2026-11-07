library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bridge_line.dart';
import '../services/bridge_reachability_checker.dart';

class BridgeScannerProvider extends ChangeNotifier {
  final _checker = BridgeReachabilityChecker();

  static const String _prefsSavedBridges = 'savedBridgeLines';

  String _rawInput = '';
  String get rawInput => _rawInput;
  set rawInput(String v) {
    _rawInput = v;
    notifyListeners();
  }

  bool isRunning = false;
  String status = 'Idle';
  int scanned = 0;
  int total = 0;
  final List<BridgeScanResult> results = [];
  bool cancel = false;
  int concurrency = 10;

  // ═══════════════════════════════════════════════════════════════
  //  🆕 ذخیره‌شده‌ها
  // ═══════════════════════════════════════════════════════════════
  List<String> _savedBridges = [];
  List<String> get savedBridges => List.unmodifiable(_savedBridges);
  bool _savedLoaded = false;

  /// لیست بریج‌های کارکننده، مرتب‌شده بر اساس بهترین پینگ.
  List<BridgeScanResult> get working =>
      results.where((r) => r.isReachable).toList()
        ..sort((a, b) => a.latencyMs.compareTo(b.latencyMs));

  /// ═══════════════════════════════════════════════════════════════
  ///  🆕 نتایج مرتب‌شده:
  ///    • بریج‌های کارکننده اول، بر اساس پینگ صعودی
  ///    • بریج‌های ناکار بعد، بر اساس پینگ صعودی
  /// ═══════════════════════════════════════════════════════════════
  List<BridgeScanResult> get sortedResults {
    final sorted = List<BridgeScanResult>.from(results);
    sorted.sort((a, b) {
      if (a.isReachable && !b.isReachable) return -1;
      if (!a.isReachable && b.isReachable) return 1;
      // هر دو هم‌وضعیت هستند → بر اساس latency
      final la = a.isReachable ? a.latencyMs : 999999;
      final lb = b.isReachable ? b.latencyMs : 999999;
      return la.compareTo(lb);
    });
    return sorted;
  }

  /// بارگذاری اولیه بریج‌های ذخیره‌شده از SharedPreferences.
  Future<void> initSavedBridges() async {
    if (_savedLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedBridges = prefs.getStringList(_prefsSavedBridges) ?? [];
    } catch (_) {
      _savedBridges = [];
    }
    _savedLoaded = true;
    notifyListeners();
  }

  /// ذخیره بریج‌های کارکننده فعلی.
  Future<int> saveWorkingBridges() async {
    final workingLines = working.map((r) => r.bridge.raw).toList();
    if (workingLines.isEmpty) return 0;
    _savedBridges = List.from(workingLines);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsSavedBridges, _savedBridges);
    } catch (_) {}
    notifyListeners();
    return workingLines.length;
  }

  /// بارگذاری بریج‌های ذخیره‌شده به input.
  Future<int> loadSavedBridges() async {
    if (!_savedLoaded) await initSavedBridges();
    if (_savedBridges.isEmpty) return 0;
    _rawInput = _savedBridges.join('\n');
    notifyListeners();
    return _savedBridges.length;
  }

  /// اسکن مجدد بریج‌های ذخیره‌شده.
  Future<int> rescanSavedBridges() async {
    if (!_savedLoaded) await initSavedBridges();
    if (_savedBridges.isEmpty) return 0;
    final count = _savedBridges.length;
    _rawInput = _savedBridges.join('\n');
    notifyListeners();
    await start();
    return count;
  }

  /// پاک کردن بریج‌های ذخیره‌شده.
  Future<void> clearSavedBridges() async {
    _savedBridges = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsSavedBridges);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> fetchFromCollector(String transport) async {
    status = 'Fetching $transport bridges…';
    notifyListeners();
    try {
      final url =
          'https://raw.githubusercontent.com/center2055/OnionHop-Bridges-Collector/main/bridge/${transport}_tested.txt';
      final r = await Process.run(
        'curl',
        ['-sSL', '--max-time', '15', url],
      );
      if (r.exitCode == 0) {
        rawInput = r.stdout as String;
        final count = rawInput
            .split('\n')
            .where((e) => e.trim().isNotEmpty && !e.trim().startsWith('#'))
            .length;
        status = 'Fetched $count bridges';
      } else {
        status = 'Fetch failed';
      }
    } catch (e) {
      status = 'Fetch error: $e';
    }
    notifyListeners();
  }

  Future<void> start() async {
    if (isRunning) return;
    final lines = _rawInput
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final bridges =
        lines.map((e) => BridgeLine.parse(e)).whereType<BridgeLine>().toList();
    if (bridges.isEmpty) {
      status = 'No valid bridge lines found';
      notifyListeners();
      return;
    }
    isRunning = true;
    cancel = false;
    results.clear();
    scanned = 0;
    total = bridges.length;
    status = 'Scanning $total bridges…';
    notifyListeners();
    final queue = List<BridgeLine>.from(bridges);
    var next = 0;
    Future<BridgeLine?> takeNext() async {
      if (cancel || next >= queue.length) return null;
      return queue[next++];
    }

    Future<void> worker() async {
      while (!cancel) {
        final bridge = await takeNext();
        if (bridge == null) return;
        final result = await _checker.check(bridge);
        if (cancel) return;
        results.add(result);
        scanned++;
        status = 'Scanned $scanned/$total · ${working.length} working';
        notifyListeners();
      }
    }

    final n = concurrency.clamp(1, 20);
    await Future.wait(List.generate(n, (_) => worker()));
    if (cancel) {
      status = 'Stopped · ${working.length} working so far';
    } else {
      status = 'Done · ${working.length} working out of $total';
    }
    isRunning = false;
    notifyListeners();
  }

  void stop() {
    if (!isRunning) return;
    cancel = true;
    isRunning = false;
    status = 'Stopped · ${working.length} working so far';
    notifyListeners();
  }
}
