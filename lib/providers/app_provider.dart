import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings_model.dart';
import '../models/settings_validation.dart';
import '../services/process_service.dart';
import '../services/privilege_service.dart';
import '../services/app_data_service.dart';
import '../services/ffvpn/ffvpn_upstream_builder.dart';
import '../services/lantern/lantern_upstream_builder.dart';
import '../services/lantern/lantern_cli_service.dart';
import '../services/psiphon_config_builder.dart';
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
import '../services/recovery/recovery_coordinator.dart';
import '../services/diagnostics/connectivity_probe.dart';
import '../services/network/network_change_detector.dart';
import '../services/watchdog/tunnel_watchdog.dart';
import '../services/health/tunnel_health_models.dart';
import '../services/health/tunnel_health_registry.dart';
import '../constants/default_lists.dart';
import 'internet_quality_provider.dart';
import '../services/wireguard/wireguard_config_parser.dart';
import '../services/wireguard/wireguard_config_builder.dart';
import '../services/wireguard/wireguard_paths.dart';
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
part 'psiphon/psiphon_launch.dart';
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
part 'app_provider_constructor.dart';
part 'app_provider_dispose.dart';
part 'app_provider_public_actions.dart';
part 'app_provider_health_helpers.dart';
part 'app_provider_tunnel_helpers.dart';
part 'app_provider_log_watchers_verify.dart';
part 'app_provider_lifecycle_shutdown.dart';
part 'app_provider_process_listener_sync.dart';

class AppProvider extends ChangeNotifier {
  final ProcessService processService = ProcessService();

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

  late RecoveryCoordinator _recoveryCoordinator;
  RecoveryCoordinator get recoveryCoordinator => _recoveryCoordinator;

  late ConnectivityProbe _connectivityProbe;
  ConnectivityProbe get connectivityProbe => _connectivityProbe;

  late NetworkChangeDetector _networkChangeDetector;
  NetworkChangeDetector get networkChangeDetector => _networkChangeDetector;

  late TunnelHealthRegistry _healthRegistry;
  TunnelHealthRegistry get healthRegistry => _healthRegistry;

  InternetQualityProvider? _qualityProvider;
  InternetQualityProvider? get qualityProvider => _qualityProvider;

  int _psiphonGeneration = 0;
  int _torGeneration = 0;
  int _sstpGeneration = 0;
  int get psiphonGeneration => _psiphonGeneration;
  int get torGeneration => _torGeneration;
  int get sstpGeneration => _sstpGeneration;
  int nextPsiphonGeneration() => ++_psiphonGeneration;
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
  bool loggingEnabled = true;
  String torStatus = 'Tor: Ready';
  String sstpStatus = 'SSTP: Ready';
  bool isElevated = false;
  bool isAutoTesting = false;
  bool userStoppedPsiphon = true;
  bool userStoppedTor = true;
  bool userStoppedSstp = true;
  bool isShuttingDown = false;
  bool restartingPsiphon = false;
  bool restartingTor = false;
  bool restartingSstp = false;

  AppProvider() {
    initializeAppProvider(this);
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
