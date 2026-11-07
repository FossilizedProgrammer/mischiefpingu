import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings_model.dart';
import '../models/settings_validation.dart';
import '../models/lantern_engine.dart';
import '../services/process_service.dart';
import '../services/privilege_service.dart';
import '../services/app_data_service.dart';
import '../services/aether_auto_test_service.dart';
import '../services/aether/gateway_reconnect_orchestrator.dart';
import '../services/aether_logger.dart';
import '../services/ffvpn/ffvpn_upstream_builder.dart';
import '../services/geph/geph_upstream_builder.dart';
import '../services/geph/geph_cli_service.dart';
import '../services/lantern/lantern_upstream_builder.dart';
import '../services/lantern/lantern_cli_service.dart';
import '../services/psiphon_config_builder.dart';
import '../services/psiphon/psiphon_upstream_builder.dart';
import '../services/tor_config_builder.dart';
import '../services/sstp_config_builder.dart';
import '../services/settings_persistence_service.dart';
import '../services/auto_reconnect_manager.dart';
import '../services/core_update_service.dart';
import '../services/log_line_parsers.dart';
import '../services/port_manager.dart';
import '../services/tunnel_watchdog_manager.dart';
import '../services/tunnel_watchdog_factory.dart';
import '../services/psiphon/psiphon_log_watcher.dart';
import '../services/tor/tor_log_watcher.dart';
import '../services/sstp/sstp_log_watcher.dart';
import '../services/sstp/sstp_upstream_builder.dart';
import '../services/recovery/recovery_coordinator.dart';
import '../services/diagnostics/connectivity_probe.dart';
import '../services/network/network_change_detector.dart';
import '../services/watchdog/tunnel_watchdog.dart';
import '../services/database/database_initializer.dart';
import '../services/database/gateway_database.dart';
import '../services/database/gateway_history_store.dart';
import '../services/database/aether_event_store.dart';
import '../services/database/profile_performance_store.dart';
import '../services/aether/decision/aether_decision_engine.dart';
import '../services/aether/decision/ranked_candidate.dart';
import '../services/aether/connection_health.dart';
import '../services/aether/connection_health_monitor.dart';
import '../services/aether/quality_degradation_detector.dart';
import '../services/aether/quality_statistics_service.dart';
import '../services/health/tunnel_health_models.dart';
import '../services/health/tunnel_health_registry.dart';
import '../constants/default_lists.dart';
import 'internet_quality_provider.dart';
import '../services/wireguard/wireguard_config_parser.dart';
import '../services/wireguard/wireguard_config_builder.dart';
import '../services/wireguard/wireguard_paths.dart';
import '../services/npv/npv_paths.dart';
import '../services/wireguard/wireguard_log_watcher.dart';
import '../services/sstp/sstp_keepalive.dart';

part 'app_provider_snapshot.dart';
part 'sstp/sstp_launch.dart';
part 'sstp/sstp_preflight.dart';
part 'sstp/sstp_launch_guards.dart';
part 'sstp/sstp_launch_prepare.dart';
part 'tor/tor_launch.dart';
part 'tor/tor_launch_guards.dart';
part 'tor/tor_launch_prepare.dart';
part 'app_provider_lifecycle.dart';
part 'app_provider_lifecycle_persistence.dart';
part 'app_provider_parsers.dart';
part 'app_provider_psiphon.dart';
part 'app_provider_psiphon_preflight.dart';
part 'aether/aether_smart_reconnect.dart';
part 'psiphon/psiphon_launch.dart';
part 'psiphon/psiphon_upstream_resolver.dart';
part 'app_provider_aether.dart';
part 'app_provider_aether_internal.dart';
part 'app_provider_aether_preflight.dart';
part 'app_provider_tor.dart';
part 'app_provider_tor_assets.dart';
part 'app_provider_tor_upstream.dart';
part 'app_provider_tor_preflight.dart';
part 'app_provider_sstp.dart';
part 'app_provider_sstp_upstream.dart';
part 'app_provider_watchdogs.dart';
part 'app_provider_watchdogs_leases.dart';
part 'app_provider_watchdogs_factory.dart';
part 'app_provider_reconnect.dart';
part 'app_provider_reconnect_scheduler.dart';
part 'app_provider_log_watchers.dart';
part 'app_provider_process_listener.dart';
part 'app_provider_wrappers.dart';
part 'app_provider_wireguard.dart';
part 'app_provider_wireguard_internal.dart';
part 'app_provider_wireguard_preflight.dart';
part 'app_provider_ffvpn.dart';
part 'ffvpn/ffvpn_preflight.dart';
part 'app_provider_lantern.dart';
part 'lantern/lantern_preflight.dart';
part 'app_provider_geph.dart';
part 'app_provider_npv.dart';
part 'npv/npv_preflight.dart';
part 'geph/geph_preflight.dart';
part 'app_provider_constructor.dart';
part 'app_provider_dispose.dart';
part 'aether/aether_start_guards.dart';
part 'aether/aether_fast_path.dart';
part 'aether/aether_restart.dart';
part 'app_provider_public_actions.dart';
part 'app_provider_health_helpers.dart';
part 'app_provider_tunnel_helpers.dart';
part 'app_provider_log_watchers_verify.dart';
part 'app_provider_lifecycle_shutdown.dart';
part 'app_provider_process_listener_sync.dart';

