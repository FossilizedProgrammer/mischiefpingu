library;

import 'dart:io';
import '../app_data_service.dart';

class AetherAssetResolver {
  AetherAssetResolver._();

  /// نام‌های ممکن asset بر اساس معماری و پلتفرم.
  static List<String> assetNames(String arch) {
    if (AppDataService.isWindows) {
      switch (arch) {
        case 'aarch64':
          return ['aether-windows-aarch64.zip', 'aether-windows-arm64.zip'];
        default:
          return ['aether-windows-x86_64.zip'];
      }
    }
    switch (arch) {
      case 'aarch64':
        return [
          'aether-linux-aarch64-musl.tar.gz',
          'aether-linux-arm64.tar.gz'
        ];
      case 'armv7':
        return ['aether-linux-armv7.tar.gz', 'aether-linux-armv7-musl.tar.gz'];
      default:
        return [
          'aether-linux-x86_64.tar.gz',
          'aether-linux-x86_64-musl.tar.gz'
        ];
    }
  }

  /// query نسخه Aether از باینری.
  static Future<String?> queryVersion(String exe) async {
    try {
      if (!await File(exe).exists()) return null;
      final r = await Process.run(exe, ['--version'])
          .timeout(const Duration(seconds: 10));
      final out = '${r.stdout}${r.stderr}'.trim();
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }
}
