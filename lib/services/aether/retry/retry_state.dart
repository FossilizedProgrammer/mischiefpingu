// lib/services/aether/retry/retry_state.dart

library;

/// ═══════════════════════════════════════════════════════════════
///  RetryState — state یک چرخه‌ی retry برای Aether.
///
///  این کلاس mutable است و در طول یک چرخه‌ی اتصال نگه داشته میشه.
///  به UI این امکان رو میده که شماره‌ی تلاش فعلی رو ببینه.
///
///  ⚠️ تغییر: `beginAttempt` حالا از `maxAttempts` فراتر نمی‌ره
///  تا UI شماره‌ی اشتباه نشون نده.
/// ═══════════════════════════════════════════════════════════════
class RetryState {
  /// شماره تلاش فعلی (1-based). 0 = هنوز شروع نشده.
  int currentAttempt;

  /// حداکثر تعداد تلاش.
  final int maxAttempts;

  /// پروتکل فعلی در حال تلاش.
  String currentProtocol;

  /// MASQUE option فعلی.
  String currentMasque;

  /// آیا کاربر cancel درخواست کرده؟
  bool cancelRequested;

  /// زمان شروع چرخه.
  final DateTime startedAt;

  /// آخرین خطا.
  String? lastError;

  RetryState({
    required this.maxAttempts,
    required this.currentProtocol,
    required this.currentMasque,
    DateTime? startedAt,
    this.currentAttempt = 0,
    this.cancelRequested = false,
    this.lastError,
  }) : startedAt = startedAt ?? DateTime.now();

  /// آیا هنوز می‌تونیم تلاش کنیم؟
  bool get canAttempt => !cancelRequested && currentAttempt < maxAttempts;

  /// آیا به سقف تلاش رسیدیم؟
  bool get isAtMaxAttempts => currentAttempt >= maxAttempts;

  /// پیشرفت (0.0..1.0).
  double get progress {
    if (maxAttempts == 0) return 0.0;
    return (currentAttempt / maxAttempts).clamp(0.0, 1.0);
  }

  /// متن وضعیت برای UI.
  String get statusText {
    if (currentAttempt == 0) return 'Starting…';
    return 'Attempt $currentAttempt/$maxAttempts';
  }

  /// زمان سپری شده از شروع.
  Duration get elapsed => DateTime.now().difference(startedAt);

  /// شروع یک تلاش جدید.
  ///
  /// ⚠️ تغییر: اگه به maxAttempts رسیده باشیم، دیگه افزایش نمی‌دیم
  /// (ولی protocol/masque آپدیت می‌شن).
  void beginAttempt({
    required String protocol,
    required String masque,
  }) {
    if (currentAttempt < maxAttempts) {
      currentAttempt++;
    }
    currentProtocol = protocol;
    currentMasque = masque;
  }

  /// علامت‌گذاری cancel.
  void requestCancel() {
    cancelRequested = true;
  }

  /// ثبت خطا.
  void recordError(String error) {
    lastError = error;
  }

  /// ریست کامل.
  void reset() {
    currentAttempt = 0;
    cancelRequested = false;
    lastError = null;
  }

  @override
  String toString() => 'RetryState(attempt=$currentAttempt/$maxAttempts, '
      'protocol=$currentProtocol, masque=$currentMasque, '
      'cancel=$cancelRequested)';
}
