// lib/services/aether/test_executor/executor_failure_handler.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق retry delay و انتظار قابل‌لغو.
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorFailureHandler on AetherTestExecutor {
  /// محاسبه تاخیر retry.
  ///
  /// در custom-only: تاخیر طولانی‌تر (۵s شروع، +۳s هر تلاش)
  /// در حالت عادی: از AetherRetryStrategy.delayAfterAttempt
  Duration _computeRetryDelay(int attemptIndex, bool isCustomOnly) {
    if (isCustomOnly) {
      final seconds = 5 + (attemptIndex - 1) * 3;
      return Duration(seconds: seconds.clamp(5, 30));
    }
    return AetherRetryStrategy.delayAfterAttempt(attemptIndex + 1);
  }

  /// انتظار با قابلیت cancel.
  ///
  /// هر ۲۵۰ms یک بار cancelRequested رو چک می‌کنه.
  Future<void> _waitWithCancel(Duration delay) async {
    final endTime = DateTime.now().add(delay);
    const checkInterval = Duration(milliseconds: 250);

    while (DateTime.now().isBefore(endTime)) {
      if (cancelRequested) return;

      final remaining = endTime.difference(DateTime.now());
      if (remaining <= Duration.zero) return;

      final sleepTime = remaining < checkInterval ? remaining : checkInterval;
      await Future.delayed(sleepTime);
    }
  }
}