class AppProvider extends ChangeNotifier {
  final ProcessService processService = ProcessService();

  late AetherAutoTestService _aetherTestService;
  AetherAutoTestService get aetherTestService => _aetherTestService;
  late final SstpKeepalive _sstpKeepalive;
  SstpKeepalive get sstpKeepalive => _sstpKeepalive;

  final SettingsPersistenceService persistence = SettingsPersistenceService();
  final AutoReconnectManager _reconnectManager = AutoReconnectManager();
  AutoReconnectManager get reconnectManager => _reconnectManager;

  bool isWireGuardBusy = false;
  bool userStoppedWireGuard = true;
  bool restartingWireGuard = false;
  String wireGuardStatus = 'WireGuard: Ready';
  late WireGuardLogWatcher _wireGuardLog;
  int _wireGuardGeneration = 0;
  int get wireGuardGeneration => _wireGuardGeneration;
  int nextWireGuardGeneration() => ++_wireGuardGeneration;

  bool isFfvpnBusy = false;
  bool userStoppedFfvpn = true;
  String ffvpnStatus = 'Firefox VPN: Ready';
  int _ffvpnGeneration = 0;
  int get ffvpnGeneration => _ffvpnGeneration;
  int nextFfvpnGeneration() => ++_ffvpnGeneration;

  bool isLanternBusy = false;
  bool userStoppedLantern = true;
  String lanternStatus = 'Lantern: Ready';
  int _lanternGeneration = 0;
  int get lanternGeneration => _lanternGeneration;
  int nextLanternGeneration() => ++_lanternGeneration;

  bool isNpvBusy = false;
  bool userStoppedNpv = true;
  String npvStatus = 'NPV: Ready';
  int _npvGeneration = 0;
  int get npvGeneration => _npvGeneration;
  int nextNpvGeneration() => ++_npvGeneration;

  bool isGephBusy = false;
  bool userStoppedGeph = true;
  String gephStatus = 'Geph: Ready';
  int _gephGeneration = 0;
  int get gephGeneration => _gephGeneration;
  int nextGephGeneration() => ++_gephGeneration;

  late RecoveryCoordinator _recoveryCoordinator;
  RecoveryCoordinator get recoveryCoordinator => _recoveryCoordinator;

  late ConnectivityProbe _connectivityProbe;
  ConnectivityProbe get connectivityProbe => _connectivityProbe;

  late NetworkChangeDetector _networkChangeDetector;
  NetworkChangeDetector get networkChangeDetector => _networkChangeDetector;

  late GatewayHistoryStore _gatewayHistoryStore;
  GatewayHistoryStore get gatewayHistoryStore => _gatewayHistoryStore;

  late AetherEventStore _aetherEventStore;
  AetherEventStore get aetherEventStore => _aetherEventStore;

  late AetherLogger _aetherLogger;
  AetherLogger get aetherLogger => _aetherLogger;

  late ProfilePerformanceStore _profilePerformanceStore;
  ProfilePerformanceStore get profilePerformanceStore =>
      _profilePerformanceStore;

  late AetherDecisionEngine _decisionEngine;
  AetherDecisionEngine get decisionEngine => _decisionEngine;

  late ConnectionHealthMonitor _healthMonitor;
  ConnectionHealth? _currentHealth;
  ConnectionHealth? get currentHealth => _currentHealth;
  ConnectionHealth? _lastNotifiedHealth;

  late QualityDegradationDetector _degradationDetector;
  late QualityStatisticsService _statsService;
  QualityStatisticsService get statsService => _statsService;

  late TunnelHealthRegistry _healthRegistry;
  TunnelHealthRegistry get healthRegistry => _healthRegistry;

  RankedCandidate? _currentActiveCandidate;
  RankedCandidate? get currentActiveCandidate => _currentActiveCandidate;

  Timer? _healthPollTimer;
  final Duration healthPollInterval = const Duration(seconds: 3);

