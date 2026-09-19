import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/settings_model.dart';
import '../services/process_service.dart';
import '../services/privilege_service.dart';
import '../services/app_data_service.dart';
import '../services/aether_auto_test_service.dart';
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
import '../services/watchdog/tunnel_watchdog.dart';
import '../constants/default_lists.dart';
import 'internet_quality_provider.dart';

part 'app_provider_lifecycle.dart';
part 'app_provider_lifecycle_persistence.dart';
part 'app_provider_parsers.dart';
part 'app_provider_psiphon.dart';
part 'app_provider_psiphon_preflight.dart';
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
part 'app_provider_reconnect.dart';
part 'app_provider_log_watchers.dart';
part 'app_provider_process_listener.dart';
part 'app_provider_wrappers.dart';

class AppProvider extends ChangeNotifier {
  final ProcessService processService = ProcessService();
  late final AetherAutoTestService _aetherTestService;
  AetherAutoTestService get aetherTestService => _aetherTestService;

  final SettingsPersistenceService persistence = SettingsPersistenceService();
  final AutoReconnectManager _reconnectManager = AutoReconnectManager();
  AutoReconnectManager get reconnectManager => _reconnectManager;

  /// ═══════════════════════════════════════════════════════════════
  ///  RecoveryCoordinator — جلوگیری از restart همزمان
  /// ═══════════════════════════════════════════════════════════════
  late final RecoveryCoordinator _recoveryCoordinator;
  RecoveryCoordinator get recoveryCoordinator => _recoveryCoordinator;

  /// ═══════════════════════════════════════════════════════════════
  ///  ConnectivityProbe — تشخیص سریع Internet vs Tunnel
  /// ═══════════════════════════════════════════════════════════════
  late final ConnectivityProbe _connectivityProbe;
  ConnectivityProbe get connectivityProbe => _connectivityProbe;

  /// ═══════════════════════════════════════════════════════════════
  ///  InternetQualityProvider — کیفیت کامل اینترنت (اختیاری)
  ///
  ///  از طریق main.dart inject می‌شود تا watchdog به کیفیت
  ///  دقیق‌تر دسترسی داشته باشد. اگر null باشد، از
  ///  ConnectivityProbe ساده استفاده می‌شود.
  /// ═══════════════════════════════════════════════════════════════
  InternetQualityProvider? _qualityProvider;
  InternetQualityProvider? get qualityProvider => _qualityProvider;

