library;

mixin ProcessTunnelState {
  bool get isPsiphonRunning;
  set isPsiphonRunning(bool v);

  bool get isAetherRunning;
  set isAetherRunning(bool v);

  bool get isTorRunning;
  set isTorRunning(bool v);

  bool get isSstpRunning;
  set isSstpRunning(bool v);

  bool get isPsiphonConnected;
  set isPsiphonConnected(bool v);

  bool get isTorConnected;
  set isTorConnected(bool v);

  bool get isSstpConnected;
  set isSstpConnected(bool v);

  bool get isSstpTunnelReady;
  set isSstpTunnelReady(bool v);

  String? get sstpAssignedIp;
  set sstpAssignedIp(String? v);

  int get torBootstrapProgress;
  set torBootstrapProgress(int v);
}
