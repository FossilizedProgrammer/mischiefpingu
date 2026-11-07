library;

import 'dart:convert';

/// ═══════════════════════════════════════════════════════════════
///  NpvServerList — خروجی `npv list -json`.
///
///  باینری npv همهٔ کانفیگ‌های فایل را با همین ترتیب می‌دهد:
///  زنده‌ها اول و سریع‌ترین به قبل (median واقعی هر کانفیگ)، بعد
///  مرده‌ها با دلیل خطا. پس لیست برای نمایش دوباره sort نمی‌شود.
/// ═══════════════════════════════════════════════════════════════
class NpvServerEntry {
  final int index;
  final String remark;
  final String proto;
  final String kind;
  final String transport;
  final bool ok;
  final int medianMs;
  final String error;

  const NpvServerEntry({
    required this.index,
    required this.remark,
    required this.proto,
    required this.kind,
    required this.transport,
    required this.ok,
    required this.medianMs,
    required this.error,
  });

  factory NpvServerEntry.fromJson(Map<String, dynamic> json) =>
      NpvServerEntry(
        index: (json['index'] as num?)?.toInt() ?? 0,
        remark: json['remark'] as String? ?? '',
        proto: json['proto'] as String? ?? '',
        kind: json['kind'] as String? ?? '',
        transport: json['transport'] as String? ?? '',
        ok: json['ok'] == true,
        medianMs: (json['medianMs'] as num?)?.toInt() ?? 0,
        error: json['error'] as String? ?? '',
      );
}

class NpvServerList {
  final String creatorMessage;
  final bool checked;
  final int total;
  final int answered;
  final List<NpvServerEntry> servers;

  const NpvServerList({
    required this.creatorMessage,
    required this.checked,
    required this.total,
    required this.answered,
    required this.servers,
  });

  bool get hasServers => servers.isNotEmpty;

  /// فقط ردیف‌های زنده، همان ترتیب باینری (سریع‌ترین به قبل).
  List<NpvServerEntry> get alive => servers.where((s) => s.ok).toList();

  /// شمارهٔ رتبه برای ردیف‌های زنده؛ مرده‌ها رتبه ندارند.
  int rankOf(NpvServerEntry entry) {
    if (!entry.ok) return 0;
    final rank = alive.indexWhere((s) => s.index == entry.index);
    return rank < 0 ? 0 : rank + 1;
  }

  /// خروجی بدشکل یا نسخهٔ قدیمی باینری که `-json` را نمی‌شناسد نباید
  /// برنامه را بشکند؛ در این حالت null می‌دهیم و پیام به کاربر می‌رسد.
  static NpvServerList? tryParse(String source) {
    try {
      final raw = jsonDecode(source);
      if (raw is! Map<String, dynamic>) return null;
      final items = raw['servers'];
      return NpvServerList(
        creatorMessage: raw['creatorMessage'] as String? ?? '',
        checked: raw['checked'] == true,
        total: (raw['total'] as num?)?.toInt() ?? 0,
        answered: (raw['answered'] as num?)?.toInt() ?? 0,
        servers: items is List
            ? items
                  .whereType<Map<String, dynamic>>()
                  .map(NpvServerEntry.fromJson)
                  .toList()
            : const [],
      );
    } catch (_) {
      return null;
    }
  }
}
