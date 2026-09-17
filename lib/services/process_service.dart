// lib/services/process_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'app_data_service.dart';
import 'log_line_parsers.dart';
import 'port_manager.dart';
import 'process/log_source.dart';
import 'process/log_store.dart'; // ← جدید
import 'process/process_notifications.dart';
import 'process/process_forwarder.dart';
import 'process/process_happy_detector.dart';

// ─── Re-export ───
export 'process/log_source.dart' show LogSource;

// ─── helpers ───
part 'process_service_helpers.dart';
part 'process_service_aether_lan.dart';

// ─── Psiphon ───
part 'psiphon_launcher.dart';
part 'psiphon_stopper.dart';
part 'process_service_psiphon.dart';

// ─── Aether ───
part 'aether_starter.dart';
part 'aether_stopper.dart';

// ─── Tor ───
part 'tor_launcher.dart';
part 'tor_stopper.dart';
part 'process_service_tor.dart';

// ─── SSTP ───
part 'sstp_launcher.dart';
part 'sstp_stopper.dart';
part 'process_service_sstp.dart';

class ProcessService extends ChangeNotifier with ProcessNotifications {
  // ═══════════════════════════════════════════════════════════════
  //  Process fields
  // ═══════════════════════════════════════════════════════════════
  Process? psiphonProcess;
  Process? aetherProcess;
  Process? torProcess;
  Process? sstpProcess;

  // ─── Forwarders ───
  ServerSocket? psiphonSocksForwarder;
  ServerSocket? psiphonHttpForwarder;
  ServerSocket? torSocksForwarder;
  ServerSocket? torHttpForwarder;

  // ─── Log store (جدا شده) ───
  final LogStore _logStore = LogStore();
  Stream<String> get logStream => _logStore.stream;
  List<String> get fullLog => _logStore.fullLog;

  bool _initialized = false;

  late final ProcessForwarder forwarder = ProcessForwarder(
    addLog: (message, {source = LogSource.empty}) =>
        addLog(message, source: source),
  );

  // ═══════════════════════════════════════════════════════════════
  //  Happy detector
  // ═══════════════════════════════════════════════════════════════
  late final ProcessHappyDetector _happyDetector = ProcessHappyDetector(
    onHappy: _fireHappyNotification,
  );

  void _fireHappyNotification(String tunnelName) {
    setHappyNotification(tunnelName);
    notifyListeners();
  }

  void checkHappyTransition({
    required String tunnelName,
    required bool wasConnected,
    required bool isConnected,
  }) {
    _happyDetector.checkTransition(
      tunnelName: tunnelName,
      wasConnected: wasConnected,
      isConnected: isConnected,
    );
  }

  // ═══════════════════════════════════════════
  //  Override — برای notifyListeners
  // ═══════════════════════════════════════════
  @override
  void setPortConflictMessage(String message) {
    super.setPortConflictMessage(message);
    notifyListeners();
  }

  @override
  void setBinaryMissingMessage(String message) {
    super.setBinaryMissingMessage(message);
    notifyListeners();
  }

  @override
  void setSadNotification(String tunnelName) {
    super.setSadNotification(tunnelName);
    notifyListeners();
  }

  @override
  void setHappyNotification(String tunnelName) {
    super.setHappyNotification(tunnelName);
    notifyListeners();
  }

  // ─── PID getters ───
  int? get aetherPid => aetherProcess?.pid;
  int? get psiphonPid => psiphonProcess?.pid;
  int? get torPid => torProcess?.pid;
  int? get sstpPid => sstpProcess?.pid;

  // ─── Lifecycle ───
  void touch() => notifyListeners();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await AppDataService.initializeDataFiles();
    for (final msg in AppDataService.initLogs) {
      addLog(msg, source: LogSource.system);
    }
    _initialized = true;
  }

  // ─── Logging (delegate به LogStore) ───
  void addLog(String message, {String source = LogSource.empty}) {
    _logStore.add(message, source: source);
    notifyListeners();
  }

  bool get loggingEnabled => _logStore.enabled;
  set loggingEnabled(bool v) {
    _logStore.enabled = v;
    notifyListeners();
  }

  void clearLog() {
    _logStore.clear();
    notifyListeners();
  }

  // ─── Port check (static) ───
  static Future<bool> isPortInUse(int port) async {
    return PortManager.isInUse(port);
  }

  Future<int> findFreePort() => PortManager.findFree(preferred: const []);

  // ─── LAN forwarders (delegating) ───
  Future<void> startDartLanForwarders({
    required int publicSocksPort,
    required int publicHttpPort,
    required int internalSocksPort,
    required int internalHttpPort,
    required String source,
  }) =>
      forwarder.startDartLanForwarders(
        publicSocksPort: publicSocksPort,
        publicHttpPort: publicHttpPort,
        internalSocksPort: internalSocksPort,
        internalHttpPort: internalHttpPort,
        source: source,
        onReady: (socks, http) {
          psiphonSocksForwarder = socks;
          psiphonHttpForwarder = http;
        },
      );

  Future<ServerSocket?> createForwarder({
    required int publicPort,
    required int internalPort,
    required String label,
    required String source,
  }) =>
      forwarder.createForwarder(
        publicPort: publicPort,
        internalPort: internalPort,
        label: label,
        source: source,
      );

  @override
  void dispose() {
    _logStore.dispose();
    super.dispose();
  }
}
