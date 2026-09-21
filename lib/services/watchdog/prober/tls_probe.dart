part of '../watchdog_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  TLS + HTTPS orchestration — مرحله 4 از probe.
///
///  این extension:
///    • SecureSocket.secure رو روی سوکت موجود اجرا می‌کنه
///    • HTTPS HEAD می‌زنه
///    • نتیجه رو به شکل record برمی‌گردونه
/// ═══════════════════════════════════════════════════════════════
extension WatchdogProberTlsProbe on WatchdogProber {
  /// اجرای TLS + HTTPS روی یک سوکت SOCKS آماده.
  ///
  /// `iter` رو cancel می‌کنه چون بعد از secure شدن، سوکت
  /// دیگه قابل استفاده از طریق iterator خام نیست.
  Future<({SecureSocket? secure, bool httpRespOk, bool httpStatusOk})>
  performTlsAndHttps({
    required Socket sock,
    required StreamIterator<List<int>>? iter,
  }) async {
    SecureSocket? secure;

    // ─── لغو iterator چون secure socket خودش روی سوکت سوار می‌شه ───
    try {
      await iter?.cancel();
    } catch (_) {}

    // ─── TLS handshake ───
    // ⚠️ static memberها باید با نام کلاس qualify بشن
    try {
      secure = await SecureSocket.secure(
        sock,
        host: WatchdogProber.probeHostname,
        onBadCertificate: (_) => true,
      ).timeout(httpProbeTimeout);
    } catch (e) {
      log('✗ probe: TLS handshake failed: $e', source: logSource);
      return (secure: null, httpRespOk: false, httpStatusOk: false);
    }

    // ─── HTTPS HEAD ───
    final httpResult = await probeHttps(secure);
    return (
      secure: secure,
      httpRespOk: httpResult.responseOk,
      httpStatusOk: httpResult.statusOk,
    );
  }
}
