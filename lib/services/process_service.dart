import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

// ═══════════════════════════════════════════════════════════════
//  ⚠️ ترتیب importها مهم است:
//   1. همه importها اول
//   2. همه partها بعد از importها
//   3. سپس declarationها (کلاس، enum، typedef، …)
//
//  ❌ هیچ typedef یا declaration نباید قبل از partها بیاید.
// ═══════════════════════════════════════════════════════════════
import '../models/wireguard_core_type.dart';
import 'app_data_service.dart';
import 'ffvpn/ffvpn_upstream_builder.dart';
import 'geph/geph_cli_service.dart';
import 'health/tunnel_health_models.dart' show TunnelKind;
import 'health/tunnel_health_tester.dart';
import 'lantern/lantern_cli_service.dart';
import 'log_line_parsers.dart';
import 'npv/npv_args.dart';
import 'npv/npv_server_list.dart';
import 'port_manager.dart';
import 'process/log_source.dart';
import 'process/log_store.dart';
import 'process/process_notifications.dart';
import 'process/process_forwarder.dart';
import 'process/process_happy_detector.dart';
import 'process/process_tunnel_state.dart';
import 'process/process_protocol_state.dart';
import 'process/process_notification_messages.dart';
import 'wireguard/wireguard_paths.dart';

// ═══════════════════════════════════════════════════════════════
//  ✅ همه importها اینجا تمام شدند.
//  ✅ حالا partها (فقط یک بلوک، بدون هیچ declaration قبل از آنها)
// ═══════════════════════════════════════════════════════════════

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
part 'process_service_wireguard.dart';
part 'process_service_ffvpn.dart';
part 'process_service_lantern.dart';
part 'process_service_geph.dart';
part 'process_service_npv.dart';

