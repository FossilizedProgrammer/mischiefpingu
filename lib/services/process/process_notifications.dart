// lib/services/process/process_notifications.dart
//
// ⚠️ اضافه شد: happy notification (وقتی اتصال برقرار می‌شود)
library;

mixin ProcessNotifications {
  // ═══════════════════════════════════════════
  //  Running / Connected state
  // ═══════════════════════════════════════════
  bool isPsiphonRunning = false;
  bool isAetherRunning = false;
  bool isTorRunning = false;
  bool isSstpRunning = false;

  bool isPsiphonConnected = false;
  bool isTorConnected = false;
  bool isSstpConnected = false;
  bool isSstpTunnelReady = false;
  String? sstpAssignedIp;

  // ═══════════════════════════════════════════
  //  Psiphon protocol
  // ═══════════════════════════════════════════
  String? lastPsiphonProtocol;
  String? pendingProtocolNotification;
  String? pendingProtocolBinary;
  String? currentPsiphonBinaryName;

  void clearPendingProtocolNotification() {
    pendingProtocolNotification = null;
    pendingProtocolBinary = null;
  }

  // ═══════════════════════════════════════════
  //  Aether protocol
  // ═══════════════════════════════════════════
  String? lastAetherProtocol;
  String? pendingAetherProtocolNotification;

  void clearPendingAetherProtocolNotification() {
    pendingAetherProtocolNotification = null;
  }

  void setAetherProtocolNotification(String protocol) {
    lastAetherProtocol = protocol;
    pendingAetherProtocolNotification = protocol;
  }

  // ═══════════════════════════════════════════
  //  Tor bootstrap + transport
  // ═══════════════════════════════════════════
  int torBootstrapProgress = 0;
  String? lastTorTransport;
  String? pendingTorNotification;
  String? pendingTorTransportDetail;
  String? pendingTorTransportType;
  String? pendingTorTransportDetailPrepared;

  void clearPendingTorNotification() {
    pendingTorNotification = null;
    pendingTorTransportDetail = null;
  }

  void prepareTorNotification(String transport, String detail) {
    pendingTorTransportType = transport;
    pendingTorTransportDetailPrepared = detail;
  }

  void setTorNotification(String transport, String detail) {
    lastTorTransport = transport;
    pendingTorNotification = transport;
    pendingTorTransportDetail = detail;
  }

  void resetTorState() {
    torBootstrapProgress = 0;
    pendingTorTransportType = null;
    pendingTorTransportDetailPrepared = null;
    lastTorTransport = null;
  }

  // ═══════════════════════════════════════════
  //  SSTP
  // ═══════════════════════════════════════════
  String? lastSstpServer;
  String? pendingSstpNotification;
  String? pendingSstpTransportDetail;
  String? pendingSstpTransportType;

  void clearPendingSstpNotification() {
    pendingSstpNotification = null;
    pendingSstpTransportDetail = null;
    pendingSstpTransportType = null;
  }

  void prepareSstpNotification(String serverInfo, String detail) {
    pendingSstpTransportType = serverInfo;
    pendingSstpTransportDetail = detail;
  }

  void setSstpNotification(String serverInfo, {String detail = ''}) {
    lastSstpServer = serverInfo;
    pendingSstpNotification = serverInfo;
    pendingSstpTransportDetail =
        detail.isNotEmpty ? detail : 'Server: $serverInfo';
  }

  // ═══════════════════════════════════════════
  //  Port conflict
  // ═══════════════════════════════════════════
  String? pendingPortConflictMessage;

  void setPortConflictMessage(String message) {
    pendingPortConflictMessage = message;
  }

  void clearPortConflictMessage() {
    pendingPortConflictMessage = null;
  }

  // ═══════════════════════════════════════════
  //  Binary missing
  // ═══════════════════════════════════════════
  String? pendingBinaryMissingMessage;

  void setBinaryMissingMessage(String message) {
    pendingBinaryMissingMessage = message;
  }

  void clearBinaryMissingMessage() {
    pendingBinaryMissingMessage = null;
  }

  // ═══════════════════════════════════════════
  //  ⚠️ Sad notification — وقتی watchdog تونل را
  //  به‌خاطر keep-alive restart می‌کند
  // ═══════════════════════════════════════════
  String? pendingSadNotification;
  DateTime? pendingSadTimestamp;

  void setSadNotification(String tunnelName) {
    pendingSadNotification = tunnelName;
    pendingSadTimestamp = DateTime.now();
  }

  void clearSadNotification() {
    pendingSadNotification = null;
    pendingSadTimestamp = null;
  }

  // ═══════════════════════════════════════════
  //  ⚠️ Happy notification — وقتی اتصال برقرار می‌شود
  //  (فقط در transition از disconnected → connected)
  // ═══════════════════════════════════════════
  String? pendingHappyNotification;
  DateTime? pendingHappyTimestamp;

  /// ست کردن notification «خوشحال» — وقتی تونل وصل می‌شود.
  /// ⚠️ فقط یک‌بار در transition صدا زده می‌شود تا از تکرار جلوگیری شود.
  void setHappyNotification(String tunnelName) {
    pendingHappyNotification = tunnelName;
    pendingHappyTimestamp = DateTime.now();
  }

  void clearHappyNotification() {
    pendingHappyNotification = null;
    pendingHappyTimestamp = null;
  }
}
