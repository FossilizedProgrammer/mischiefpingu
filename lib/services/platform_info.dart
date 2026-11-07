import 'dart:io';

/// اطلاعات پلتفرم و محیط اجرا
class PlatformInfo {
  PlatformInfo._();

  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static String get exeExt => isWindows ? '.exe' : '';
  static String get osFolder => isWindows ? 'windows' : 'linux';

  static bool get isRunningInAppImage {
    if (isWindows) return false;
    return Platform.environment.containsKey('APPIMAGE') ||
        Platform.environment.containsKey('APPDIR');
  }

  static bool get isRoot {
    if (isWindows) {
      try {
        final r = Process.runSync('net', ['session']);
        return r.exitCode == 0;
      } catch (_) {}
      return false;
    }
    try {
      final r = Process.runSync('id', ['-u']);
      if (r.exitCode == 0 && r.stdout.toString().trim() == '0') return true;
    } catch (_) {}
    final user = Platform.environment['USER'] ?? '';
    final home = Platform.environment['HOME'] ?? '';
    return user == 'root' || home == '/root';
  }

  static String? get realUsername {
    if (isWindows) return Platform.environment['USERNAME'];
    final sudo = Platform.environment['SUDO_USER'];
    if (sudo != null && sudo.isNotEmpty && sudo != 'root') return sudo;
    final pkUid = Platform.environment['PKEXEC_UID'];
    if (pkUid != null && pkUid.isNotEmpty && pkUid != '0') {
      try {
        final r = Process.runSync('getent', ['passwd', pkUid]);
        if (r.exitCode == 0) {
          final name = r.stdout.toString().split(':').first.trim();
          if (name.isNotEmpty && name != 'root') return name;
        }
      } catch (_) {}
    }
    final logname = Platform.environment['LOGNAME'];
    if (logname != null && logname.isNotEmpty && logname != 'root') {
      return logname;
    }
    return null;
  }

  static String? get realUserHome {
    if (isWindows) return Platform.environment['USERPROFILE'];
    final user = realUsername;
    if (user == null) return null;
    try {
      final r = Process.runSync('getent', ['passwd', user]);
      if (r.exitCode == 0) {
        final parts = r.stdout.toString().trim().split(':');
        if (parts.length >= 6 && parts[5].isNotEmpty) return parts[5];
      }
    } catch (_) {}
    final candidate = '/home/$user';
    if (Directory(candidate).existsSync()) return candidate;
    return null;
  }
}
