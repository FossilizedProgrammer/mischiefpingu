// lib/services/aether/test_executor/executor_masque_helper.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  Helperهای MASQUE + برچسب‌گذاری.
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorMasqueHelper on AetherTestExecutor {
  /// محاسبه MASQUE option مؤثر برای یک attempt.
  String _effectiveMasqueForAttempt(EndpointAttempt attempt, int index) {
    // ─── custom endpoint: masque رو از خود attempt بگیر ───
    if (attempt.isCustomEndpoint && attempt.masque.isNotEmpty) {
      return attempt.masque;
    }

    // ─── فقط masque و mim از جابه‌جایی H2/H3 پشتیبانی می‌کنن ───
    if (attempt.protocol != 'masque' && attempt.protocol != 'mim') {
      return attempt.masque;
    }

    if (attempt.masque.isEmpty) {
      return attempt.masque;
    }

    // ═══════════════════════════════════════════════════════════
    //  H2/H3 swap در automatic، manual، و custom-first
    // ═══════════════════════════════════════════════════════════
    final shouldSwap = settings.isAetherProfileAutomatic ||
        settings.aetherProfile == 'manual' ||
        settings.isEndpointPinningCustomFirst;

    if (shouldSwap) {
      return AetherRetryStrategy.masqueForAttempt(
        preferredMasque: attempt.masque,
        attemptIndex: index + 1,
      );
    }

    return attempt.masque;
  }

  /// ساخت برچسب protocol/masque برای notification.
  String _protocolLabelWithMasque(String protocol, String masque) {
    if (masque.isEmpty) return protocol;
    return '$protocol/$masque';
  }
}
