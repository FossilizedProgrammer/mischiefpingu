part of 'settings_model.dart';

class ProfileCandidate {
  final String protocol;
  final String masque;
  final bool fragmentH2;

  const ProfileCandidate({
    required this.protocol,
    this.masque = '',
    this.fragmentH2 = false,
  });

  String get key => '$protocol|$masque|$fragmentH2';
}

class AetherProfile {
  final String id;
  final String label;
  final String description;
  final String scanMode;
  final String noize;
  final List<ProfileCandidate> candidates;

  const AetherProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.scanMode,
    required this.noize,
    required this.candidates,
  });
}

const List<AetherProfile> aetherProfiles = [
  // ═══════════════════════════════════════════════════════════════
  //  ⚠️ تغییرات:
  //    • adaptive: noize از 'off' به 'balanced'
  //    • adaptive: ترتیب candidates — MIM قبل از WireGuard
  //      (چون WireGuard در ایران خیلی راحت DPI می‌شه)
  //    • patchy: fragmentH2 برای HTTP-2
  //    • strict: بدون تغییر (خوبه)
  // ═══════════════════════════════════════════════════════════════
  AetherProfile(
    id: 'adaptive',
    label: 'Adaptive',
    description: 'تعادل سرعت و پوشش — مناسب اکثر شبکه‌ها',
    scanMode: 'balanced',
    // ⚠️ قبلاً 'off' بود — در شبکه‌های فیلترشده شکست می‌خورد
    noize: 'balanced',
    candidates: [
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-2'),
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-2'),
      ProfileCandidate(protocol: 'gool'),
      ProfileCandidate(protocol: 'wireguard'),
    ],
  ),
  AetherProfile(
    id: 'patchy',
    label: 'Patchy signal',
    description: 'دیتای موبایل ناپایدار — جستجوی سخت‌تر و مقاوم‌تر',
    scanMode: 'balanced',
    noize: 'balanced',
    candidates: [
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-2', fragmentH2: true),
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-2', fragmentH2: true),
      ProfileCandidate(protocol: 'gool'),
      ProfileCandidate(protocol: 'wireguard'),
    ],
  ),
  AetherProfile(
    id: 'strict',
    label: 'Strict network',
    description: 'وای‌فای محدود یا فیلتر سنگین — fragment + masque-in-masque + noize gfw',
    scanMode: 'stealth',
    noize: 'gfw',
    candidates: [
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-2', fragmentH2: true),
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-2', fragmentH2: true),
      ProfileCandidate(protocol: 'mim', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'masque', masque: 'HTTP-3'),
      ProfileCandidate(protocol: 'gool'),
    ],
  ),
  AetherProfile(
    id: 'manual',
    label: 'Manual',
    description: 'همهٔ گزینه‌ها دستی — برای کاربران حرفه‌ای',
    scanMode: '',
    noize: '',
    candidates: [],
  ),
];

AetherProfile? aetherProfileById(String id) {
  for (final p in aetherProfiles) {
    if (p.id == id) return p;
  }
  return null;
}

extension AppSettingsAetherProfile on AppSettings {
  AetherProfile? get activeAetherProfile => aetherProfileById(aetherProfile);

  void applyAetherProfile(String id) {
    final p = aetherProfileById(id);
    if (p == null) return;
    aetherProfile = id;

    // ═══════════════════════════════════════════════════════════════
    //  ⚠️ Manual mode:
    //    • پروتکل 'auto' بی‌معنیه — به 'masque' پیش‌فرض می‌ره
    //    • scanMode / obfuscation / masqueOption دست نمی‌خورن
    //      (چون user خودش می‌خواد تنظیم کنه)
    // ═══════════════════════════════════════════════════════════════
    if (id == 'manual') {
      if (aetherProtocol == 'auto' || aetherProtocol.isEmpty) {
        aetherProtocol = 'masque';
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════
    //  ⚠️ برگشت از manual به preset:
    //    • پروتکل دوباره 'auto' می‌شه (چون preset خودش تصمیم می‌گیره)
    // ═══════════════════════════════════════════════════════════════
    aetherProtocol = 'auto';

    final hasCustomEndpoint = aetherCustomEndpoint.trim().isNotEmpty;
    if (!hasCustomEndpoint) {
      aetherScanMode = p.scanMode;
      for (final c in p.candidates) {
        if ((c.protocol == 'masque' || c.protocol == 'mim') &&
            c.masque.isNotEmpty) {
          masqueOption = c.masque;
          break;
        }
      }
    }
    if (p.noize.isNotEmpty) {
      obfuscation = p.noize;
    }
  }
}
