library;

/// ═══════════════════════════════════════════════════════════════
///  RankedCandidate — یک کاندید اتصال با امتیاز رتبه‌بندی.
///
///  این کلاس جایگزین EndpointAttempt در مسیر DecisionEngine است.
///  تفاوت اصلی: score واقعی از Cache/History + منبع امتیاز.
/// ═══════════════════════════════════════════════════════════════
class RankedCandidate {
  final String protocol;
  final String masque;
  final String endpoint;
  final bool fragmentH2;

  /// امتیاز نهایی (0..100). 0 = ناشناخته (fallback).
  final double score;

  /// منبع امتیاز — برای لاگ و دیباگ.
  final CandidateSource source;

  /// دلیل انتخاب این رتبه (برای لاگ).
  final String reason;

  const RankedCandidate({
    required this.protocol,
    required this.masque,
    required this.endpoint,
    this.fragmentH2 = false,
    required this.score,
    required this.source,
    required this.reason,
  });

  /// کلید یکتا برای dedupe.
  String get dedupeKey => '$protocol|$masque|$endpoint|$fragmentH2';

  /// برچسب کوتاه برای لاگ.
  String get label {
    if (masque.isNotEmpty) {
      final suffix = fragmentH2 ? '+fragment' : '';
      return '${protocol.toUpperCase()}/$masque$suffix';
    }
    return protocol.toUpperCase();
  }

  @override
  String toString() =>
      'RankedCandidate($label, score=${score.toStringAsFixed(1)}, '
      'source=${source.name})';
}

enum CandidateSource {
  /// آخرین Gateway موفق (بالاترین اولویت).
  lastRemembered,

  /// از دیتابیس تاریخچه.
  history,

  /// از ProfilePerformanceStore (Smart Cache).
  cache,

  /// Custom endpoint کاربر.
  custom,

  /// پیش‌فرض پروفایل (بدون امتیاز).
  defaultFallback,
}
