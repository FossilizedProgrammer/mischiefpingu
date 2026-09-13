// lib/providers/app_provider.dart
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
import '../constants/default_lists.dart';

part 'app_provider_lifecycle.dart';
part 'app_provider_parsers.dart';
part 'app_provider_psiphon.dart';
part 'app_provider_aether.dart';
part 'app_provider_tor.dart';               
part 'app_provider_tor_upstream.dart';
part 'app_provider_sstp.dart';              
part 'app_provider_sstp_upstream.dart';


class AppProvider extends ChangeNotifier {
  final ProcessService processService = ProcessService();
  late final AetherAutoTestService _aetherTestService;
  AetherAutoTestService get aetherTestService => _aetherTestService;

  final SettingsPersistenceService persistence = SettingsPersistenceService();
  final AutoReconnectManager _reconnectManager = AutoReconnectManager();
  AutoReconnectManager get reconnectManager => _reconnectManager;

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

  String cleanIp(String ip) => ip.replaceAll(r'\', '').trim();
  List<String> cleanIpList(List<String> list) =>
      list.map(cleanIp).where((e) => e.isNotEmpty).toSet().toList();

  AppProvider() {
    processService.ensureInitialized();
    processService.addListener(_onProcessServiceChanged);
    _aetherTestService = AetherAutoTestService(
      processService: processService,
      settings: settings,
    );
    Future.microtask(initializeProvider);
  }

  void _onProcessServiceChanged() {
    if (isShuttingDown) return;

    final logs = processService.fullLog;
    if (logs.isNotEmpty) {
      tryParseFoundFronting(logs.last);
      tryParseBuildRev(logs.last);
    }

    if (!processService.isPsiphonRunning &&
        !userStoppedPsiphon &&
        settings.autoReconnectPsiphon &&
        !isPsiphonBusy &&
        !isAutoTesting) {
      _reconnectManager.schedulePsiphonReconnect(
        shouldReconnect: () =>
            !processService.isPsiphonRunning &&
            !userStoppedPsiphon &&
            settings.autoReconnectPsiphon &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !isShuttingDown,
        onReconnect: () => connectPsiphon(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isAetherRunning &&
        !userStoppedAether &&
        !isAutoTesting &&
        settings.autoReconnectAether &&
        !isPsiphonBusy) {
      _reconnectManager.scheduleAetherReconnect(
        shouldReconnect: () =>
            !processService.isAetherRunning &&
            !userStoppedAether &&
            settings.autoReconnectAether &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !isShuttingDown,
        onReconnect: () => connectAether(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isTorRunning &&
        !userStoppedTor &&
        settings.autoReconnectTor &&
        !isTorBusy &&
        !isAutoTesting) {
      _reconnectManager.scheduleTorReconnect(
        shouldReconnect: () =>
            !processService.isTorRunning &&
            !userStoppedTor &&
            settings.autoReconnectTor &&
            !isTorBusy &&
            !isAutoTesting &&
            !isShuttingDown,
        onReconnect: () => connectTor(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isSstpRunning &&
        !userStoppedSstp &&
        settings.autoReconnectSstp &&
        !isSstpBusy &&
        !isAutoTesting) {
      _reconnectManager.scheduleSstpReconnect(
        shouldReconnect: () =>
            !processService.isSstpRunning &&
            !userStoppedSstp &&
            settings.autoReconnectSstp &&
            !isSstpBusy &&
            !isAutoTesting &&
            !isShuttingDown,
        onReconnect: () => connectSstp(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (processService.isTorRunning) {
      if (processService.isTorConnected) {
        torStatus = 'Tor: Connected';
      } else if (torStatus == 'Tor: Ready' || torStatus == 'Tor: Stopped') {
        torStatus = 'Tor: Bootstrapping…';
      }
    }

    if (processService.isSstpRunning) {
      if (processService.isSstpConnected) {
        sstpStatus = 'SSTP: Connected';
      } else if (sstpStatus == 'SSTP: Ready' ||
          sstpStatus == 'SSTP: Stopped') {
        sstpStatus = 'SSTP: Connecting…';
      }
    }

    notifyListeners();
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

  // ─── Delegating wrappers ───
  Future<void> setLoggingEnabled(bool value) =>
      setLoggingEnabledInternal(value);
  Future<void> saveSettings() => saveSettingsInternal();
  Future<void> saveIpList(List<String> list) => saveIpListInternal(list);
  Future<void> saveHttpHostList(List<String> list) =>
      saveHttpHostListInternal(list);
  Future<void> saveTlsSniList(List<String> list) =>
      saveTlsSniListInternal(list);

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
    try {
      _aetherTestService.requestCancel();
    } catch (_) {}
  }

  Future<void> shutdownAll() => shutdownAllInternal();

  @override
  void dispose() {
    isShuttingDown = true;
    _aetherTestService.requestCancel();
    _reconnectManager.cancelAll();
    processService.removeListener(_onProcessServiceChanged);
    super.dispose();
  }
}