  GatewayReconnectOrchestrator? _gatewayReconnectOrchestrator;
  GatewayReconnectOrchestrator? get gatewayReconnectOrchestrator =>
      _gatewayReconnectOrchestrator;

  InternetQualityProvider? _qualityProvider;
  InternetQualityProvider? get qualityProvider => _qualityProvider;

  int _psiphonGeneration = 0;
  int _aetherGeneration = 0;
  int _torGeneration = 0;
  int _sstpGeneration = 0;
  int get psiphonGeneration => _psiphonGeneration;
  int get aetherGeneration => _aetherGeneration;
  int get torGeneration => _torGeneration;
  int get sstpGeneration => _sstpGeneration;
  int nextPsiphonGeneration() => ++_psiphonGeneration;
  int nextAetherGeneration() => ++_aetherGeneration;
  int nextTorGeneration() => ++_torGeneration;
  int nextSstpGeneration() => ++_sstpGeneration;

  TunnelWatchdogManager? _watchdogManager;
  TunnelWatchdogManager? get watchdogManager => _watchdogManager;

  String? _lastBuiltProfile;

  late PsiphonLogWatcher _psiphonLog;
  late TorLogWatcher _torLog;
  late SstpLogWatcher _sstpLog;
  PsiphonLogWatcher get psiphonLog => _psiphonLog;
  TorLogWatcher get torLog => _torLog;
  SstpLogWatcher get sstpLog => _sstpLog;

  StreamSubscription<String>? _logSubscription;
  StreamSubscription<String>? get logSubscription => _logSubscription;

  _TunnelStateSnapshot? _lastTunnelState;

  AppSettings settings = AppSettings();
  List<String> ipList = List.from(DefaultLists.ipList);
  List<String> httpHostList = List.from(DefaultLists.httpHostList);
  List<String> tlsSniList = List.from(DefaultLists.tlsSniList);

  bool isLoading = false;
  bool isPsiphonBusy = false;
  bool isTorBusy = false;
  bool isSstpBusy = false;

  /// نگهبان بازگشت: Psiphon ↔ هسته‌ای که آپ‌استریم خودش است.
  bool _psiphonUpstreamResolving = false;
  bool loggingEnabled = true;
  String aetherStatus = 'Aether: Ready';
  String torStatus = 'Tor: Ready';
  String sstpStatus = 'SSTP: Ready';
  bool isElevated = false;
  bool isAutoTesting = false;
  bool userStoppedPsiphon = true;
  bool userStoppedAether = true;
  bool userStoppedTor = true;
  bool userStoppedSstp = true;
  bool isShuttingDown = false;
  bool restartingPsiphon = false;
  bool restartingAether = false;
  bool restartingTor = false;
  bool restartingSstp = false;

  String? lastAetherConnectedProtocol;
  String? lastAetherConnectedGatewayKey;
  DateTime? lastAetherConnectedAt;
  int aetherReconnectCount = 0;
  bool _escalationInProgress = false;

  AppProvider() {
    initializeAppProvider(this);
  }

  /// آیا تونلی در حال کار است یا وسط start/stop؟
  ///
  /// محل مرجع این پرسش است: مسیر بستن پنجره با همین تصمیم می‌گیرد که آیا
  /// لازم است قبل از خروج تونل‌ها بسته شوند یا نه. اگر تونلی اینجا جا بیفتد،
  /// هنگام بستن برنامه زنده رها می‌شود.
  bool get hasActiveTunnel {
    final ps = processService;
    return ps.isPsiphonRunning ||
        isPsiphonBusy ||
        ps.isAetherRunning ||
        isAutoTesting ||
        ps.isTorRunning ||
        isTorBusy ||
        ps.isSstpRunning ||
        isSstpBusy ||
        ps.isWireGuardRunning ||
        isWireGuardBusy ||
        ps.isFfvpnRunning ||
        isFfvpnBusy ||
        ps.isLanternRunning ||
        isLanternBusy ||
        ps.isGephRunning ||
        isGephBusy ||
        ps.isNpvRunning ||
        isNpvBusy;
  }

  void attachQualityProvider(InternetQualityProvider provider) {
    _qualityProvider = provider;
    processService.addLog(
      '→ AppProvider: InternetQualityProvider attached (watchdog will use full quality diagnostics)',
      source: LogSource.app,
    );
  }

  /// ✅ این متد در کلاس اصلی تعریف شده تا به notifyListeners دسترسی داشته باشد
  void touch() {
    if (isShuttingDown) return;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeAppProvider(this);
    super.dispose();
  }
}
