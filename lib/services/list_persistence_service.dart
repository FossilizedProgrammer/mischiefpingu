// lib/services/list_persistence_service.dart
//
// ═══════════════════════════════════════════════════════════════
//  ListPersistenceService — ذخیره/بارگذاری لیست‌های IP/HTTP/SNI
//  (تفکیک شده از settings_persistence_service.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'package:shared_preferences/shared_preferences.dart';

class ListPersistenceService {
  static const String _keyIpList = 'ipList';
  static const String _keyHttpHostList = 'httpHostList';
  static const String _keyTlsSniList = 'tlsSniList';

  Future<List<String>> loadIpList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyIpList) ?? fallback;
  }

  Future<void> saveIpList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyIpList, list);
  }

  Future<List<String>> loadHttpHostList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyHttpHostList) ?? fallback;
  }

  Future<void> saveHttpHostList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHttpHostList, list);
  }

  Future<List<String>> loadTlsSniList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyTlsSniList) ?? fallback;
  }

  Future<void> saveTlsSniList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyTlsSniList, list);
  }
}
