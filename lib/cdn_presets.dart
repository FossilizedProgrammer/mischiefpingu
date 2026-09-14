// lib/cdn_presets.dart
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
  static const List<String> akamaiSnis = [
    'a248.e.akamai.net',
    'a77.net.akamai.net',
    'a104.net.akamai.net',
    'a184.net.akamai.net',
    'ds-aksb.akamaized.net',
    'ak.net.akamaized.net',
  ];

  static const List<String> cloudflareSnis = [
    'www.cloudflare.com',
    'discord.com',
    'cdnjs.cloudflare.com',
    'www.shopify.com',
    'www.medium.com',
    'www.cloudflareapps.com',
  ];

  static const List<String> fastlySnis = [
    'www.fastly.com',
    'www.reddit.com',
    'www.nytimes.com',
    'www.imgur.com',
    'www.spotify.com',
    'developer.mozilla.org',
  ];

  static const List<String> googleSnis = [
    'fonts.googleapis.com',
    'ajax.googleapis.com',
    'storage.googleapis.com',
    'www.gstatic.com',
    'ssl.gstatic.com',
    'accounts.google.com',
  ];

  static const List<String> amazonSnis = [
    'd1.cloudfront.net',
    'd2.cloudfront.net',
    'd3.cloudfront.net',
    'aws.cloudfront.net',
    's3.amazonaws.com',
    'edge.cloudfront.net',
  ];

  static const List<String> azureSnis = [
    'ajax.aspnetcdn.com',
    'az416426.vo.msecnd.net',
    'az784690.vo.msecnd.net',
    'cdn.office.net',
    'static.azureedge.net',
    'az.msecnd.net',
  ];

  // ─── Aliases برای سازگاری با کد قدیمی ───
  static const List<String> akamaiRanges = CdnPresetRanges.akamai;
  static const List<String> cloudflareRanges = CdnPresetRanges.cloudflare;
  static const List<String> fastlyRanges = CdnPresetRanges.fastly;
  static const List<String> googleRanges = CdnPresetRanges.google;
  static const List<String> amazonRanges = CdnPresetRanges.amazon;
  static const List<String> azureRanges = CdnPresetRanges.azure;

  static final List<CdnPreset> all = [
    CdnPreset(
      id: 'akamai',
      name: 'Akamai',
      snis: akamaiSnis,
      ranges: akamaiRanges,
    ),
    CdnPreset(
      id: 'cloudflare',
      name: 'Cloudflare',
      snis: cloudflareSnis,
      ranges: cloudflareRanges,
    ),
    CdnPreset(
      id: 'fastly',
      name: 'Fastly',
      snis: fastlySnis,
      ranges: fastlyRanges,
    ),
    CdnPreset(
      id: 'google',
      name: 'Google CDN',
      snis: googleSnis,
      ranges: googleRanges,
    ),
    CdnPreset(
      id: 'amazon',
      name: 'Amazon CloudFront',
      snis: amazonSnis,
      ranges: amazonRanges,
    ),
    CdnPreset(
      id: 'azure',
      name: 'Microsoft Azure',
      snis: azureSnis,
      ranges: azureRanges,
    ),
    CdnPreset(
      id: 'custom',
      name: 'Custom (my IPs)',
      snis: akamaiSnis,
      ranges: const [], // از SharedPreferences خونده می‌شه
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
