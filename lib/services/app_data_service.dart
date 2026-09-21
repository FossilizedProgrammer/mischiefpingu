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

  static List<String> get initLogs => DataInitializerService.initLogs;

  static bool get isWindows => PlatformInfo.isWindows;
  static bool get isLinux => PlatformInfo.isLinux;
  static String get exeExt => PlatformInfo.exeExt;
  static String get osFolder => PlatformInfo.osFolder;
  static bool get isRunningInAppImage => PlatformInfo.isRunningInAppImage;
  static bool get isRoot => PlatformInfo.isRoot;
  static String? get realUsername => PlatformInfo.realUsername;
  static String? get realUserHome => PlatformInfo.realUserHome;

  static Future<void> fixOwnership(String path) =>
      OwnershipService.fixOwnership(path);

  static Future<void> fixDataDirOwnership() async {
    if (isWindows) return;
    final dir = await getDataDir();
    await OwnershipService.fixOwnership(dir);
  }

  static Future<String> getDataDir() => DataPathsService.getDataDir();

  static Future<void> initializeDataFiles() =>
      DataInitializerService.initializeDataFiles();

  static String getExeDir() => DataPathsService.getExeDir();
  static String getPlatformDir() => DataPathsService.getPlatformDir();

  static Future<String> getBinaryPath(String name) =>
      DataPathsService.getBinaryPath(name);

  static Future<String?> resolveBinaryPath(String name) =>
      DataPathsService.resolveBinaryPath(name);

  static Future<List<String>> binaryCandidates(String name) =>
      DataPathsService.binaryCandidates(name);

  static Future<void> logBinaryCandidates(
    String name, {
    void Function(String)? log,
  }) => DataPathsService.logBinaryCandidates(name, log: log);

  static Future<String> getBinaryPathForWrite(String name) =>
      DataPathsService.getBinaryPathForWrite(name);

  /// مسیر ذخیره‌سازی SSTP (برای نوشتن — همیشه dataDir).
  static Future<String> getSstpBinaryPath() =>
      DataPathsService.getSstpBinaryPath();

  /// مسیر اجرای SSTP — همه مسیرها را چک می‌کند.
  static Future<String> getSstpBinaryPathForExecution() =>
      DataPathsService.getSstpBinaryPathForExecution();

  static Future<String> getTorDir() => DataPathsService.getTorDir();

  static Future<String> getTorBinaryPath() =>
      DataPathsService.getTorBinaryPath();

  static Future<String?> findTorBinary() => DataPathsService.findTorBinary();

  static Future<List<String>> torBinaryCandidates() =>
      DataPathsService.torBinaryCandidates();

  static Future<void> logTorBinaryCandidates({void Function(String)? log}) =>
      DataPathsService.logTorBinaryCandidates(log: log);

  static Future<String> ensureTorDir() => DataPathsService.ensureTorDir();

  static Future<List<String>> aetherPtCandidates() =>
      DataPathsService.aetherPtCandidates();

  static Future<String?> findAetherPtDir() =>
      DataPathsService.findAetherPtDir();

  static Future<String> getGatewayHistoryDbPath() async {
    final dir = await getDataDir();
    return '$dir/gateway_history.db';
  }
}
