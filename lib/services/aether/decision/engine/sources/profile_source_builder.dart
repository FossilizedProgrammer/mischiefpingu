part of '../../aether_decision_engine.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProfileSourceBuilder — candidates پیش‌فرض پروفایل.
///
///  اگر profile در دسترس باشه، candidateهای آن را اضافه می‌کند.
///  در غیر این صورت، fallbackهای عمومی را اضافه می‌کند.
///
///  ⚠️ تغییر: bonus score برای پروتکل‌های غیر-WireGuard
///
///  چون در شبکه‌های فیلترشده، WireGuard خیلی راحت DPI می‌شه،
///  MASQUE و MIM رو با یه score کوچیک جلوتر می‌فرستیم.
/// ═══════════════════════════════════════════════════════════════
class ProfileSourceBuilder {
  final AetherDecisionEngine engine;

  const ProfileSourceBuilder({required this.engine});

  void build(void Function(RankedCandidate) add) {
    final profile = engine.settings.activeAetherProfile;
    final candidates = profile?.candidates ?? const <ProfileCandidate>[];

    if (candidates.isEmpty) {
      for (final c in const [
        ProfileCandidate(protocol: 'masque', masque: 'HTTP-3'),
        ProfileCandidate(protocol: 'mim', masque: 'HTTP-3'),
        ProfileCandidate(protocol: 'masque', masque: 'HTTP-2'),
        ProfileCandidate(protocol: 'wireguard'),
        ProfileCandidate(protocol: 'gool'),
      ]) {
        add(_defaultCandidate(c));
      }
      return;
    }

    for (final c in candidates) {
      add(_defaultCandidate(c));
    }
  }

  RankedCandidate _defaultCandidate(ProfileCandidate c) {
    final baseScore = _protocolBonusScore(c.protocol);

    return RankedCandidate(
      protocol: c.protocol,
      masque: c.masque,
      endpoint: '',
      fragmentH2: c.fragmentH2,
      score: baseScore,
      source: CandidateSource.defaultFallback,
      reason:
          'profile default'
          '${baseScore > 0 ? " (protocol bonus $baseScore)" : ""}',
    );
  }

  /// bonus score برای پروتکل‌ها.
  ///
  ///   • MIM       → +5 (بهترین علیه DPI)
  ///   • MASQUE    → +3 (خوب)
  ///   • GOOL      → +2 (WARP-in-WARP)
  ///   • WireGuard →  0 (در برابر DPI ضعیف)
  double _protocolBonusScore(String protocol) {
    switch (protocol) {
      case 'mim':
        return 5.0;
      case 'masque':
        return 3.0;
      case 'gool':
        return 2.0;
      case 'wireguard':
        return 0.0;
      default:
        return 0.0;
    }
  }
}
