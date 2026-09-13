// lib/providers/sstp_fetcher_provider.dart
//
// ═══════════════════════════════════════════════════════════════
//  SstpFetcherProvider
//   • fetch از vpngate.net (با/بدون پروکسی)
//   • ذخیره در دیتافایل با dedup
//   • auto-refresh هر ۱۵ دقیقه
//   • health-check موازی و مرتب‌سازی بر اساس سلامت + latency
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/vpngate_scraper_service.dart';
import '../services/sstp_server_store.dart';
import '../services/sstp_health_checker.dart';
import '../services/process_service.dart';

class SstpFetcherProvider extends ChangeNotifier {
  final ProcessService processService;

  SstpFetcherProvider({required this.processService});

  final _store = SstpServerStore();
  late final VpngateScraperService _scraper =
      VpngateScraperService(log: processService.addLog);
  final _healthChecker = SstpHealthChecker();

  // ─── state ───
  List<SstpServer> servers = [];
  bool isLoading = false;
  String status = 'Idle';
  String lastMessage = '';
  bool autoRefresh = false;
  Timer? _autoTimer;

  /// انتخاب کاربر برای پروکسی این فرایند:
  ///   'direct' | 'psiphon' | 'aether' | 'tor' | 'sstp' | 'auto'
  String proxyMode = 'auto';

  // ─── health state ───
  /// ip:port → وضعیت
  final Map<String, SstpHealthResult> _health = {};
  bool isHealthChecking = false;
  int _healthProgressDone = 0;
  int _healthProgressTotal = 0;
  bool _cancelHealth = false;

  SstpHealthResult healthOf(SstpServer s) =>
      _health[s.key] ?? SstpHealthResult.unknown;

  int get healthProgressDone => _healthProgressDone;
  int get healthProgressTotal => _healthProgressTotal;

  /// تعداد سرورهای زنده (alive).
  int get aliveCount => servers.where((s) {
        final h = _health[s.key];
        return h?.status == SstpHealth.alive;
      }).length;

  /// سرورهای مرتب‌شده برای UI.
  List<SstpServer> get visibleServers {
    final list = List<SstpServer>.from(servers);

    // مرتب‌سازی: alive اول، بعد tcpOnly، بعد unknown، بعد checking، بعد dead
    list.sort((a, b) {
      final ha = _health[a.key];
      final hb = _health[b.key];
      final sa = _rank(ha);
      final sb = _rank(hb);
      if (sa != sb) return sa.compareTo(sb);
      final la = ha?.latencyMs ?? 9999;
      final lb = hb?.latencyMs ?? 9999;
      if (la != lb) return la.compareTo(lb);
      return a.ping.compareTo(b.ping);
    });
    return list;
  }

  int _rank(SstpHealthResult? h) {
    switch (h?.status) {
      case SstpHealth.alive:
        return 0;
      case SstpHealth.tcpOnly:
        return 1;
      case SstpHealth.unknown:
        return 2;
      case SstpHealth.checking:
        return 3;
      case SstpHealth.dead:
        return 4;
      default:
        return 2;
    }
  }

  // ─── init ───
  Future<void> init() async {
    servers = await _store.load();
    status = servers.isEmpty ? 'No saved servers' : '${servers.length} saved';
    notifyListeners();
  }

  // ═══════════════════════════════════════════
  //  resolve proxy
  // ═══════════════════════════════════════════
  String? _resolveProxy() {
    String? pick(String mode) {
      switch (mode) {
        case 'psiphon':
          return processService.isPsiphonConnected
              ? '127.0.0.1:${_psiphonSocksPort()}'
              : null;
        case 'aether':
          return processService.isAetherRunning
              ? '127.0.0.1:${_aetherSocksPort()}'
              : null;
        case 'tor':
          return processService.isTorConnected
              ? '127.0.0.1:${_torSocksPort()}'
              : null;
        case 'sstp':
          return processService.isSstpConnected
              ? '127.0.0.1:${_sstpSocksPort()}'
              : null;
        default:
          return null;
      }
    }

    if (proxyMode == 'direct') return null;
    if (proxyMode != 'auto') {
      final v = pick(proxyMode);
      if (v == null) {
        throw StateError(
          'Selected proxy ($proxyMode) is not running. '
          'Start it first or choose Auto/Direct.',
        );
      }
      return v;
    }
    for (final m in ['psiphon', 'aether', 'tor', 'sstp']) {
      final v = pick(m);
      if (v != null) return v;
    }
    return null;
  }

  int Function() _psiphonPortGetter = () => 1080;
  int Function() _aetherPortGetter = () => 1819;
  int Function() _torPortGetter = () => 19050;
  int Function() _sstpPortGetter = () => 1082;

  int _psiphonSocksPort() => _psiphonPortGetter();
  int _aetherSocksPort() => _aetherPortGetter();
  int _torSocksPort() => _torPortGetter();
  int _sstpSocksPort() => _sstpPortGetter();

