library;

/// ═══════════════════════════════════════════════════════════════
///  مقایسه نسخه (semantic versioning).
/// ═══════════════════════════════════════════════════════════════
class AppUpdateVersionUtils {
  AppUpdateVersionUtils._();

  /// آیا [latest] از [installed] جدیدتر است؟
  static bool isNewer(String installed, String latest) {
    final a = _parse(installed);
    final b = _parse(latest);
    for (var i = 0; i < b.length; i++) {
      final ai = i < a.length ? a[i] : 0;
      if (b[i] > ai) return true;
      if (b[i] < ai) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    return v.split(RegExp(r'[.\-+]')).map((e) {
      final m = RegExp(r'\d+').firstMatch(e);
      return m != null ? int.tryParse(m.group(0)!) ?? 0 : 0;
    }).toList();
  }
}
