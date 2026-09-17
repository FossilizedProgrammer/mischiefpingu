import 'dart:io';

/// تشخیص معماری CPU (x86_64 / aarch64 / armv7).
class CoreUpdateArch {
  CoreUpdateArch._();

  static bool get _isWin => Platform.isWindows;

  static Future<String> detect() async {
    if (_isWin) {
      final env = Platform.environment['PROCESSOR_ARCHITECTURE'];
      if (env == null) return 'x86_64';
      final e = env.toLowerCase();
      if (e.contains('arm64') || e.contains('aarch64')) return 'aarch64';
      if (e.contains('arm')) return 'armv7';
      return 'x86_64';
    }
    try {
      final r = await Process.run('uname', ['-m']);
      final m = (r.stdout as String).trim().toLowerCase();
      if (m.contains('aarch64') || m.contains('arm64')) return 'aarch64';
      if (m.contains('armv7') || m.contains('armhf')) return 'armv7';
      return 'x86_64';
    } catch (_) {
      return 'x86_64';
    }
  }
}
