library;

class VersionParsers {
  VersionParsers._();

  /// پارس نسخه Aether از خروجی `--version`.
  static String? parseAether(String? output) {
    if (output == null || output.isEmpty) return null;
    final parts = output.split(RegExp(r'\s+'));
    for (final pt in parts.reversed) {
      if (RegExp(r'^\d+\.\d+').hasMatch(pt)) return pt.trim();
    }
    return output.trim().split('\n').first.trim();
  }

  /// پارس نسخه Psiphon از خروجی `-v`.
  static String? parsePsiphon(String? output) {
    if (output == null || output.isEmpty) return null;
    final revMatch = RegExp(
      r'Revision:\s*([0-9a-f]{7,40})',
      caseSensitive: false,
    ).firstMatch(output);
    final rev = revMatch?.group(1)?.trim();
    if (rev == null || rev.isEmpty) return null;
    final short = rev.length > 10 ? rev.substring(0, 10) : rev;
    final dateMatch = RegExp(r'Build Date:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})')
        .firstMatch(output);
    final date = dateMatch?.group(1);
    return date != null ? '$short ($date)' : short;
  }

  /// پارس نسخه Tor از خروجی `--version`.
  static String? parseTor(String? output) {
    if (output == null || output.isEmpty) return null;
    final m = RegExp(
      r'version\s+([0-9][\w.\-]+)',
      caseSensitive: false,
    ).firstMatch(output);
    if (m != null) return m.group(1)!.trim();
    return output.trim().split('\n').first.trim();
  }

  /// پارس نسخه semantic از خروجی عمومی (برای SSTP).
  static String? parseSemver(String? output) {
    if (output == null || output.isEmpty) return null;
    final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b')
        .firstMatch(output);
    return m?.group(1);
  }

  /// آیا [latest] از [installed] جدیدتر است؟
  static bool isNewer(String installed, String latest) {
    List<int> parse(String v) => v
        .split(RegExp(r'[.\-+]'))
        .map(
          (e) =>
              int.tryParse(RegExp(r'\d+').firstMatch(e)?.group(0) ?? '0') ?? 0,
        )
        .toList();
    final a = parse(installed);
    final b = parse(latest);
    for (var i = 0; i < b.length; i++) {
      final ai = i < a.length ? a[i] : 0;
      if (b[i] > ai) return true;
      if (b[i] < ai) return false;
    }
    return false;
  }

  /// آیا نسخه "ناموجود" است؟
  static bool isMissing(String v) {
    final t = v.trim().toLowerCase();
    return t.isEmpty || t == 'unknown' || t == 'not installed';
  }

  /// فرمت بایت به رشته خوانا.
  static String formatBytes(int bytes) {
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }
}
