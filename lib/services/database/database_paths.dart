library;

import 'package:path/path.dart' as p;

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  DatabasePaths — مسیرهای فایل دیتابیس در dataDir.
/// ═══════════════════════════════════════════════════════════════
class DatabasePaths {
  DatabasePaths._();

  static const String gatewayHistoryDb = 'gateway_history.db';

  /// مسیر کامل فایل دیتابیس تاریخچه Gateway.
  static Future<String> gatewayHistoryPath() async {
    final dataDir = await AppDataService.getDataDir();
    return p.join(dataDir, gatewayHistoryDb);
  }
}
