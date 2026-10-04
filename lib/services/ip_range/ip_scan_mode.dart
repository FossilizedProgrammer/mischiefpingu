library;

/// ═══════════════════════════════════════════════════════════════
///  IpScanMode — حالت‌های اسکن CDN
///
///  ⚠️ اعداد کاهش یافتند چون تست کامل HTTP هر IP
///  بین ۵-۸ ثانیه طول می‌کشه.
/// ═══════════════════════════════════════════════════════════════
enum IpScanMode {
  quick,
  balanced,
  deep;

  static IpScanMode fromId(String id) {
    for (final m in values) {
      if (m.name == id) return m;
    }
    return IpScanMode.balanced;
  }

  String get id => name;

  bool get isSampling => this != IpScanMode.deep;

  int get samplesPerCidr {
    switch (this) {
      case IpScanMode.quick:
        return 8;
      case IpScanMode.balanced:
        return 64;
      case IpScanMode.deep:
        return 0;
    }
  }

  int get maxTotalIps {
    switch (this) {
      case IpScanMode.quick:
        return 200;
      case IpScanMode.balanced:
        return 2000;
      case IpScanMode.deep:
        return 20000;
    }
  }

  String get estimatedDuration {
    switch (this) {
      case IpScanMode.quick:
        return '~1-2 min';
      case IpScanMode.balanced:
        return '~5-10 min';
      case IpScanMode.deep:
        return '~30-60 min';
    }
  }
}
