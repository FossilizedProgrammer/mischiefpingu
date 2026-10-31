library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  NpvPaths — مسیرهای موتور npv (NPV Tunnel / xray درون‌پروسه).
///
///  ⚠️ نام پوشهٔ کار `npvs/` است: باینری seedشدهٔ `npv` مستقیم داخل پوشهٔ
///  داده می‌نشیند، پس یک پوشهٔ هم‌نام `npv/` کنارش باعث درگیری می‌شود.
///
///  فایل کانفیگ را فقط کاربر انتخاب می‌کند؛ نمونهٔ پیش‌فرضِ داخل برنامه
///  وجود ندارد، چون اتصال به کانفیگی که کاربر هرگز ندیده درست نیست.
/// ═══════════════════════════════════════════════════════════════
class NpvPaths {
  NpvPaths._();

  static const String binaryName = 'npv';
  static const String dataSubdir = 'npvs';

  static Future<String> workDir() async {
    final dataDir = await AppDataService.getDataDir();
    final dir = p.join(dataDir, dataSubdir);
    await Directory(dir).create(recursive: true);
    return dir;
  }

  /// مسیر کامل فایل انتخاب‌شده؛ null یعنی کاربر هنوز فایلی نداده
  /// یا فایلِ ذخیره‌شده از پوشهٔ کار پاک شده است.
  static Future<String?> resolveConfigPath(String preferred) async {
    final name = preferred.trim();
    if (name.isEmpty) return null;
    final path = p.join(await workDir(), p.basename(name));
    return await File(path).exists() ? path : null;
  }

  /// کپی فایل انتخابی به پوشهٔ کار؛ basenameِ فایل مقصد را می‌دهد
  /// (همان چیزی که در `settings.npvConfigName` ذخیره می‌شود).
  static Future<String> importConfig(String sourcePath) async {
    final dir = await workDir();
    final source = File(sourcePath);
    var name = p.basename(sourcePath);
    if (await File(p.join(dir, name)).exists()) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      name = '${p.basenameWithoutExtension(name)}-$stamp${p.extension(name)}';
    }
    await source.copy(p.join(dir, name));
    return name;
  }

  static Future<String?> resolveBinary() =>
      AppDataService.resolveBinaryPath(binaryName);
}
