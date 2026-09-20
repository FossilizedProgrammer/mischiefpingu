library;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_initializer.dart';
import 'database_migrations.dart';
import 'database_paths.dart';
import 'database_schema.dart';

/// ═══════════════════════════════════════════════════════════════
///  GatewayDatabase — کانکشن singleton به دیتابیس تاریخچه Gateway.
///
///  - Lazy open می‌شود.
///  - Thread-safe از طریق Future cached.
///  - در dispose بسته می‌شود.
/// ═══════════════════════════════════════════════════════════════
class GatewayDatabase {
  GatewayDatabase._();

  static Database? _db;
  static Future<Database>? _openingFuture;

  /// گرفتن کانکشن (اگر باز نباشد، باز می‌کند).
  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final existing = _openingFuture;
    if (existing != null) return existing;

    final future = _open();
    _openingFuture = future;
    try {
      final db = await future;
      _db = db;
      return db;
    } finally {
      _openingFuture = null;
    }
  }

  static Future<Database> _open() async {
    DatabaseInitializer.ensureInitialized();
    final path = await DatabasePaths.gatewayHistoryPath();

    return openDatabase(
      path,
      version: DatabaseSchema.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// بستن کانکشن (برای shutdown).
  static Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) {
      try {
        await db.close();
      } catch (_) {}
    }
  }
}
