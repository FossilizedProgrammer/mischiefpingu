library;

import 'data_paths/data_dir_resolver.dart';
import 'data_paths/binary_paths.dart';
import 'data_paths/tor_paths.dart';
import 'data_paths/aether_paths.dart';
import 'platform_info.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — API عمومی DataPathsService حفظ می‌شود.
/// ═══════════════════════════════════════════════════════════════
class DataPathsService {
  DataPathsService._();

  static bool get isWindows => PlatformInfo.isWindows;
  static bool get isLinux => PlatformInfo.isLinux;
  static String get exeExt => PlatformInfo.exeExt;
  static String get osFolder => PlatformInfo.osFolder;
  static bool get isRunningInAppImage => PlatformInfo.isRunningInAppImage;

  static Future<String> getDataDir() => DataDirResolver.getDataDir();

  static String getPlatformDir() => DataDirResolver.getPlatformDir();
  static String getExeDir() => DataDirResolver.getExeDir();

  static Future<List<String>> binaryCandidates(String name) =>
      BinaryPathsService.binaryCandidates(name);

  static Future<String?> resolveBinaryPath(String name) =>
      BinaryPathsService.resolveBinaryPath(name);

  static Future<String> getBinaryPath(String name) =>
      BinaryPathsService.getBinaryPath(name);

  static Future<String> getBinaryPathForWrite(String name) =>
      BinaryPathsService.getBinaryPathForWrite(name);

  static Future<void> logBinaryCandidates(
    String name, {
    void Function(String)? log,
  }) => BinaryPathsService.logBinaryCandidates(name, log: log);

  static Future<String> getSstpBinaryPath() =>
      BinaryPathsService.getSstpBinaryPath();

  static Future<String> getSstpBinaryPathForExecution() =>
      BinaryPathsService.getSstpBinaryPathForExecution();

  static Future<List<String>> torBinaryCandidates() =>
      TorPathsService.torBinaryCandidates();

  static Future<String> getTorDir() => TorPathsService.getTorDir();
  static Future<String> getTorBinaryPath() =>
      TorPathsService.getTorBinaryPath();
  static Future<String?> findTorBinary() => TorPathsService.findTorBinary();

  static Future<void> logTorBinaryCandidates({void Function(String)? log}) =>
      TorPathsService.logTorBinaryCandidates(log: log);

  static Future<String> ensureTorDir() => TorPathsService.ensureTorDir();

  static Future<List<String>> aetherPtCandidates() =>
      AetherPathsService.aetherPtCandidates();

  static Future<String?> findAetherPtDir() =>
      AetherPathsService.findAetherPtDir();
}
