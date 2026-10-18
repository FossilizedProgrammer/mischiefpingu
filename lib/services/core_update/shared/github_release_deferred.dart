library;

import 'dart:io';

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../core_update_pending.dart';
import 'github_core_spec.dart';

class GithubReleaseDeferred {
  final GithubCoreSpec spec;
  final CoreUpdatePendingManager pending;
  final void Function(String)? log;

  const GithubReleaseDeferred({
    required this.spec,
    required this.pending,
    this.log,
  });

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

  /// ذخیرهٔ باینری دانلود‌شده در staging و ثبت آپدیت معلق.
  ///
  /// [coreId] و [displayName] برای باینری‌های اضافی (extra) قابل بازنویسی‌اند
  /// تا هر کدام یک رکورد معلق جدا داشته باشند.
  Future<void> defer({
    required String found,
    required String dest,
    required String binaryName,
    required String version,
    String? coreId,
    String? displayName,
  }) async {
    final effectiveCoreId = coreId ?? spec.coreId;
    final effectiveName = displayName ?? spec.displayName;
    final stagingDir = await Directory.systemTemp.createTemp(
      '${spec.tempPrefix}deferred_',
    );
    final stagingPath = '${stagingDir.path}/$binaryName';
    await File(found).copy(stagingPath);
    if (!_isWin) {
      await Process.run('chmod', ['+x', stagingPath]);
    }
    await pending.add(
      PendingCoreUpdate(
        coreId: effectiveCoreId,
        stagingPath: stagingPath,
        destPath: dest,
        version: version,
        createdAt: DateTime.now(),
      ),
    );
    _log(
      '★ $effectiveName update downloaded ($version) — deferred, will apply on next startup',
    );
  }

  /// تأیید نصب موفق — فایل موجود است و اندازه‌اش صفر نیست.
  Future<void> verify(String dest) async {
    final exists = await File(dest).exists();
    final size = await CoreUpdateUtils.fileSize(dest);
    _log('→ VERIFY: file exists at $dest = $exists (size: $size bytes)');
    if (!exists || size == 0) {
      throw StateError(
        'Update reported success but file not found at $dest. '
        'Check dataDir permissions.',
      );
    }
  }
}
