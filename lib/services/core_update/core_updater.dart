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
