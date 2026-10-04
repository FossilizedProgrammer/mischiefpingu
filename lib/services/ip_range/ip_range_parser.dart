library;

import 'ip_models.dart';
import 'ip_scan_mode.dart';
import 'ip_validators.dart';
import 'ip_expanders.dart';

export 'ip_models.dart';
export 'ip_scan_mode.dart';

class IpRangeParser {
  IpRangeParser._();

  /// حالت پیش‌فرض.
  static const IpScanMode defaultMode = IpScanMode.balanced;

  /// expand با حالت مشخص.
  ///
  /// [mode] تعیین می‌کند چند IP تولید شود و آیا نمونه‌برداری انجام شود.
  static ExpansionResult expandWithDiagnostics(
    String? input, {
    IpScanMode mode = defaultMode,
  }) {
    final ips = <String>[];
    final warnings = <String>[];
    if (input == null || input.trim().isEmpty) {
      return ExpansionResult(ips, warnings, false);
    }
    final seen = <String>{};
    var hitCap = false;

    final cap = mode.maxTotalIps;

    for (final rawLine in input.split('\n')) {
      final line = IpValidators.stripComment(rawLine).trim();
      if (line.isEmpty) continue;

      for (final token in line.split(RegExp(r'[\s,;]+'))) {
        if (token.isEmpty) continue;
        if (cap > 0 && ips.length >= cap) {
          hitCap = true;
          return ExpansionResult(ips, warnings, hitCap);
        }
        IpExpanders.expandToken(
          token,
          ips,
          seen,
          warnings,
          mode: mode,
        );
      }
    }
    return ExpansionResult(ips, warnings, hitCap);
  }

  /// متد قدیمی — برای سازگاری با کد موجود.
  @Deprecated('Use expandWithDiagnostics(input, mode: ...) instead')
  static ExpansionResult expandSampled(
    String? input, {
    int samplesPerCidr = 256,
  }) =>
      expandWithDiagnostics(input, mode: IpScanMode.balanced);
}
