library;

class ExpansionResult {
  final List<String> ips;
  final List<String> warnings;
  final bool hitCap;

  ExpansionResult(this.ips, this.warnings, this.hitCap);
}
