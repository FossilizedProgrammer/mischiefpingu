// lib/providers/geph_provider.dart
//
// وضعیت queryهای CLI گف برای بخش ابزارهای تنظیمات:
//   • لیست کشورها (`geph5-proxy countries`) — کش‌شده روی دیسک
//   • اجرای دستورات جانبی (signup / login) با نمایش خروجی

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/settings_model.dart';
import '../services/data_paths/data_dir_resolver.dart';
import '../services/geph/geph_cli_service.dart';
import '../services/process_service.dart';

class GephProvider extends ChangeNotifier {
  GephProvider({required ProcessService processService})
      : _processService = processService {
    _loadCachedCountries();
  }

  final ProcessService _processService;

  GephCliService cliFor(AppSettings settings) => GephCliService(
        settings: settings,
        processService: _processService,
      );

  void _log(String message) {
    _processService.addLog(message, source: LogSource.geph);
  }

  // ─── لیست کشورها (کش‌شده) ───
  List<GephCountryInfo> countries = const [];
  bool isLoadingCountries = false;
  bool countriesLoaded = false;
  String? countriesError;

  bool get hasCountries => countries.isNotEmpty;

  Future<String> _cachePath() async {
    final dir = await DataDirResolver.getDataDir();
    return p.join(dir, 'geph_countries.json');
  }

  /// لیست کش‌شدهٔ قبلی را از دیسک می‌خواند تا کومبوباکس بدون fetch هم پر باشد.
  Future<void> _loadCachedCountries() async {
    try {
      final file = File(await _cachePath());
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return;
      final list = decoded
          .whereType<Map>()
          .map((m) =>
              GephCountryInfo.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      if (list.isNotEmpty) {
        countries = list;
        countriesLoaded = true;
        _log('★ Loaded ${list.length} Geph exit countries from cache');
        notifyListeners();
      }
    } catch (e) {
      _log('⚠ Could not read the cached Geph country list: $e');
    }
  }

  Future<void> _saveCachedCountries() async {
    try {
      final file = File(await _cachePath());
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(countries.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      _log('⚠ Could not cache the Geph country list: $e');
    }
  }

  Future<void> loadCountries(
    AppSettings settings, {
    String level = 'all',
  }) async {
    if (isLoadingCountries) return;
    isLoadingCountries = true;
    countriesError = null;
    notifyListeners();

    try {
      _log('→ Fetching the list of Geph exit countries…');
      final list = await cliFor(settings).fetchCountries(level: level);
      if (list == null) {
        countriesError = 'command failed';
        _log('✗ Failed to load the Geph country list — see the log above');
      } else {
        countries = list;
        countriesLoaded = true;
        countriesError = null;
        _log('★ Loaded ${list.length} Geph exit countries');
        await _saveCachedCountries();
      }
    } catch (e) {
      countriesError = '$e';
      _log('✗ Failed to load the Geph country list: $e');
    } finally {
      isLoadingCountries = false;
      notifyListeners();
    }
  }

  // ─── دستورات یک‌بارمصرف ───
  bool isRunningCommand = false;
  String runningLabel = '';
  String lastOutput = '';
  String lastCommandLabel = '';

  /// یک دستور جانبی را اجرا می‌کند؛ خروجی در [lastOutput] می‌ماند و کل
  /// جریان به پنل لاگ فرستاده می‌شود.
  Future<GephCommandResult?> runCommand(
    AppSettings settings,
    Future<List<String>> argsFuture, {
    required String label,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    if (isRunningCommand) {
      _log('→ Geph: "$label" ignored — another command is running');
      return null;
    }

    isRunningCommand = true;
    runningLabel = label;
    lastCommandLabel = label;
    lastOutput = '';
    notifyListeners();

    try {
      final result =
          await cliFor(settings).run(await argsFuture, timeout: timeout);
      lastOutput = result.output;
      if (result.ok) {
        _log('★ Geph "$label" finished successfully');
      } else if (result.timedOut) {
        _log('⚠ Geph "$label" timed out');
      } else if (result.binaryError != null) {
        _log('✗ Geph "$label" could not run: ${result.binaryError}');
      } else {
        _log('⚠ Geph "$label" exited with code ${result.exitCode}');
      }
      return result;
    } catch (e) {
      lastOutput = '$e';
      _log('✗ Geph "$label" failed: $e');
      return null;
    } finally {
      isRunningCommand = false;
      runningLabel = '';
      notifyListeners();
    }
  }
}
