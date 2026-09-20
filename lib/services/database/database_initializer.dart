library;

import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// ═══════════════════════════════════════════════════════════════
///  DatabaseInitializer — راه‌اندازی sqflite در دسکتاپ.
///
///  در ویندوز و لینوکس باید یک بار `initFfi` را صدا بزنیم تا
///  sqflite بتواند با SQLite سیستمی کار کند.
///
///  این تابع idempotent است — اگر چند بار صدا زده بشه مشکلی نیست.
/// ═══════════════════════════════════════════════════════════════
class DatabaseInitializer {
  DatabaseInitializer._();

  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}
