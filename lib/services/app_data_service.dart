import 'platform_info.dart';
import 'ownership_service.dart';
import 'data_paths_service.dart';
import 'data_initializer_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — سازگاری کامل با کد موجود
///  تمام متدها به سرویس‌های تخصصی delegate می‌شوند:
///    • OwnershipService     → مدیریت chown/chmod
///    • DataPathsService     → مسیرها و دایرکتوری‌ها
///    • DataInitializerService → مقداردهی اولیه فایل‌ها
/// ═══════════════════════════════════════════════════════════════
class AppDataService {
  AppDataService._();

  // ─── Init Logs ───
  static List<String> get initLogs => DataInitializerService.initLogs;

  // ─── Platform Info (delegate → PlatformInfo) ───
  static bool get isWindows => PlatformInfo.isWindows;
  static bool get isLinux => PlatformInfo.isLinux;
  static String get exeExt => PlatformInfo.exeExt;
  static String get osFolder => PlatformInfo.osFolder;
  static bool get isRunningInAppImage => PlatformInfo.isRunningInAppImage;
  static bool get isRoot => PlatformInfo.isRoot;
  static String? get realUsername => PlatformInfo.realUsername;
  static String? get realUserHome => PlatformInfo.realUserHome;

  // ─── Ownership (delegate → OwnershipService) ───
  static Future<void> fixOwnership(String path) =>
      OwnershipService.fixOwnership(path);

  static Future<void> fixDataDirOwnership() async {
    if (isWindows) return;
    final dir = await getDataDir();
    await OwnershipService.fixOwnership(dir);
  }

  // ─── Data directory (delegate → DataPathsService) ───
  static Future<String> getDataDir() => DataPathsService.getDataDir();

  // ─── Initialize (delegate → DataInitializerService) ───
  static Future<void> initializeDataFiles() =>
      DataInitializerService.initializeDataFiles();

  // ─── Binary paths (delegate → DataPathsService) ───
  static Future<String> getBinaryPath(String name) =>
      DataPathsService.getBinaryPath(name);

  /// ⚠️ مسیر ذخیره‌سازی SSTP (همیشه داخل dataDir).
  /// برای نوشتن (آپدیت/دانلود) استفاده شود.
  static Future<String> getSstpBinaryPath() =>
      DataPathsService.getSstpBinaryPath();

  /// ⚠️ مسیر اجرای SSTP (اول dataDir، بعد platformDir).
  /// فقط برای اجرا استفاده شود، نه برای نوشتن.
  static Future<String> getSstpBinaryPathForExecution() =>
      DataPathsService.getSstpBinaryPathForExecution();

  static Future<String> getTorDir() => DataPathsService.getTorDir();

  static Future<String> getTorBinaryPath() =>
      DataPathsService.getTorBinaryPath();

  static Future<String?> findTorBinary() => DataPathsService.findTorBinary();

  static Future<String> ensureTorDir() => DataPathsService.ensureTorDir();
}
