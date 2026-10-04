import 'cdn_presets_ranges.dart';

class CdnPreset {
  final String id;
  final String name;
  final List<String> snis;
  final List<String> ranges;

  const CdnPreset({
    required this.id,
    required this.name,
    required this.snis,
    required this.ranges,
  });
}

class CdnPresets {
  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Akamai
  ///
  ///  ⚠️ نکته مهم درباره فیلترینگ در ایران:
  ///  - SNIهای عمومی Akamai (a248.e.akamai.net) معمولاً بازن
  ///  - اگه بسته بودن، می‌تونید SNI یه سایت ایرانی پشت Akamai
  ///    رو امتحان کنید (مثل aparat.com)
  ///
  ///  چرا این ترتیب؟
  ///    1. a248.e.akamai.net → عمومی‌ترین
  ///    2. a.akamaihd.net    → پایدار
  ///    3. a.akamaized.net   → پایدار
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> akamaiSnis = [
    'a248.e.akamai.net',
    'a.akamaihd.net',
    'a.akamaized.net',
    'www.akamai.com',
    'ds-aksb.akamaized.net',
    'ak.net.akamaized.net',
    // سایت‌های ایرانی پشت Akamai (برای مواقع فیلترشدن SNIهای بالا):
    // 'www.aparat.com',
    // 'www.varzesh3.com',
  ];

  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Cloudflare
  ///
  ///  ⚠️ فیلترینگ در ایران:
  ///  - www.cloudflare.com     → معمولاً باز ✅
  ///  - 1.1.1.1                → معمولاً باز (DNS کلودفلر) ✅
  ///  - one.one.one.one        → معمولاً باز ✅
  ///  - discord.com            → ❌ فیلتر
  ///  - shopify.com            → بعضاً فیلتر
  ///  - cdnjs.cloudflare.com   → بعضاً فیلتر
  ///
  ///  سایت‌های بزرگ جهانی که اکثراً بازن و پشت کلودفلر:
  ///  - digitalocean.com
  ///  - upwork.com
  ///  - namecheap.com
  ///  - udemy.com
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> cloudflareSnis = [
    'www.cloudflare.com',
    'cloudflare.com',
    '1.1.1.1',
    'one.one.one.one',
    'www.digitalocean.com',
    'www.upwork.com',
    'www.namecheap.com',
    'www.udemy.com',
    'developers.cloudflare.com',
    'blog.cloudflare.com',
  ];

  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Fastly
  ///
  ///  ⚠️ Fastly در ایران کمتر استفاده می‌شه و SNIهاش
  ///  ممکنه فیلتر باشن.
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> fastlySnis = [
    'www.fastly.com',
    'www.reddit.com',      // ⚠️ فیلتر در ایران
    'www.nytimes.com',     // ⚠️ فیلتر در ایران
    'www.imgur.com',
    'developer.mozilla.org',
  ];

  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Google
  ///
  ///  ⚠️ در ایران:
  ///  - fonts.googleapis.com   → معمولاً باز ✅
  ///  - fonts.gstatic.com      → معمولاً باز ✅
  ///  - www.google.com         → معمولاً فیلتر ❌
  ///
  ///  ⚠️ نکته مهم: google.com رو آخر گذاشتم چون معمولاً فیلتره.
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> googleSnis = [
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'ajax.googleapis.com',
    'ssl.gstatic.com',
    'www.gstatic.com',
    'storage.googleapis.com',
    'accounts.google.com',
    'www.google.com',
  ];

  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Amazon CloudFront
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> amazonSnis = [
    'd1.cloudfront.net',
    'd2.cloudfront.net',
    'd3.cloudfront.net',
    'aws.cloudfront.net',
    's3.amazonaws.com',
    'edge.cloudfront.net',
  ];

  /// ═══════════════════════════════════════════════════════════════
  ///  SNIهای Microsoft Azure
  ///
  ///  ⚠️ در ایران:
  ///  - www.microsoft.com  → معمولاً باز ✅
  ///  - cdn.office.net     → معمولاً باز ✅
  /// ═══════════════════════════════════════════════════════════════
  static const List<String> azureSnis = [
    'www.microsoft.com',
    'ajax.aspnetcdn.com',
    'az416426.vo.msecnd.net',
    'az784690.vo.msecnd.net',
    'cdn.office.net',
    'static.azureedge.net',
    'az.msecnd.net',
  ];

  static const List<String> akamaiRanges = CdnPresetRanges.akamai;
  static const List<String> cloudflareRanges = CdnPresetRanges.cloudflare;
  static const List<String> fastlyRanges = CdnPresetRanges.fastly;
  static const List<String> googleRanges = CdnPresetRanges.google;
  static const List<String> amazonRanges = CdnPresetRanges.amazon;
  static const List<String> azureRanges = CdnPresetRanges.azure;

  static final List<CdnPreset> all = [
    // ⚠️ ترتیب مهمه: Cloudflare اول (چون SNIهای بازتری داره)
    CdnPreset(
      id: 'cloudflare',
      name: 'Cloudflare',
      snis: cloudflareSnis,
      ranges: cloudflareRanges,
    ),
    CdnPreset(
      id: 'akamai',
      name: 'Akamai',
      snis: akamaiSnis,
      ranges: akamaiRanges,
    ),
    CdnPreset(
      id: 'google',
      name: 'Google CDN',
      snis: googleSnis,
      ranges: googleRanges,
    ),
    CdnPreset(
      id: 'azure',
      name: 'Microsoft Azure',
      snis: azureSnis,
      ranges: azureRanges,
    ),
    CdnPreset(
      id: 'amazon',
      name: 'Amazon CloudFront',
      snis: amazonSnis,
      ranges: amazonRanges,
    ),
    CdnPreset(
      id: 'fastly',
      name: 'Fastly',
      snis: fastlySnis,
      ranges: fastlyRanges,
    ),
    CdnPreset(
      id: 'custom',
      name: 'Custom (my IPs)',
      snis: cloudflareSnis,
      ranges: const [],
    ),
  ];

  static CdnPreset? byId(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
