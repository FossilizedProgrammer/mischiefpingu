import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

/// لایهٔ دسترسی به SharedPreferences برای ذخیره/بارگذاری تنظیمات و لیست‌ها.
/// هیچ منطق اعتبارسنجی ندارد — فقط خواندن و نوشتن خام.
class SettingsPersistenceService {
  // ─── Settings ───

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('settings');
    if (jsonStr != null) {
      try {
        return AppSettings.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(settings.toJson()));
  }

  // ─── Logging ───

  Future<bool> loadLoggingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggingEnabled') ?? true;
  }

  Future<void> saveLoggingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggingEnabled', value);
  }

  // ─── IP List ───

  Future<List<String>> loadIpList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('ipList') ?? fallback;
  }

  Future<void> saveIpList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ipList', list);
  }

  // ─── HTTP Host List ───

  Future<List<String>> loadHttpHostList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('httpHostList') ?? fallback;
  }

  Future<void> saveHttpHostList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('httpHostList', list);
  }

  // ─── TLS SNI List ───

  Future<List<String>> loadTlsSniList(List<String> fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('tlsSniList') ?? fallback;
  }

  Future<void> saveTlsSniList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tlsSniList', list);
  }
}
