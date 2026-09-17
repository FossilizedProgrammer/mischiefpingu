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
import '../constants/default_lists.dart';

part 'app_provider_lifecycle.dart';
part 'app_provider_lifecycle_persistence.dart';
part 'app_provider_parsers.dart';
part 'app_provider_psiphon.dart';
part 'app_provider_psiphon_preflight.dart';
part 'app_provider_aether.dart';
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
        processService.addLog(
          '⚠ logStream error: $e',
          source: LogSource.app,
        );
      },
    );

    _aetherTestService = AetherAutoTestService(
      processService: processService,
      settings: settings,
    );

    Future.microtask(initializeProvider);
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
    try {
      _aetherTestService.requestCancel();
    } catch (_) {}
  }

  Future<void> shutdownAll() => shutdownAllInternal();

  @override
  void dispose() {
    isShuttingDown = true;

    _watchdogManager?.disposeAll();

    _logSubscription?.cancel();
    _logSubscription = null;

    _aetherTestService.requestCancel();
    _reconnectManager.cancelAll();
    processService.removeListener(handleProcessServiceChange);
    super.dispose();
  }
}
