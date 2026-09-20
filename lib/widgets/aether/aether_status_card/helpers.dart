library;

/// ═══════════════════════════════════════════════════════════════
///  helperهای فرمت‌دهی برای AetherStatusCard.
/// ═══════════════════════════════════════════════════════════════
class AetherStatusHelpers {
  AetherStatusHelpers._();

  /// کوتاه کردن unique key به ip:port.
  ///
  /// key format: `ip:port|protocol|masque|sni`
  static String shortenKey(String? key) {
    if (key == null || key.isEmpty) return '—';
    final parts = key.split('|');
    return parts.isNotEmpty ? parts.first : key;
  }

  /// فرمت duration به شکل `2h 15m` یا `5m 30s` یا `45s`.
  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }
}