  void bindPortGetters({
    required int Function() psiphon,
    required int Function() aether,
    required int Function() tor,
    int Function()? sstp,
  }) {
    _psiphonPortGetter = psiphon;
    _aetherPortGetter = aether;
    _torPortGetter = tor;
    if (sstp != null) _sstpPortGetter = sstp;
  }

  // ═══════════════════════════════════════════
  //  fetch
  // ═══════════════════════════════════════════
  Future<void> fetchNow({bool autoCheckAfter = false}) async {
    if (isLoading) return;
    isLoading = true;
    status = 'Fetching vpngate.net…';
    lastMessage = '';
    notifyListeners();

    try {
      String? proxy;
      try {
        proxy = _resolveProxy();
      } on StateError catch (e) {
        isLoading = false;
        status = 'Proxy not available';
        lastMessage = e.message;
        notifyListeners();
        return;
      }

      final result = await _scraper.fetchAndParse(proxy: proxy);
      if (!result.ok) {
        isLoading = false;
        status = 'Fetch failed';
        lastMessage = result.message;
        notifyListeners();
        return;
      }

      final merged = await _store.merge(result.servers);
      servers = merged.all;
      isLoading = false;
      status = 'Total: ${servers.length} server(s)';
      lastMessage = merged.added > 0
          ? '★ Added ${merged.added} new server(s) (${result.servers.length} fetched)'
          : 'No new servers (${result.servers.length} fetched, all duplicates)';

      processService.addLog(
        '★ vpngate: $lastMessage',
        source: 'Vpngate',
      );

      notifyListeners();

      // اگر auto است، بعد از fetch خودکار health check بزن
      if (autoCheckAfter && servers.isNotEmpty && !isHealthChecking) {
        await checkAllHealth();
      }
    } catch (e) {
      isLoading = false;
      status = 'Error';
      lastMessage = '$e';
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════
  //  health check
  // ═══════════════════════════════════════════
  Future<void> checkAllHealth({int concurrency = 20}) async {
    if (isHealthChecking) return;
    if (servers.isEmpty) return;

    isHealthChecking = true;
    _cancelHealth = false;
    _healthProgressDone = 0;
    _healthProgressTotal = servers.length;

    // همه را به checking ست کن
    for (final s in servers) {
      _health[s.key] = const SstpHealthResult(
        status: SstpHealth.checking,
        latencyMs: 0,
        message: 'checking…',
      );
    }
    notifyListeners();

    final queue = List<SstpServer>.from(servers);
    var next = 0;

    Future<void> worker() async {
      while (!_cancelHealth) {
        final idx = next++;
        if (idx >= queue.length) return;
        final s = queue[idx];
        try {
          final r = await _healthChecker.check(s.ip, s.port);
          _health[s.key] = r;
        } catch (e) {
          _health[s.key] = SstpHealthResult(
            status: SstpHealth.dead,
            latencyMs: 0,
            message: _shortErr(e),
          );
        }
        _healthProgressDone++;
        // برای جلوگیری از rebuild های پشت سر هم، هر ۳ تا یک بار notify
        if (_healthProgressDone % 3 == 0 ||
            _healthProgressDone == _healthProgressTotal) {
          notifyListeners();
        }
      }
    }

    final n = concurrency.clamp(1, 60);
    await Future.wait(List.generate(n, (_) => worker()));

    isHealthChecking = false;
    final alive = aliveCount;
    status = '$alive alive / ${servers.length} total';
    processService.addLog(
      '★ SSTP health check done: $status',
      source: 'SstpHealth',
    );
    notifyListeners();
  }

  void cancelHealthCheck() {
    if (!isHealthChecking) return;
    _cancelHealth = true;
    isHealthChecking = false;
    status = 'Health check cancelled';
    notifyListeners();
  }

  String _shortErr(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }

  // ═══════════════════════════════════════════
  //  auto-refresh
  // ═══════════════════════════════════════════
  void setAutoRefresh(bool value) {
    autoRefresh = value;
    _autoTimer?.cancel();
    _autoTimer = null;
    if (value) {
      _autoTimer = Timer.periodic(const Duration(minutes: 15), (_) {
        // هر ۱۵ دقیقه: fetch + health check
        fetchNow(autoCheckAfter: true);
      });
      processService.addLog(
        '→ vpngate auto-refresh enabled (every 15 min)',
        source: 'Vpngate',
      );
    } else {
      processService.addLog(
        '→ vpngate auto-refresh disabled',
        source: 'Vpngate',
      );
    }
    notifyListeners();
  }

  void setProxyMode(String mode) {
    proxyMode = mode;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _store.clear();
    servers = [];
    _health.clear();
    status = 'Cleared';
    notifyListeners();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _cancelHealth = true;
    super.dispose();
  }
}
