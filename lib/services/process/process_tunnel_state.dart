library;

mixin ProcessTunnelState {
  bool get isPsiphonRunning;
  set isPsiphonRunning(bool v);

  bool get isAetherRunning;
  set isAetherRunning(bool v);

  /// ═══════════════════════════════════════════════════════════════
  ///  ⚠️ جدید: آیا tunnel Aether واقعاً آماده است؟
  ///
  ///  تفاوت با isAetherRunning:
  ///    • isAetherRunning     = پروسه Aether spawn شده (فقط همین)
  ///    • isAetherTunnelReady = Aether خودش خط "socks5 server
  ///      listening" را چاپ کرده (tunnel واقعاً validate شده)
  ///
  ///  بین این دو معمولاً ۵–۱۰ ثانیه فاصله است.
  ///
  ///  auto-probe و health check باید به isAetherTunnelReady
  ///  اعتماد کنند، نه isAetherRunning — وگرنه probe قبل از
  ///  آماده شدن SOCKS اجرا می‌شود و "Connection refused" می‌دهد.
  /// ═══════════════════════════════════════════════════════════════
  bool get isAetherTunnelReady;
  set isAetherTunnelReady(bool v);

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
