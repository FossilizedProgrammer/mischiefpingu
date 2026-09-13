import 'dart:io';
import 'platform_info.dart';

/// مدیریت ownership فایل‌ها و دایرکتوری‌ها (فقط لینوکس — در ویندوز no-op)
class OwnershipService {
  OwnershipService._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  /// تغییر مالکیت مسیر به کاربر واقعی (chown + chmod)
  /// فقط وقتی برنامه با دسترسی root اجرا شده باشد اثر دارد.
  static Future<void> fixOwnership(String path) async {
    if (PlatformInfo.isWindows) return;
    if (!PlatformInfo.isRoot) return;
    final user = PlatformInfo.realUsername;
    if (user == null) {
      _log('fixOwnership: elevated but real user unknown — skipped for $path');
      return;
    }
    try {
      final r = await Process.run('chown', ['-R', '$user:$user', path]);
      if (r.exitCode == 0) {
        _log('Ownership fixed → $user:$user for $path');
      } else {
        _log('chown failed for $path: ${r.stderr.toString().trim()}');
      }
      await Process.run('chmod', ['-R', 'u+rwX', path]);
    } catch (e) {
      _log('fixOwnership error: $e');
    }
  }
}
