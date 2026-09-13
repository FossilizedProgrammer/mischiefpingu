// lib/services/log_line_parsers.dart
library;

/// Pure parsers for process log lines (Psiphon build-rev capture, CDN
/// fronting auto-save, ActiveTunnel protocol). No app state — callers apply the results.
class LogLineParsers {
  static final buildRevRegex = RegExp(r'"buildRev"\s*:\s*"([0-9a-f]{7,40})"');

  /// Extracts the Psiphon core build revision from a log line, if present.
  static String? parseBuildRev(String line) {
    final match = buildRevRegex.firstMatch(line);
    if (match == null) return null;
    return match.group(1);
  }

  static final cdnFoundRegex = RegExp(
    r'cdn fronting scan found \(ip:\s*([^\s,)]+),\s*sni:\s*([^\s,)]+)\)',
    caseSensitive: false,
  );

  /// Extracts a found fronting (ip, sni) pair from a scanner log line.
  /// Returns null when the line carries no pair (or an incomplete one).
  static ({String ip, String sni})? parseFoundFronting(String line) {
    final match = cdnFoundRegex.firstMatch(line);
    if (match == null) return null;
    final ip = (match.group(1)?.trim() ?? '').replaceAll(r'\', '').trim();
    final sni = match.group(2)?.trim() ?? '';
    if (ip.isEmpty || sni.isEmpty) return null;
    return (ip: ip, sni: sni);
  }

  // ── ActiveTunnel protocol ──────────────────────────────────────────────
  // Matches: "noticeType":"ActiveTunnel" ... "protocol":"OSSH" (order-independent)
  static final activeTunnelProtocolRegex = RegExp(
    r'"noticeType"\s*:\s*"ActiveTunnel".*?"protocol"\s*:\s*"([^"]+)"',
    caseSensitive: false,
    dotAll: true,
  );

  // Fallback if fields appear in reverse order
  static final activeTunnelProtocolRegexAlt = RegExp(
    r'"protocol"\s*:\s*"([^"]+)".*?"noticeType"\s*:\s*"ActiveTunnel"',
    caseSensitive: false,
    dotAll: true,
  );

  /// Extracts the tunnel protocol (SSH / OSSH / FRONTED-MEEK-OSSH / ...) from an
  /// ActiveTunnel notice line. Returns null if the line is not an ActiveTunnel
  /// notice or the protocol field is missing.
  static String? parseActiveTunnelProtocol(String line) {
    if (!line.contains('ActiveTunnel')) return null;

    var match = activeTunnelProtocolRegex.firstMatch(line);
    match ??= activeTunnelProtocolRegexAlt.firstMatch(line);
    if (match == null) return null;

    final protocol = match.group(1)?.trim();
    if (protocol == null || protocol.isEmpty) return null;
    return protocol;
  }
}
