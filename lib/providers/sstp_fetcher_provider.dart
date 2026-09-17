library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/vpngate_scraper_service.dart';
import '../services/sstp_server_store.dart';
import '../services/sstp_health_checker.dart';
import '../services/process_service.dart';

part 'sstp_fetcher/sstp_fetcher_proxy.dart';
part 'sstp_fetcher/sstp_fetcher_fetch.dart';
part 'sstp_fetcher/sstp_fetcher_health.dart';
part 'sstp_fetcher/sstp_fetcher_auto_refresh.dart';

class SstpFetcherProvider extends ChangeNotifier {
  final ProcessService processService;

  SstpFetcherProvider({required this.processService});

  final _store = SstpServerStore();
  late final VpngateScraperService _scraper =
      VpngateScraperService(log: processService.addLog);
  final _healthChecker = SstpHealthChecker();

  List<SstpServer> servers = [];
  bool isLoading = false;
  String status = 'Idle';
  String lastMessage = '';
  bool autoRefresh = false;
  Timer? autoTimer;
  String proxyMode = 'auto';

  final Map<String, SstpHealthResult> health = {};
  bool isHealthChecking = false;
  int healthProgressDone = 0;
  int healthProgressTotal = 0;
  bool cancelHealth = false;

  int Function() psiphonPortGetter = () => 1080;
  int Function() aetherPortGetter = () => 1819;
  int Function() torPortGetter = () => 19050;
  int Function() sstpPortGetter = () => 1082;

  /// ✅ برای استفاده در extensionها (چون notifyListeners protected است)
  void touch() => notifyListeners();

  SstpHealthResult healthOf(SstpServer s) =>
      health[s.key] ?? SstpHealthResult.unknown;

  int get aliveCount => servers.where((s) {
        final h = health[s.key];
        return h?.status == SstpHealth.alive;
      }).length;

  Future<void> init() async {
    servers = await _store.load();
    status = servers.isEmpty ? 'No saved servers' : '${servers.length} saved';
    touch();
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    cancelHealth = true;
    super.dispose();
  }
}
