library;

import 'dart:io';

import '../core_update_utils.dart';

class TorVersionQuery {
  TorVersionQuery._();

  /// query نسخه Tor از باینری.
  static Future<String?> query(String exe) async {
    try {
      if (!await File(exe).exists()) return null;
      final r = await Process.run(exe, [
        '--version',
      ]).timeout(const Duration(seconds: 10));
      final out = '${r.stdout}${r.stderr}'.trim();
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }

  /// query و parse نسخه.
  static Future<String?> queryAndParse(String exe) async {
    final raw = await query(exe);
    return CoreUpdateUtils.parseTorVersion(raw);
  }
}
