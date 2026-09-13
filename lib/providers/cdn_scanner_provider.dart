import 'package:flutter/foundation.dart';
import '../cdn_ip_checker.dart';
import '../services/ip_range_parser.dart';
import '../cdn_presets.dart';

class CdnScannerProvider extends ChangeNotifier {
  final _checker = CdnIpChecker();
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

  final List<String> defaultSnis = [
    ...CdnPresets.akamaiSnis,
    'microsoft.com',
    'google.com',
    'cloudflare.com',
  ];

  String? selectedPresetId;

  void applyPreset(String presetId) {
    final preset = CdnPresets.byId(presetId);
    if (preset == null) return;
    selectedPresetId = presetId;
    snis = List.from(preset.snis);
    customInput = preset.ranges.join('\n');
    notifyListeners();
  }

  CdnScannerProvider() {
    snis = List.from(defaultSnis);
  }

  Future<void> start() async {
    if (isRunning) return;

    final parsed = IpRangeParser.expandWithDiagnostics(customInput);
    final ips = parsed.ips;

    if (ips.isEmpty) {
      status = 'No valid IPs found';
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
