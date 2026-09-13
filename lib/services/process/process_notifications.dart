// lib/services/process/process_notifications.dart

/// وضعیت notificationها و state داخلی Psiphon/Aether/Tor/SSTP.
///
/// این mixin را ProcessService استفاده می‌کند تا فیلدهای state و
/// pending/notification از منطق پروسه جدا شوند.
///
/// ⚠️ فیلدهای state به صورت public تعریف شده‌اند تا فایل‌های part
/// (process_service_psiphon.dart، process_service_tor.dart،
/// process_service_sstp.dart) بتوانند مستقیماً به آن‌ها دسترسی داشته باشند.
mixin ProcessNotifications {
  // ═══════════════════════════════════════════
  //  Running / Connected state
  //  (public — برای دسترسی از فایل‌های part)
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

  /// پاک‌سازی state داخلی Tor (در exit handler).
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

  /// آماده‌سازی notification — قبل از اتصال واقعی.
  void prepareSstpNotification(String serverInfo, String detail) {
    pendingSstpTransportType = serverInfo;
    pendingSstpTransportDetail = detail;
  }

  /// تنظیم notification بعد از اتصال موفق.
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
}
