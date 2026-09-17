// lib/services/ip_range/ip_range_parser.dart
//
// ═══════════════════════════════════════════════════════════════
//  IpRangeParser — Facade برای expand کردن IP/CIDR/Range
//  منطق به IpExpanders و IpValidators منتقل شده.
// ═══════════════════════════════════════════════════════════════
library;

import 'ip_models.dart';
import 'ip_validators.dart';
import 'ip_expanders.dart';

// Re-export برای سازگاری
export 'ip_models.dart';

class IpRangeParser {
  IpRangeParser._();

  static const int maxEntries = IpExpanders.maxEntries;
  static const int cidrMaxHosts = IpExpanders.cidrMaxHosts;

  static ExpansionResult expandWithDiagnostics(String? input) {
    final ips = <String>[];
    final warnings = <String>[];
    if (input == null || input.trim().isEmpty) {
      return ExpansionResult(ips, warnings, false);
    }
    final seen = <String>{};
    var hitCap = false;

    for (final rawLine in input.split('\n')) {
      var line = IpValidators.stripComment(rawLine).trim();
      if (line.isEmpty) continue;

      for (final token in line.split(RegExp(r'[\s,;]+'))) {
        if (token.isEmpty) continue;
        if (ips.length >= maxEntries) {
          hitCap = true;
          return ExpansionResult(ips, warnings, hitCap);
        }
        IpExpanders.expandToken(token, ips, seen, warnings);
      }
    }
    return ExpansionResult(ips, warnings, hitCap);
  }
}
