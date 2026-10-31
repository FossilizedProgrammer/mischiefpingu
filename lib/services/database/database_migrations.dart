library;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_schema.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onCreate(Database db, int version) async {
    // v1
    await db.execute(DatabaseSchema.createTableGatewayHistory);
    await db.execute(DatabaseSchema.createIndexScore);
    await db.execute(DatabaseSchema.createIndexProtocol);
    await db.execute(DatabaseSchema.createIndexLastSuccess);

    // v2
    await db.execute(DatabaseSchema.createTableAetherEvents);
    await db.execute(DatabaseSchema.createIndexAetherEventsTs);
    await db.execute(DatabaseSchema.createIndexAetherEventsProfile);

    // v3
    await db.execute(DatabaseSchema.createTableProfilePerformance);
    await db.execute(DatabaseSchema.createIndexProfilePerf);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // v1 → v2
    if (oldVersion < 2) {
      await db.execute(DatabaseSchema.createTableAetherEvents);
      await db.execute(DatabaseSchema.createIndexAetherEventsTs);
      await db.execute(DatabaseSchema.createIndexAetherEventsProfile);
    }

    // v2 → v3
    if (oldVersion < 3) {
      await db.execute(DatabaseSchema.createTableProfilePerformance);
      await db.execute(DatabaseSchema.createIndexProfilePerf);
    }

    // v3 → v4
    if (oldVersion < 4) {
      await _upgradeToV4(db);
    }
  }

  /// v3 → v4: افزودن ستون‌های Quality.
  static Future<void> _upgradeToV4(Database db) async {
    await db.execute(
      'ALTER TABLE ${DatabaseSchema.tableGatewayHistory} '
      'ADD COLUMN ${DatabaseSchema.colAvgSessionUptimeSec} '
      'INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE ${DatabaseSchema.tableGatewayHistory} '
      'ADD COLUMN ${DatabaseSchema.colReconnectCount} '
      'INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE ${DatabaseSchema.tableGatewayHistory} '
      'ADD COLUMN ${DatabaseSchema.colTotalAttempts} '
      'INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE ${DatabaseSchema.tableGatewayHistory} '
      'ADD COLUMN ${DatabaseSchema.colLastUptimeSamples} '
      "TEXT NOT NULL DEFAULT '[]'",
    );
  }
}
