library;

mixin ProcessProtocolState {
  String? get lastPsiphonProtocol;
  set lastPsiphonProtocol(String? v);

  String? get pendingProtocolNotification;
  set pendingProtocolNotification(String? v);

  String? get pendingProtocolBinary;
  set pendingProtocolBinary(String? v);

  String? get currentPsiphonBinaryName;
  set currentPsiphonBinaryName(String? v);

  void clearPendingProtocolNotification();

  String? get lastAetherProtocol;
  set lastAetherProtocol(String? v);

  String? get pendingAetherProtocolNotification;
  set pendingAetherProtocolNotification(String? v);

  void clearPendingAetherProtocolNotification();
  void setAetherProtocolNotification(String protocol);

  String? get lastTorTransport;
  set lastTorTransport(String? v);

  String? get pendingTorNotification;
  set pendingTorNotification(String? v);

  String? get pendingTorTransportDetail;
  set pendingTorTransportDetail(String? v);

  String? get pendingTorTransportType;
  set pendingTorTransportType(String? v);

  String? get pendingTorTransportDetailPrepared;
  set pendingTorTransportDetailPrepared(String? v);

  void clearPendingTorNotification();
  void prepareTorNotification(String transport, String detail);
  void setTorNotification(String transport, String detail);
  void resetTorState();

  String? get lastSstpServer;
  set lastSstpServer(String? v);

  String? get pendingSstpNotification;
  set pendingSstpNotification(String? v);

  String? get pendingSstpTransportDetail;
  set pendingSstpTransportDetail(String? v);

  String? get pendingSstpTransportType;
  set pendingSstpTransportType(String? v);

  void clearPendingSstpNotification();
  void prepareSstpNotification(String serverInfo, String detail);
  void setSstpNotification(String serverInfo, {String detail});
}
