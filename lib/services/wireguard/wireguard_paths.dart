library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardPaths — مسیرهای فایل‌های WireGuard.
///
///  ساختار:
///    `<dataDir>/wireguard/`
///      ├── wireproxy.conf  (فایل ورودی wireproxy)
///      ├── wg.conf          (کانفیگ استاندارد WireGuard)
///      └── reserved         (اختیاری)
/// ═══════════════════════════════════════════════════════════════
class WireGuardPaths {
  WireGuardPaths._();

  static Future<String> workDir() async {
    final dataDir = await AppDataService.getDataDir();
    final dir = p.join(dataDir, 'wireguard');
    await Directory(dir).create(recursive: true);
    return dir;
  }

  /// مسیر فایل کانفیگ استاندارد WireGuard که wireproxy باید بخونه.
  static Future<String> wgConfigPath() async {
    final dir = await workDir();
    return p.join(dir, 'wg.conf');
  }

  /// مسیر فایل کانفیگ wrapper که به wireproxy داده می‌شه.
  static Future<String> wireproxyConfigPath() async {
    final dir = await workDir();
    return p.join(dir, 'wireproxy.conf');
  }

  /// لیست مسیرهای احتمالی باینری wireproxy.
  static Future<List<String>> binaryCandidates() async {
    return AppDataService.binaryCandidates('wireproxy');
  }

  /// پیدا کردن باینری.
  static Future<String?> resolveBinary() async {
    return AppDataService.resolveBinaryPath('wireproxy');
  }

  /// مسیر پیش‌فرض برای نوشتن.
  static Future<String> binaryPathForWrite() async {
    return AppDataService.getBinaryPathForWrite('wireproxy');
  }
}
