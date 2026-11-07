// lib/services/diagnostics/diagnostics_report_redactor.dart

library;

/// ═══════════════════════════════════════════════════════════════
///  DiagnosticsReportRedactor — حذف اطلاعات حساس از گزارش.
///
///  چه چیزهایی redact میشن:
///    • IPv4 آدرس‌ها (به جز 127.0.0.1 و 0.0.0.0)
///    • IPv6 آدرس‌ها
///    • کلیدها (PrivateKey، PublicKey، PresharedKey)
///    • رمز عبور و نام کاربری
///    • توکن‌ها و API keyها
///    • fingerprintها
///
///  ⚠️ این کلاس محافظه‌کارانه عمل می‌کنه — اگه شک داشت،
///  redact می‌کنه.
/// ═══════════════════════════════════════════════════════════════
class DiagnosticsReportRedactor {
  DiagnosticsReportRedactor._();

  static const String _redacted = '[REDACTED]';

  // ─── IPv4 (به جز loopback و any) ───
  static final RegExp _ipv4 = RegExp(
    r'\b(?!(?:127\.0\.0\.1|0\.0\.0\.0)\b)'
    r'(?:\d{1,3}\.){3}\d{1,3}\b',
  );

  // ─── IPv6 ساده ───
  static final RegExp _ipv6 = RegExp(
    r'\b(?:[0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}\b',
  );

  // ─── کلیدها (Base64 بلند) ───
  static final RegExp _base64Key = RegExp(
    r'\b[A-Za-z0-9+/]{40,}={0,2}\b',
  );

  // ─── Hex بلند (fingerprint / sha) ───
  static final RegExp _hexHash = RegExp(
    r'\b[0-9a-fA-F]{32,}\b',
  );

  // ─── Password / Secret / Token / API key ───
  static final RegExp _secretKeyValue = RegExp(
    r'((?:password|pass|secret|token|api[_-]?key|presharedkey|privatekey)'
    r'\s*[:=]\s*)([^\s,;"\n]+)',
    caseSensitive: false,
  );

  // ─── Username in URL ───
  static final RegExp _urlUserInfo = RegExp(
    r'([a-z][a-z0-9+.-]*://)([^/\s@]+)@',
    caseSensitive: false,
  );

  // ─── Endpoint (host:port) در برخی خطوط ───
  static final RegExp _endpointValue = RegExp(
    r'(endpoint\s*[:=]\s*)([^\s,;"\n]+)',
    caseSensitive: false,
  );

  /// اعمال همه‌ی redactionها روی یک رشته.
  static String redact(String input) {
    var out = input;

    // اول secret key=value (چون ممکنه شامل base64 باشه)
    out = out.replaceAllMapped(_secretKeyValue, (m) {
      return '${m.group(1)}$_redacted';
    });

    // URL userinfo (user:pass@host)
    out = out.replaceAllMapped(_urlUserInfo, (m) {
      return '${m.group(1)}$_redacted@';
    });

    // endpoint
    out = out.replaceAllMapped(_endpointValue, (m) {
      return '${m.group(1)}$_redacted';
    });

    // IPv6 قبل از IPv4 (چون IPv4 زیرمجموعه IPv6 نیست ولی ترتیب مهمه)
    out = out.replaceAll(_ipv6, _redacted);

    // IPv4
    out = out.replaceAllMapped(_ipv4, (m) {
      final ip = m.group(0)!;
      // نگه‌داشتن 127.x.x.x و 0.0.0.0
      if (ip.startsWith('127.') || ip == '0.0.0.0') return ip;
      return _redacted;
    });

    // Hex hash (fingerprint / sha)
    out = out.replaceAll(_hexHash, _redacted);

    // Base64 کلیدها
    out = out.replaceAll(_base64Key, _redacted);

    return out;
  }

  /// آیا این خط شامل اطلاعات حساسه؟ (برای تست)
  static bool containsSensitive(String line) {
    return _ipv4.hasMatch(line) ||
        _ipv6.hasMatch(line) ||
        _base64Key.hasMatch(line) ||
        _hexHash.hasMatch(line) ||
        _secretKeyValue.hasMatch(line);
  }
}
