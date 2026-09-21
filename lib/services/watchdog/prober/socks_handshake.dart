part of '../watchdog_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  SOCKS5 handshake — مرحله 1+2+3 از probe.
///
///  این extension سه مرحله رو انجام می‌ده و نتیجه رو به شکل
///  یک record برمی‌گردونه. اگه هر مرحله‌ای شکست خورد،
///  مرحله‌های بعدی اجرا نمی‌شن و `null` برمی‌گرده.
/// ═══════════════════════════════════════════════════════════════
extension WatchdogProberSocksHandshake on WatchdogProber {
  /// نتیجهٔ handshake.
  Future<SocksHandshakeResult> performSocksHandshake({
    required Stopwatch sw,
  }) async {
    Socket? sock;
    StreamIterator<List<int>>? iter;

    bool tcpOk = false;
    bool greetOk = false;
    bool connectOk = false;

    // ─── مرحله 1: TCP ───
    try {
      sock = await Socket.connect(
        '127.0.0.1',
        socksPort,
        timeout: connectTimeout,
      );
      tcpOk = true;
    } on SocketException {
      return SocksHandshakeResult(
        sock: null,
        iter: null,
        tcpOk: false,
        greetOk: false,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }

    iter = StreamIterator<List<int>>(sock.timeout(socksTimeout));

    // ─── مرحله 2: greeting ───
    sock.add([0x05, 0x01, 0x00]);
    await sock.flush();

    if (!await iter.moveNext()) {
      return SocksHandshakeResult(
        sock: sock,
        iter: iter,
        tcpOk: tcpOk,
        greetOk: false,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
    final greet = iter.current;
    if (greet.isEmpty || greet[0] != 0x05) {
      return SocksHandshakeResult(
        sock: sock,
        iter: iter,
        tcpOk: tcpOk,
        greetOk: false,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
    if (greet.length >= 2 && greet[1] != 0x00) {
      return SocksHandshakeResult(
        sock: sock,
        iter: iter,
        tcpOk: tcpOk,
        greetOk: false,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
    greetOk = true;

    // ─── مرحله 3: CONNECT ───
    // ⚠️ static memberها باید با نام کلاس qualify بشن:
    //    WatchdogProber.probeHostname / WatchdogProber.probeHttpsPort
    final hostBytes = utf8.encode(WatchdogProber.probeHostname);
    sock.add(<int>[
      0x05,
      0x01,
      0x00,
      0x03,
      hostBytes.length,
      ...hostBytes,
      (WatchdogProber.probeHttpsPort >> 8) & 0xFF,
      WatchdogProber.probeHttpsPort & 0xFF,
    ]);
    await sock.flush();

    if (!await iter.moveNext()) {
      return SocksHandshakeResult(
        sock: sock,
        iter: iter,
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
    final resp = iter.current;
    if (resp.length < 2 || resp[1] != 0x00) {
      return SocksHandshakeResult(
        sock: sock,
        iter: iter,
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: false,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
    connectOk = true;

    return SocksHandshakeResult(
      sock: sock,
      iter: iter,
      tcpOk: tcpOk,
      greetOk: greetOk,
      connectOk: connectOk,
      latencyMs: sw.elapsedMilliseconds,
    );
  }
}

/// نتیجهٔ SOCKS5 handshake.
class SocksHandshakeResult {
  final Socket? sock;
  final StreamIterator<List<int>>? iter;
  final bool tcpOk;
  final bool greetOk;
  final bool connectOk;
  final int latencyMs;

  const SocksHandshakeResult({
    required this.sock,
    required this.iter,
    required this.tcpOk,
    required this.greetOk,
    required this.connectOk,
    required this.latencyMs,
  });

  /// آیا تمام مراحل SOCKS موفق بودن؟ (TLS و HTTPS جدا هستن)
  bool get socksOk => tcpOk && greetOk && connectOk;
}
