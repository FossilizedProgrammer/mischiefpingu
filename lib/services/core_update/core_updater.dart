// lib/services/core_update/core_updater.dart
//
// ═══════════════════════════════════════════════════════════════
//  CoreUpdater — interface مشترک برای همهٔ updaterها
//  (تفکیک شده از core_update_service.dart)
//
//  هدف: حذف switch/case از CoreUpdateService و افزودن
//  core جدید فقط با اضافه کردن به map.
// ═══════════════════════════════════════════════════════════════
library;

import '../core_update_models.dart';

abstract class CoreUpdater {
  /// شناسهٔ core (aether / tor / psiphon / sunandlion / sstp).
  String get coreId;

  /// بررسی وجود آپدیت.
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  });

  /// دانلود و نصب آپدیت.
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  });
}
