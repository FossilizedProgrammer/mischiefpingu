// ═══════════════════════════════════════════════════════════════
//  AetherProtocolCard — shell / re-export
//
//  این فایل حالا فقط یک shell هست. کد اصلی به
//  `aether/aether_protocol_card.dart` منتقل شده تا:
//    • فایل اصلی کوتاه‌تر و قابل‌خون‌تر بشه
//    • همه کامپوننت‌های Aether در یک پوشه (`aether/`) متمرکز بشن
//    • importهای موجود در سراسر پروژه بدون تغییر کار کنن
//
//  ⚠️ اگه می‌خوای این فایل رو حذف کنی، همه importهای
//  `aether_protocol_card.dart` رو باید به
//  `aether/aether_protocol_card.dart` تغییر بدی.
// ═══════════════════════════════════════════════════════════════

export 'aether/aether_protocol_card.dart' show AetherProtocolCard;
