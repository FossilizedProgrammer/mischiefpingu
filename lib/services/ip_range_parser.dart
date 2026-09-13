class ExpansionResult {
  final List<String> ips;
  final List<String> warnings;
  final bool hitCap;
  ExpansionResult(this.ips, this.warnings, this.hitCap);
}

class IpRangeParser {
  static const int maxEntries = 20000;
  static const int cidrMaxHosts = 65536;

  static final _rangeRe = RegExp(
    r'^\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(\d{1,3}(?:\.\d{1,3}\.\d{1,3}\.\d{1,3})?)\s*$',
  );

  static ExpansionResult expandWithDiagnostics(String? input) {
    final ips = <String>[];
    final warnings = <String>[];
    if (input == null || input.trim().isEmpty) {
      return ExpansionResult(ips, warnings, false);
    }
    final seen = <String>{};
    var hitCap = false;
    for (final rawLine in input.split('\n')) {
      var line = _stripComment(rawLine).trim();
      if (line.isEmpty) continue;
      for (final token in line.split(RegExp(r'[\s,;]+'))) {
        if (token.isEmpty) continue;
        if (ips.length >= maxEntries) {
          hitCap = true;
          return ExpansionResult(ips, warnings, hitCap);
        }
        _expandToken(token, ips, seen, warnings);
      }
    }
    return ExpansionResult(ips, warnings, hitCap);
  }

  static String _stripComment(String line) {
    final hash = line.indexOf('#');
    if (hash >= 0) line = line.substring(0, hash);
    final sl = line.indexOf('//');
    if (sl >= 0) line = line.substring(0, sl);
    return line;
  }

  static void _expandToken(
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
    final m = _rangeRe.firstMatch(token);
    if (m != null) {
      _expandDashRange(m.group(1)!, m.group(2)!, result, seen, warnings);
      return;
    }
    if (_tryParseIPv4(token)) {
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
    if (!_tryParseIPv4(ipPart) || prefix == null || prefix < 0 || prefix > 32) {
      warnings.add("'$token' bad CIDR");
      return;
    }
    final base = _ipv4ToUInt(ipPart);
    final hostBits = 32 - prefix;
    final size = hostBits >= 32 ? 0xFFFFFFFF : (1 << hostBits);
    if (size > cidrMaxHosts) {
      warnings.add("'$token' too large (max /$prefix limited)");
      final step = (size / cidrMaxHosts).ceil();
      final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
      final baseAligned = base & mask;
      for (var i = 0; i < size && result.length < maxEntries; i += step) {
        final s = _formatIPv4((baseAligned + i) & 0xFFFFFFFF);
        if (seen.add(s)) result.add(s);
      }
      return;
    }
    final mask = hostBits >= 32 ? 0 : (~((1 << hostBits) - 1) & 0xFFFFFFFF);
    final baseAligned = base & mask;
    for (var i = 0; i < size && result.length < maxEntries; i++) {
      final s = _formatIPv4((baseAligned + i) & 0xFFFFFFFF);
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
    if (!_tryParseIPv4(startStr)) {
      warnings.add('bad start');
      return;
    }
    final startAddr = _ipv4ToUInt(startStr);
    int endAddr;
    if (endStr.contains('.')) {
      if (!_tryParseIPv4(endStr)) return;
      endAddr = _ipv4ToUInt(endStr);
    } else {
      final last = int.tryParse(endStr);
      if (last == null || last < 0 || last > 255) return;
      endAddr = (startAddr & 0xFFFFFF00) | last;
    }
    if (endAddr < startAddr) return;
    for (var a = startAddr; a <= endAddr && result.length < maxEntries; a++) {
      final s = _formatIPv4(a);
      if (seen.add(s)) result.add(s);
      if (a == 0xFFFFFFFF) break;
    }
  }

  static bool _tryParseIPv4(String s) {
    final p = s.split('.');
    if (p.length != 4) return false;
    for (final x in p) {
      final n = int.tryParse(x);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  static int _ipv4ToUInt(String ip) {
    final b = ip.split('.').map(int.parse).toList();
    return ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]) & 0xFFFFFFFF;
  }

  static String _formatIPv4(int addr) =>
      '${(addr >> 24) & 0xFF}.${(addr >> 16) & 0xFF}.${(addr >> 8) & 0xFF}.${addr & 0xFF}';
}
