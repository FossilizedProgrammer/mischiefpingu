// lib/screens/widgets/sstp_fetcher/sstp_country_helpers.dart
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  Helperهای رنگ و نام کشور برای SSTP
/// ═══════════════════════════════════════════════════════════════
class SstpCountryHelpers {
  SstpCountryHelpers._();

  static String shortName(String name, String code) {
    if (name.isEmpty && code.isEmpty) return 'Unknown';
    if (name.isEmpty) return code;
    if (name.length > 22) return code.isNotEmpty ? code : name;
    return name;
  }

  static Color badgeColor(String code, ThemeData theme) {
    if (code.isEmpty) return theme.colorScheme.outline;
    final hash = code.codeUnits.fold<int>(0, (a, b) => a + b);
    final palette = [
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.deepOrange,
      Colors.brown,
    ];
    return palette[hash % palette.length];
  }
}
