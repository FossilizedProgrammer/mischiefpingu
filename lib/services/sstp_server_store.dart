library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'vpngate_scraper_service.dart';

class SstpServerStore {
  static const String _key = 'sstpServers';

  Future<List<SstpServer>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SstpServer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// ادغام سرورهای جدید با قبلی، بدون تکرار (بر اساس ip:port).
  /// برمی‌گرداند: (همه سرورها، تعداد جدید)
  Future<({List<SstpServer> all, int added})> merge(
    List<SstpServer> incoming,
  ) async {
    final existing = await load();
    final seen = existing.map((e) => e.key).toSet();
    var added = 0;
    final merged = List<SstpServer>.from(existing);
    for (final s in incoming) {
      if (seen.add(s.key)) {
        merged.add(s);
        added++;
      }
    }
    if (added > 0) {
      await _save(merged);
    }
    return (all: merged, added: added);
  }

  Future<void> _save(List<SstpServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(servers.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
