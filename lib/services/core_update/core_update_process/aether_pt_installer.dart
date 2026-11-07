part of 'directory_copier.dart';

/// ═══════════════════════════════════════════════════════════════
///  نصب پوشه `pt` مخصوص Aether.
///
///  این منطق قبلاً توی DirectoryCopier بود. حالا جدا شده
///  چون فقط برای Aether استفاده می‌شه.
///
///  ⚠️ این extension از `part of` استفاده می‌کنه، پس به
///  فیلدهای private DirectoryCopier (مثل `_log`) دسترسی داره.
/// ═══════════════════════════════════════════════════════════════
extension AetherPtInstaller on DirectoryCopier {
  /// نصب پوشه `pt` از staging یا fallback به dataDir.
  ///
  /// اگر پوشه `pt` در stagingSource پیدا نشه، fallbackSource
  /// رو امتحان می‌کنه. اگه هیچ‌کدوم پیدا نشن، فقط لاگ می‌کنه.
  ///
  /// ⚠️ این متد از `core_update_process_utils.dart` به عنوان
  /// `installAetherPtDirectory` (facade) صدا زده می‌شه.
  Future<void> installAetherPtDirectoryImpl({
    required String dataDir,
    String? stagingSource,
    String? fallbackSource,
  }) async {
    final destPt = p.join(dataDir, 'pt');

    String? srcPt;

    if (stagingSource != null) {
      final candidate = p.join(stagingSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null && fallbackSource != null) {
      final candidate = p.join(fallbackSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null) {
      _log(
        '→ installAetherPtDirectory: no `pt` directory found '
        '(staging=$stagingSource, fallback=$fallbackSource)',
      );
      return;
    }

    final destPtDir = Directory(destPt);
    if (await destPtDir.exists()) {
      try {
        await destPtDir.delete(recursive: true);
        _log('→ Removed old `pt` directory before install');
      } catch (e) {
        _log('⚠ Could not remove old `pt`: $e — will overwrite in place');
      }
    }

    _log('→ Installing Aether `pt` directory: $srcPt → $destPt');
    final count = await copyDirectoryTree(src: srcPt, dest: destPt);
    _log('★ Aether `pt` directory installed ($count files) → $destPt');
  }
}
