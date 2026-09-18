import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'app_data_service.dart';
import 'log_line_parsers.dart';
import 'port_manager.dart';
import 'process/log_source.dart';
import 'process/log_store.dart';
import 'process/process_notifications.dart';
import 'process/process_forwarder.dart';
import 'process/process_happy_detector.dart';
import 'process/process_tunnel_state.dart';
import 'process/process_protocol_state.dart';
import 'process/process_notification_messages.dart';

export 'process/log_source.dart' show LogSource;

part 'process_service_helpers.dart';
part 'process_service_aether_lan.dart';
part 'process_service_lan.dart';

part 'psiphon/psiphon_process_starter.dart';
part 'psiphon/psiphon_log_listener.dart';
part 'psiphon_stopper.dart';
part 'process_service_psiphon.dart';

part 'aether_starter.dart';
part 'aether_stopper.dart';

part 'tor_launcher.dart';
part 'tor_stopper.dart';
part 'process_service_tor.dart';

part 'sstp_launcher.dart';
part 'sstp_stopper.dart';
part 'process_service_sstp.dart';

class ProcessService extends ChangeNotifier
    with ProcessNotifications
    implements
        ProcessTunnelState,
        ProcessProtocolState,
        ProcessNotificationMessages {
  @override
  bool isPsiphonRunning = false;

  @override
  bool isAetherRunning = false;

  @override
  bool isTorRunning = false;

  @override
  bool isSstpRunning = false;

  @override
  bool isPsiphonConnected = false;

  @override
  bool isTorConnected = false;

  @override
  bool isSstpConnected = false;

  @override
  bool isSstpTunnelReady = false;

  @override
  String? sstpAssignedIp;

  @override
  int torBootstrapProgress = 0;

  @override
  String? lastPsiphonProtocol;

  @override
  String? pendingProtocolNotification;

  @override
  String? pendingProtocolBinary;

  @override
  String? currentPsiphonBinaryName;

  @override
  void clearPendingProtocolNotification() {
    pendingProtocolNotification = null;
    pendingProtocolBinary = null;
  }

  @override
  String? lastAetherProtocol;

  @override
  String? pendingAetherProtocolNotification;

  @override
  void clearPendingAetherProtocolNotification() {
    pendingAetherProtocolNotification = null;
  }

  @override
  void setAetherProtocolNotification(String protocol) {
    lastAetherProtocol = protocol;
    pendingAetherProtocolNotification = protocol;
  }

  @override
  String? lastTorTransport;

  @override
  String? pendingTorNotification;

  @override
  String? pendingTorTransportDetail;

  @override
  String? pendingTorTransportType;

  @override
  String? pendingTorTransportDetailPrepared;

  @override
  void clearPendingTorNotification() {
    pendingTorNotification = null;
    pendingTorTransportDetail = null;
  }

  @override
  void prepareTorNotification(String transport, String detail) {
    pendingTorTransportType = transport;
    pendingTorTransportDetailPrepared = detail;
  }

  @override
  void setTorNotification(String transport, String detail) {
    lastTorTransport = transport;
    pendingTorNotification = transport;
    pendingTorTransportDetail = detail;
  }

  @override
  void resetTorState() {
    torBootstrapProgress = 0;
    pendingTorTransportType = null;
    pendingTorTransportDetailPrepared = null;
    lastTorTransport = null;
  }

  @override
  String? lastSstpServer;

  @override
  String? pendingSstpNotification;

  @override
  String? pendingSstpTransportDetail;

  @override
  String? pendingSstpTransportType;

  @override
  void clearPendingSstpNotification() {
    pendingSstpNotification = null;
    pendingSstpTransportDetail = null;
    pendingSstpTransportType = null;
  }

  @override
  void prepareSstpNotification(String serverInfo, String detail) {
    pendingSstpTransportType = serverInfo;
    pendingSstpTransportDetail = detail;
  }

  @override
  void setSstpNotification(String serverInfo, {String detail = ''}) {
    lastSstpServer = serverInfo;
    pendingSstpNotification = serverInfo;
    pendingSstpTransportDetail = detail.isNotEmpty
        ? detail
        : 'Server: $serverInfo';
  }

  @override
  String? pendingPortConflictMessage;

  @override
  void setPortConflictMessage(String message) {
    pendingPortConflictMessage = message;
    notifyListeners();
  }

  @override
  void clearPortConflictMessage() {
    pendingPortConflictMessage = null;
  }

  @override
  String? pendingBinaryMissingMessage;

  @override
  void setBinaryMissingMessage(String message) {
    pendingBinaryMissingMessage = message;
    notifyListeners();
  }

  @override
  void clearBinaryMissingMessage() {
    pendingBinaryMissingMessage = null;
  }

  @override
  String? pendingSadNotification;

  @override
  DateTime? pendingSadTimestamp;

  @override
  void setSadNotification(String tunnelName) {
    pendingSadNotification = tunnelName;
    pendingSadTimestamp = DateTime.now();
    notifyListeners();
  }

  @override
  void clearSadNotification() {
    pendingSadNotification = null;
    pendingSadTimestamp = null;
  }

  @override
  String? pendingHappyNotification;

  @override
  DateTime? pendingHappyTimestamp;

  @override
  void setHappyNotification(String tunnelName) {
    pendingHappyNotification = tunnelName;
    pendingHappyTimestamp = DateTime.now();
    notifyListeners();
  }

  @override
  void clearHappyNotification() {
    pendingHappyNotification = null;
    pendingHappyTimestamp = null;
  }

  Process? psiphonProcess;
  Process? aetherProcess;
  Process? torProcess;
  Process? sstpProcess;

  ServerSocket? psiphonSocksForwarder;
  ServerSocket? psiphonHttpForwarder;
  ServerSocket? torSocksForwarder;
  ServerSocket? torHttpForwarder;

  final LogStore _logStore = LogStore();
  Stream<String> get logStream => _logStore.stream;
  List<String> get fullLog => _logStore.fullLog;

  bool _initialized = false;

  late final ProcessForwarder forwarder = ProcessForwarder(
    addLog: (message, {source = LogSource.empty}) =>
        addLog(message, source: source),
  );

  late final ProcessHappyDetector _happyDetector = ProcessHappyDetector(
    onHappy: _fireHappyNotification,
  );

  void _fireHappyNotification(String tunnelName) {
    setHappyNotification(tunnelName);
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

  int? get aetherPid => aetherProcess?.pid;
  int? get psiphonPid => psiphonProcess?.pid;
  int? get torPid => torProcess?.pid;
  int? get sstpPid => sstpProcess?.pid;

  void touch() => notifyListeners();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await AppDataService.initializeDataFiles();
    for (final msg in AppDataService.initLogs) {
      addLog(msg, source: LogSource.system);
    }
    _initialized = true;
  }

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

  static Future<bool> isPortInUse(int port) async {
    return PortManager.isInUse(port);
  }

  Future<int> findFreePort() => PortManager.findFree(preferred: const []);

  @override
  void dispose() {
    _logStore.dispose();
    super.dispose();
  }
}
