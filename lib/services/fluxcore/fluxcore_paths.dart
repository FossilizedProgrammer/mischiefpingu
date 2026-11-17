library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  FluxcorePaths — مسیر باینری و کانفیگ هستهٔ Fluxcore.
///
///  باینری مثل بقیهٔ هسته‌ها از پوشهٔ داده/platform حل می‌شود. کانفیگ و
///  هویت Fluxcore زیر `fluxcore/config` می‌نشیند تا با بقیهٔ فایل‌های اپ
///  قاطی نشود و با پاک‌کردن پوشهٔ هسته قابل بازنشانی باشد.
/// ═══════════════════════════════════════════════════════════════
class FluxcorePaths {
  FluxcorePaths._();

  static const String binaryName = 'fluxcore';
  static const String dataSubdir = 'fluxcore';

  static Future<String> workDir() async {
    final dataDir = await AppDataService.getDataDir();
    final dir = p.join(dataDir, dataSubdir);
    await Directory(dir).create(recursive: true);
    return dir;
  }

  static Future<String> configHome() async {
    final dir = p.join(await workDir(), 'config');
    await Directory(dir).create(recursive: true);
    return dir;
  }

  static Future<String?> resolveBinary() =>
      AppDataService.resolveBinaryPath(binaryName);
}