class ProcessService extends ChangeNotifier
    with ProcessNotifications
    implements
        ProcessTunnelState,
        ProcessProtocolState,
        ProcessNotificationMessages {
  // ═══════════════════════════════════════════════════════════════
  //  Tunnel running flags
  // ═══════════════════════════════════════════════════════════════

  bool isWireGuardRunning = false;

  bool isWireGuardConnected = false;

  bool isWireGuardTunnelReady = false;

  Process? wireGuardProcess;

  int? get wireGuardPid => wireGuardProcess?.pid;

  @override
  bool isPsiphonRunning = false;

  @override
  bool isAetherRunning = false;

  @override
  bool isAetherTunnelReady = false;

  /// آخرین خطایی که خود هستهٔ Aether پیش از validate شدن تونل گزارش کرد
  /// (مثلاً `connect-ip status: 400` برای endpoint سنجاق‌شده). تا وقتی
  /// تونل ready نشده، presence یعنی این attempt بی‌فایده است و نباید
  /// منتظر timeout پروب ماند.
  String? aetherAttemptError;

  @override
  bool isTorRunning = false;

  @override
  bool isSstpRunning = false;

  bool isFfvpnRunning = false;

  bool isFfvpnConnected = false;

  bool isLanternRunning = false;

  bool isLanternConnected = false;

  bool isGephRunning = false;

  bool isGephConnected = false;

  bool isNpvRunning = false;

  bool isNpvConnected = false;

  /// remark کانفیگی که npv بعد از سنجش انتخاب کرده (برای نمایش در status).
  String npvSelectedConfig = '';

  /// نتیجهٔ `npv list -json`: فهرست کانفیگ‌ها و سنجش آن‌ها.
  NpvServerList? npvServerList;

  bool isNpvScanning = false;

  /// سنجش توسط کاربر قطع شده تا exit-code غیرصفرِ kill خطا تلقی نشود.
  bool npvScanCancelled = false;

  /// خطای آخرین سنجش؛ null یعنی بی‌خطا.
  String? npvScanError;

  /// آیا آخرین سنجش واقعاً ترافیک رد کرده بود (-check) یا فقط فهرست بود.
  bool npvScanChecked = false;

  DateTime? npvScanTime;

  /// فایل کانفیگی که آخرین سنجش روی آن انجام شد؛ اتصال فقط وقتی از نتیجه
  /// استفاده می‌کند که همین فایل هنوز انتخاب شده باشد.
  String npvScanConfigPath = '';

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

  bool suppressSadNotification = false;

  // ═══════════════════════════════════════════════════════════════
  //  🆕 SSTP intentional stop flag
  //
  //  جلوگیری از دوبار صدا زدن onSstpStopped:
  //    • stopSstp() آن را true می‌کند
  //    • exitCode listener آن را چک و reset می‌کند
  // ═══════════════════════════════════════════════════════════════
  bool sstpStoppedIntentionally = false;

  // ═══════════════════════════════════════════════════════════════
  //  Psiphon protocol state
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Aether protocol state
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Tor protocol state
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  SSTP protocol state
  // ═══════════════════════════════════════════════════════════════

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
    pendingSstpTransportDetail =
        detail.isNotEmpty ? detail : 'Server: $serverInfo';
  }

  // ═══════════════════════════════════════════════════════════════
  //  Port conflict message
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Binary missing message
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Sad notification
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Happy notification
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Process handles
  // ═══════════════════════════════════════════════════════════════

  Process? psiphonProcess;
  Process? aetherProcess;
  Process? torProcess;
  Process? sstpProcess;
  Process? ffvpnProcess;
  Process? lanternProcess;
  Process? gephProcess;
  Process? npvProcess;
  Process? npvScanProcess;

  // ═══════════════════════════════════════════════════════════════
  //  Forwarder sockets
  // ═══════════════════════════════════════════════════════════════

  ServerSocket? psiphonSocksForwarder;
  ServerSocket? psiphonHttpForwarder;
  ServerSocket? torSocksForwarder;
  ServerSocket? torHttpForwarder;

  // ═══════════════════════════════════════════════════════════════
  //  Log store
  // ═══════════════════════════════════════════════════════════════

  final LogStore _logStore = LogStore();
  Stream<String> get logStream => _logStore.stream;
  List<String> get fullLog => _logStore.fullLog;

  /// منابع فعال لاگ.
  Set<String> get enabledLogSources => _logStore.enabledSources;

  /// به‌روزرسانی منابع فعال لاگ.
  void setEnabledLogSources(Set<String> sources) {
    _logStore.setEnabledSources(sources);
    notifyListeners();
  }

  bool _initialized = false;

  // ═══════════════════════════════════════════════════════════════
  //  Forwarder + happy detector
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  PID getters
  // ═══════════════════════════════════════════════════════════════

  int? get aetherPid => aetherProcess?.pid;
  int? get psiphonPid => psiphonProcess?.pid;
  int? get torPid => torProcess?.pid;
  int? get sstpPid => sstpProcess?.pid;
  int? get ffvpnPid => ffvpnProcess?.pid;
  int? get lanternPid => lanternProcess?.pid;
  int? get gephPid => gephProcess?.pid;
  int? get npvPid => npvProcess?.pid;

  // ═══════════════════════════════════════════════════════════════
  //  Lifecycle
  // ═══════════════════════════════════════════════════════════════

  void touch() => notifyListeners();

  /// callback برای شروع keepalive (از AppProvider ست می‌شه).
  void Function(int socksPort)? onSstpTunnelReady;

  /// callback برای توقف keepalive.
  void Function()? onSstpStopped;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await AppDataService.initializeDataFiles();
    for (final msg in AppDataService.initLogs) {
      addLog(msg, source: LogSource.system);
    }
    _initialized = true;
  }

  // ═══════════════════════════════════════════════════════════════
  //  Logging
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  //  Port utilities
  // ═══════════════════════════════════════════════════════════════

  static Future<bool> isPortInUse(int port) async {
    return PortManager.isInUse(port);
  }

  Future<int> findFreePort() => PortManager.findFree(preferred: const []);

  // ═══════════════════════════════════════════════════════════════
  //  Dispose
  // ═══════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _logStore.dispose();
    super.dispose();
  }
}
