library;

import 'dart:io';

import '../../app_data_service.dart';

/// مدیریت چک و kill پروسه‌های در حال اجرا.
class ProcessController {
  final void Function(String)? log;
  ProcessController({this.log});

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

  Future<bool> isProcessRunning(String binaryName) async {
    try {
      if (_isWin) {
        final r = await Process.run('tasklist', [
          '/FI',
          'IMAGENAME eq $binaryName',
        ]);
        if (r.exitCode == 0) {
          return (r.stdout as String).contains(binaryName);
        }
      } else {
        final pattern = '(^|/)${RegExp.escape(binaryName)}\$';
        final r = await Process.run('pgrep', ['-f', pattern]);
        if (r.exitCode == 0 && (r.stdout as String).trim().isNotEmpty) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> stopProcess(String binaryName, String label) async {
    try {
      final running = await isProcessRunning(binaryName);
      if (running) {
        _log('→ $label is running — stopping it for replacement …');
        if (_isWin) {
          await Process.run('taskkill', ['/F', '/IM', binaryName]);
        } else {
          await Process.run('pkill', [
            '-f',
            '(^|/)${RegExp.escape(binaryName)}\$',
          ]);
        }
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } catch (_) {}
  }
}
