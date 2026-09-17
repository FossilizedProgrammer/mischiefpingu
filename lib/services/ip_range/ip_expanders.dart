// lib/services/ip_range/ip_expanders.dart
//
// ═══════════════════════════════════════════════════════════════
//  IpExpanders — منطق expand کردن token به IPها
//  (تفکیک شده از ip_range_parser.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'ip_validators.dart';

class IpExpanders {
  IpExpanders._();

  static const int maxEntries = 20000;
  static const int cidrMaxHosts = 65536;

  /// expand یک token (IP / CIDR / Range) به لیست IPها.
  static void expandToken(
    String token,
    List<String> result,
    Set<String> seen,
    List<String> warnings,
  ) {
    final slash = token.indexOf('/');
    if (slash > 0) {
      _expandCidr(token, slash, result, seen, warnings);
      return;
    }

    final m = IpValidators.rangeRe.firstMatch(token);
    if (m != null) {
      _expandDashRange(m.group(1)!, m.group(2)!, result, seen, warnings);
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
    List<String> warnings,
  ) {
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

    if (size > cidrMaxHosts) {
      warnings.add("'$token' too large (max /$prefix limited)");
      final step = (size / cidrMaxHosts).ceil();
      final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
      final baseAligned = base & mask;

      for (var i = 0; i < size && result.length < maxEntries; i += step) {
        final s = IpValidators.formatIPv4((baseAligned + i) & 0xFFFFFFFF);
        if (seen.add(s)) result.add(s);
      }
      return;
    }

    final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
    final baseAligned = base & mask;

    for (var i = 0; i < size && result.length < maxEntries; i++) {
      final s = IpValidators.formatIPv4((baseAligned + i) & 0xFFFFFFFF);
      if (seen.add(s)) result.add(s);
    }
  }

  static void _expandDashRange(
    String startStr,
    String endStr,
    List<String> result,
    Set<String> seen,
    List<String> warnings,
  ) {
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

    for (var a = startAddr; a <= endAddr && result.length < maxEntries; a++) {
      final s = IpValidators.formatIPv4(a);
      if (seen.add(s)) result.add(s);
      if (a == 0xFFFFFFFF) break;
    }
  }
}
