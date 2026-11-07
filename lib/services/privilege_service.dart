import 'dart:io';

class PrivilegeService {
  static bool? _cached;

  /// آیا برنامه با دسترسی root (لینوکس) یا Admin (ویندوز) اجرا شده؟
  static Future<bool> isElevated() async {
    if (_cached != null) return _cached!;
    if (Platform.isWindows) {
      try {
        final result = await Process.run('net', ['session']);
        _cached = result.exitCode == 0;
        return _cached!;
      } catch (_) {}
      _cached = false;
      return false;
    }
    try {
      final result = await Process.run('id', ['-u']);
      _cached = result.exitCode == 0 && result.stdout.toString().trim() == '0';
      return _cached!;
    } catch (_) {}
    _cached = false;
    return false;
  }
}
