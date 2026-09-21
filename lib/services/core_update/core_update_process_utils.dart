library;

import 'core_update_process/binary_replacer.dart';
import 'core_update_process/directory_copier.dart';
import 'core_update_process/platform_binary_sync.dart';
import 'core_update_process/process_controller.dart';
import 'core_update_archive_extractor.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — API عمومی CoreUpdateProcessUtils حفظ می‌شود،
///  پیاده‌سازی به زیرسرویس‌ها delegate شده است.
///
///  ⚠️ `installAetherPtDirectory` از extension `AetherPtInstaller`
///  روی `DirectoryCopier` استفاده می‌کنه (روش پیاده‌سازی نامش
///  `installAetherPtDirectoryImpl` هست).
/// ═══════════════════════════════════════════════════════════════
class CoreUpdateProcessUtils {
  final void Function(String)? log;

  late final CoreUpdateArchiveExtractor _archive = CoreUpdateArchiveExtractor(
    log: log,
  );
  late final ProcessController _process = ProcessController(log: log);
  late final BinaryReplacer _replacer = BinaryReplacer(log: log);
  late final DirectoryCopier _copier = DirectoryCopier(log: log);
  late final PlatformBinarySync _platformSync = PlatformBinarySync(
    log: log,
    replacer: _replacer,
    binaryNameForCore: binaryNameForCore,
  );

  CoreUpdateProcessUtils({this.log});

  Future<void> extractArchive(String archive, String destDir) =>
      _archive.extract(archive, destDir);

  String binaryNameForCore(String coreId) => _archive.binaryNameForCore(coreId);

  Future<bool> isProcessRunning(String binaryName) =>
      _process.isProcessRunning(binaryName);

  Future<void> stopProcess(String binaryName, String label) =>
      _process.stopProcess(binaryName, label);

  Future<int> replaceBinary(String src, String dest) =>
      _replacer.replaceBinary(src, dest);

  Future<int> copyDirectoryTree({
    required String src,
    required String dest,
    bool skipIfExists = false,
  }) => _copier.copyDirectoryTree(
    src: src,
    dest: dest,
    skipIfExists: skipIfExists,
  );

  /// نصب پوشه `pt` مخصوص Aether.
  ///
  /// ⚠️ پیاده‌سازی در `AetherPtInstaller.installAetherPtDirectoryImpl`
  /// هست. این متد فقط یک facade عمومی هست تا API حفظ بشه.
  Future<void> installAetherPtDirectory({
    required String dataDir,
    String? stagingSource,
    String? fallbackSource,
  }) => _copier.installAetherPtDirectoryImpl(
    dataDir: dataDir,
    stagingSource: stagingSource,
    fallbackSource: fallbackSource,
  );

  Future<void> updateExecutableDirBinary(String coreId, String stagingPath) =>
      _platformSync.updateExecutableDirBinary(coreId, stagingPath);
}