  /// تزریق provider کیفیت از main.dart.
  void attachQualityProvider(InternetQualityProvider provider) {
    _qualityProvider = provider;
    processService.addLog(
      '→ AppProvider: InternetQualityProvider attached '
      '(watchdog will use full quality diagnostics)',
      source: LogSource.app,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  Generation counters — جلوگیری از race condition در callbackها
  /// ═══════════════════════════════════════════════════════════════
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

  late final PsiphonLogWatcher _psiphonLog;
  late final TorLogWatcher _torLog;
  late final SstpLogWatcher _sstpLog;

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

  String cleanIp(String ip) => ip.replaceAll(r'\', '').trim();
  List<String> cleanIpList(List<String> list) =>
      list.map(cleanIp).where((e) => e.isNotEmpty).toSet().toList();

  AppProvider() {
    processService.ensureInitialized();
    processService.addListener(handleProcessServiceChange);

    _psiphonLog = PsiphonLogWatcher(log: processService.addLog);
    _torLog = TorLogWatcher(log: processService.addLog);
    _sstpLog = SstpLogWatcher(log: processService.addLog);

    _logSubscription = processService.logStream.listen(
      feedLogWatchers,
      onError: (e) {
        processService.addLog('⚠ logStream error: $e', source: LogSource.app);
      },
    );

    _aetherTestService = AetherAutoTestService(
      processService: processService,
      settings: settings,
    );

    _recoveryCoordinator = RecoveryCoordinator(log: processService.addLog);
    _connectivityProbe = ConnectivityProbe(log: processService.addLog);

    _reconnectManager.acquireLease = (tunnel) async {
      final tunnelName = _tunnelDisplayName(tunnel);
      final lease = _recoveryCoordinator.tryAcquire(
        tunnel: tunnelName,
        action: RecoveryAction.autoReconnect,
        reason: 'process exited unexpectedly',
      );
      return lease != null;
    };

    _reconnectManager.releaseLease = (tunnel) {
      final tunnelName = _tunnelDisplayName(tunnel);
      _recoveryCoordinator.releaseLeaseByTunnel(tunnelName);
    };

    Future.microtask(initializeProvider);
  }

  String _tunnelDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'psiphon':
        return 'Psiphon';
      case 'aether':
        return 'Aether';
      case 'tor':
        return 'Tor';
      case 'sstp':
        return 'SSTP';
      default:
        return key;
    }
  }

  void touch() {
    if (isShuttingDown) return;
    notifyListeners();
  }

  Future<void> applyScannerResults({
    required List<String> ips,
    String? tlsSni,
  }) async {
    if (ips.isEmpty) return;
    final merged = <String>{...ipList, ...ips}.toList();
    await saveIpList(merged);
    settings.ip = ips.first;
    if (tlsSni != null && tlsSni.isNotEmpty) {
      settings.tlsSni = tlsSni;
      if (!tlsSniList.contains(tlsSni)) {
        await saveTlsSniList([...tlsSniList, tlsSni]);
      }
    }
    settings.isFronted = true;
    settings.useSunAndLion = true;
    settings.upstreamType = 0;
    await saveSettings();
    notifyListeners();
  }

  void applySetting(int number) {
    settings.applyPreset(number);
    saveSettings();
    notifyListeners();
  }

  Future<void> copyLogToClipboard() async {
    final text = processService.fullLog.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
  }

  void cancelAllAutoReconnect() {
    _reconnectManager.cancelAll();
    _watchdogManager?.stopAll();
    _recoveryCoordinator.releaseAll();
    try {
      _aetherTestService.requestCancel();
    } catch (_) {}
  }

  Future<void> shutdownAll() => shutdownAllInternal();

  @override
  void dispose() {
    isShuttingDown = true;

    _watchdogManager?.disposeAll();
    _recoveryCoordinator.dispose();

    _logSubscription?.cancel();
    _logSubscription = null;

    _aetherTestService.requestCancel();
    _reconnectManager.cancelAll();
    processService.removeListener(handleProcessServiceChange);
    super.dispose();
  }
}

/// snapshot از state تونل‌ها برای تشخیص تغییر واقعی.
class _TunnelStateSnapshot {
  final bool psiphonRunning;
  final bool psiphonConnected;
  final bool aetherRunning;
  final bool torRunning;
  final bool torConnected;
  final int torBootstrapProgress;
  final bool sstpRunning;
  final bool sstpConnected;

  const _TunnelStateSnapshot({
    required this.psiphonRunning,
    required this.psiphonConnected,
    required this.aetherRunning,
    required this.torRunning,
    required this.torConnected,
    required this.torBootstrapProgress,
    required this.sstpRunning,
    required this.sstpConnected,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TunnelStateSnapshot &&
        other.psiphonRunning == psiphonRunning &&
        other.psiphonConnected == psiphonConnected &&
        other.aetherRunning == aetherRunning &&
        other.torRunning == torRunning &&
        other.torConnected == torConnected &&
        other.torBootstrapProgress == torBootstrapProgress &&
        other.sstpRunning == sstpRunning &&
        other.sstpConnected == sstpConnected;
  }

  @override
  int get hashCode => Object.hash(
        psiphonRunning,
        psiphonConnected,
        aetherRunning,
        torRunning,
        torConnected,
        torBootstrapProgress,
        sstpRunning,
        sstpConnected,
      );
}
