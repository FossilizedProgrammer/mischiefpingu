part of '../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  ثبت موفقیت، شکست، عملکرد و رویدادهای session.
///
///  این فایل فقط shell است — منطق در:
///    • success_failure.dart     → recordSuccess + recordFailure
///    • performance_session.dart → recordPerformance + recordSessionEnd
///                                 + recordReconnectEvent
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStoreRecord on GatewayHistoryStore {
  // متدها در فایل‌های جداگانه — این extension فقط برای
  // سازگاری با کد قبلی است. متدهای واقعی در دو فایل part شده
  // تعریف می‌شوند.
}
