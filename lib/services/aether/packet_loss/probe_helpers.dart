part of '../packet_loss_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  توابع کمکی static برای PacketLossProber.
/// ═══════════════════════════════════════════════════════════════
class ProbeHelpers {
  ProbeHelpers._();

  static bool looksLikeIPv4(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  /// SNI: اگه IP بود، SNI معادل hostname رو برگردون.
  static String sniFor(String host) {
    if (looksLikeIPv4(host)) {
      for (final e in PacketLossProber.ipFallback.entries) {
        if (e.value == host) return e.key;
      }
      return 'www.cloudflare.com';
    }
    return host;
  }

  /// Host header: اگه IP بود، hostname رو برگردون.
  static String hostHeaderFor(String host) {
    if (looksLikeIPv4(host)) {
      for (final e in PacketLossProber.ipFallback.entries) {
        if (e.value == host) return e.key;
      }
      return 'www.cloudflare.com';
    }
    return host;
  }

  static String headPreview(List<int> data) {
    return String.fromCharCodes(data.take(40));
  }
}
