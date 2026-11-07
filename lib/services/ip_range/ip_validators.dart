library;

class IpValidators {
  IpValidators._();

  static final rangeRe = RegExp(
    r'^\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(\d{1,3}(?:\.\d{1,3}\.\d{1,3}\.\d{1,3})?)\s*$',
  );

  /// حذف کامنت‌های `#` و `//` از خط.
  static String stripComment(String line) {
    final hash = line.indexOf('#');
    if (hash >= 0) line = line.substring(0, hash);
    final sl = line.indexOf('//');
    if (sl >= 0) line = line.substring(0, sl);
    return line;
  }

  /// بررسی معتبر بودن IPv4.
  static bool isValidIPv4(String s) {
    final p = s.split('.');
    if (p.length != 4) return false;
    for (final x in p) {
      final n = int.tryParse(x);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  /// تبدیل IPv4 به عدد 32 بیتی.
  static int ipv4ToUInt(String ip) {
    final b = ip.split('.').map(int.parse).toList();
    return ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]) & 0xFFFFFFFF;
  }

  /// تبدیل عدد 32 بیتی به IPv4.
  static String formatIPv4(int addr) =>
      '${(addr >> 24) & 0xFF}.${(addr >> 16) & 0xFF}.${(addr >> 8) & 0xFF}.${addr & 0xFF}';
}
