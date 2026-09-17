// lib/services/ip_range/ip_models.dart
//
// ═══════════════════════════════════════════════════════════════
//  IpExpansionResult — نتیجهٔ expand کردن IP/CIDR/Range
//  (تفکیک شده از ip_range_parser.dart)
// ═══════════════════════════════════════════════════════════════
library;

class ExpansionResult {
  final List<String> ips;
  final List<String> warnings;
  final bool hitCap;

  ExpansionResult(this.ips, this.warnings, this.hitCap);
}
