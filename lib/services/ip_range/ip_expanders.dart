library;

import 'ip_scan_mode.dart';
import 'ip_validators.dart';

class IpExpanders {
  IpExpanders._();

  /// حالت پیش‌فرض expand.
  static const IpScanMode defaultMode = IpScanMode.balanced;

  /// expand یک token (IP / CIDR / Range) به لیست IPها.
  static void expandToken(
    String token,
    List<String> result,
    Set<String> seen,
    List<String> warnings, {
    required IpScanMode mode,
  }) {
    final slash = token.indexOf('/');
    if (slash > 0) {
      _expandCidr(
        token,
        slash,
        result,
        seen,
        warnings,
        mode: mode,
      );
      return;
    }

    final m = IpValidators.rangeRe.firstMatch(token);
    if (m != null) {
      _expandDashRange(
        m.group(1)!,
        m.group(2)!,
        result,
        seen,
        warnings,
        mode: mode,
      );
      return;
    }

    if (IpValidators.isValidIPv4(token)) {
      if (seen.add(token)) result.add(token);
      return;
    }

    warnings.add("'$token' invalid");
  }

  static void _expandCidr(
    String token,
    int slashIdx,
    List<String> result,
    Set<String> seen,
    List<String> warnings, {
    required IpScanMode mode,
  }) {
    final ipPart = token.substring(0, slashIdx);
    final prefix = int.tryParse(token.substring(slashIdx + 1));

    if (!IpValidators.isValidIPv4(ipPart) ||
        prefix == null ||
        prefix < 0 ||
        prefix > 32) {
      warnings.add("'$token' bad CIDR");
      return;
    }

    final base = IpValidators.ipv4ToUInt(ipPart);
    final hostBits = 32 - prefix;
    final size = hostBits >= 32 ? 0xFFFFFFFF : (1 << hostBits);

    // ═══════════════════════════════════════════════════════════
    //  نمونه‌برداری از CIDRهای بزرگ
    //
    //  در حالت quick/balanced، از CIDRهایی که بزرگ‌تر از /24 هستند
    //  نمونه‌برداری می‌کنیم. در حالت deep، همه expand می‌شوند.
    // ═══════════════════════════════════════════════════════════
    final shouldSample = mode.isSampling && prefix < 24;

    if (shouldSample) {
      _sampleCidr(
        token: token,
        base: base,
        prefix: prefix,
        size: size,
        result: result,
        seen: seen,
        warnings: warnings,
        samplesPerCidr: mode.samplesPerCidr,
      );
      return;
    }

    // ─── Expand کامل ───
    final maxTotal = mode.maxTotalIps;
    final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
    final baseAligned = base & mask;

    // در حالت deep، محدودیت داریم ولی بزرگ
    final effectiveCap = maxTotal > 0 ? maxTotal : size;

    for (var i = 0; i < size && result.length < effectiveCap; i++) {
      final s = IpValidators.formatIPv4((baseAligned + i) & 0xFFFFFFFF);
      if (seen.add(s)) result.add(s);
    }

    if (result.length >= effectiveCap && size > effectiveCap) {
      warnings.add(
        "'$token' truncated at $effectiveCap IPs (mode: ${mode.name})",
      );
    }
  }

  /// نمونه‌برداری یکنواخت از یک CIDR بزرگ.
  ///
  /// مثال: از `23.32.0.0/11` (2M IP)، 256 نمونه می‌گیرد.
  /// فاصله = size / samplesPerCidr
  static void _sampleCidr({
    required String token,
    required int base,
    required int prefix,
    required int size,
    required List<String> result,
    required Set<String> seen,
    required List<String> warnings,
    required int samplesPerCidr,
  }) {
    warnings.add(
      "'$token' is /$prefix (${_formatBigNumber(size)} IPs) — "
      'sampling $samplesPerCidr IPs uniformly',
    );

    final hostBits = 32 - prefix;
    final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
    final baseAligned = base & mask;

    // step یکنواخت
    final step = (size / samplesPerCidr).ceil().clamp(1, size);

    for (var i = 0; i < size; i += step) {
      final s = IpValidators.formatIPv4((baseAligned + i) & 0xFFFFFFFF);
      if (seen.add(s)) result.add(s);
      if (result.length > 100000) break; // safety
    }
  }

  static void _expandDashRange(
    String startStr,
    String endStr,
    List<String> result,
    Set<String> seen,
    List<String> warnings, {
    required IpScanMode mode,
  }) {
    if (!IpValidators.isValidIPv4(startStr)) {
      warnings.add('bad start');
      return;
    }

    final startAddr = IpValidators.ipv4ToUInt(startStr);
    int endAddr;

    if (endStr.contains('.')) {
      if (!IpValidators.isValidIPv4(endStr)) return;
      endAddr = IpValidators.ipv4ToUInt(endStr);
    } else {
      final last = int.tryParse(endStr);
      if (last == null || last < 0 || last > 255) return;
      endAddr = (startAddr & 0xFFFFFF00) | last;
    }

    if (endAddr < startAddr) return;

    final rangeSize = endAddr - startAddr + 1;
    final cap = mode.maxTotalIps > 0 ? mode.maxTotalIps : rangeSize;

    // در حالت‌های quick/balanced، اگر رنج خیلی بزرگ باشد، نمونه بگیر
    if (mode.isSampling && rangeSize > 1024) {
      final step = (rangeSize / mode.samplesPerCidr).ceil().clamp(1, rangeSize);
      warnings.add(
        "'$startStr-$endStr' is a large range (${_formatBigNumber(rangeSize)} IPs) — "
        'sampling ${mode.samplesPerCidr} IPs uniformly',
      );
      for (var a = startAddr; a <= endAddr; a += step) {
        final s = IpValidators.formatIPv4(a);
        if (seen.add(s)) result.add(s);
        if (result.length >= cap) break;
      }
      return;
    }

    for (var a = startAddr; a <= endAddr && result.length < cap; a++) {
      final s = IpValidators.formatIPv4(a);
      if (seen.add(s)) result.add(s);
      if (a == 0xFFFFFFFF) break;
    }
  }

  static String _formatBigNumber(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}K';
    }
    return '$n';
  }
}
