library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_data_service.dart';
import '../../models/wireguard_core_type.dart'; // 🆕 import مشترک

/// ═══════════════════════════════════════════════════════════════
///  WireGuardPaths — مسیرهای فایل‌های WireGuard + پشتیبانی چند هسته.
///
///  ⚠️ enum `WireGuardCoreType` از این فایل حذف شد و حالا
///  فقط یک نسخه در `lib/models/wireguard_core_type.dart` وجود دارد.
/// ═══════════════════════════════════════════════════════════════
class WireGuardPaths {
  WireGuardPaths._();

  static Future<String> workDir() async {
    final dataDir = await AppDataService.getDataDir();
    final dir = p.join(dataDir, 'wireguard');
    await Directory(dir).create(recursive: true);
    return dir;
  }

  static Future<String> wgConfigPath() async {
    final dir = await workDir();
    return p.join(dir, 'wg.conf');
  }

  static Future<String> wireproxyConfigPath() async {
    final dir = await workDir();
    return p.join(dir, 'wireproxy.conf');
  }

  static String binaryName(WireGuardCoreType type) {
    switch (type) {
      case WireGuardCoreType.standard:
        return 'wireproxy';
      case WireGuardCoreType.amnezia:
        return 'wireproxy-awg';
    }
  }

  static Future<List<String>> binaryCandidates(WireGuardCoreType type) async {
    return AppDataService.binaryCandidates(binaryName(type));
  }

  static Future<String?> resolveBinary(WireGuardCoreType type) async {
    return AppDataService.resolveBinaryPath(binaryName(type));
  }

  static Future<String> binaryPathForWrite(WireGuardCoreType type) async {
    return AppDataService.getBinaryPathForWrite(binaryName(type));
  }
}
