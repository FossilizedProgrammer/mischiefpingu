// lib/services/aether_cache_manager.dart
//
// ═══════════════════════════════════════════════════════════════
//  AetherCacheManager — مدیریت فایل‌های کش Aether
//  حذف کانفیگ‌های toml برای مجبور کردن Aether به اسکن مجدد
//  (مثلاً وقتی tunnel dead می‌شود).
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_data_service.dart';
import 'process_service.dart';

class AetherCacheManager {
  final ProcessService processService;

  AetherCacheManager({required this.processService});

  /// تمام فایل‌های کانفیگ ممکن Aether (بر اساس پروتکل‌های مختلف).
  static const List<String> _allConfigFiles = [
    'aether-masque.toml',
    'aether-wireguard.toml',
    'aether-gool.toml',
    'aether.toml',
  ];

  /// پاک‌سازی کانفیگ کش‌شده تا Aether مجبور به اسکن مجدد شود.
  ///
  /// اگر [specificProtocol] داده شود، فقط فایل مربوط به آن پروتکل
  /// حذف می‌شود. در غیر این صورت همهٔ فایل‌های کانفیگ حذف می‌شوند.
  Future<void> clearCachedGateway({String? specificProtocol}) async {
    try {
      final dataDir = await AppDataService.getDataDir();
      final filesToClear = _filesForProtocol(specificProtocol);

      var removed = 0;
      for (final name in filesToClear) {
        final f = File(p.join(dataDir, name));
        try {
          if (await f.exists()) {
            await f.delete();
            removed++;
            processService.addLog(
              '→ Removed $name (force rescan)',
              source: LogSource.aether,
            );
          }
        } catch (e) {
          processService.addLog(
            '⚠ Failed to remove $name: $e',
            source: LogSource.aether,
          );
        }
      }

      if (removed == 0) {
        processService.addLog(
          '→ No cached Aether config found to clear',
          source: LogSource.aether,
        );
      }

      await AppDataService.fixDataDirOwnership();
    } catch (e) {
      processService.addLog(
        '⚠ AetherCacheManager.clearCachedGateway error: $e',
        source: LogSource.aether,
      );
    }
  }

  /// نگاشت پروتکل به لیست فایل‌های مرتبط.
  List<String> _filesForProtocol(String? protocol) {
    switch (protocol) {
      case 'masque':
        return const ['aether-masque.toml', 'aether.toml'];
      case 'wireguard':
        return const ['aether-wireguard.toml', 'aether.toml'];
      case 'gool':
        return const ['aether-gool.toml', 'aether.toml'];
      default:
        return _allConfigFiles;
    }
  }
}
