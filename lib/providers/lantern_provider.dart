// lib/providers/lantern_provider.dart
//
// وضعیت queryهای CLI لنترن برای بخش ابزارهای تنظیمات:
//   • لیست سرورها (`lantern servers --json`) — کش‌شده روی دیسک
//   • اجرای دستورات جانبی (auth) با نمایش خروجی

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/settings_model.dart';
import '../services/data_paths/data_dir_resolver.dart';
import '../services/lantern/lantern_cli_service.dart';
import '../services/process_service.dart';

class LanternProvider extends ChangeNotifier {
  LanternProvider({required ProcessService processService})
      : _processService = processService {
    _loadCachedServers();
  }

  final ProcessService _processService;

  LanternCliService cliFor(AppSettings settings) => LanternCliService(
        settings: settings,
        processService: _processService,
      );

  void _log(String message) {
    _processService.addLog(message, source: LogSource.lantern);
  }

  // ─── لیست سرورها (کش‌شده) ───
  List<LanternServerInfo> servers = const [];
  bool isLoadingServers = false;
  bool serversLoaded = false;
  String? serversError;

  bool get hasServers => servers.isNotEmpty;

  Future<String> _cachePath() async {
    final dir = await DataDirResolver.getDataDir();
    return p.join(dir, 'lantern_servers.json');
  }

  /// لیست کش‌شدهٔ قبلی را از دیسک می‌خواند تا کومبوباکس بدون fetch هم پر باشد.
  Future<void> _loadCachedServers() async {
    try {
      final file = File(await _cachePath());
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return;
      final list = decoded
          .whereType<Map>()
          .map((m) =>
              LanternServerInfo.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      if (list.isNotEmpty) {
        servers = list;
        serversLoaded = true;
        _log('★ Loaded ${list.length} Lantern servers from cache');
        notifyListeners();
      }
    } catch (e) {
      _log('⚠ Could not read the cached Lantern server list: $e');
    }
  }

  Future<void> _saveCachedServers() async {
    try {
      final file = File(await _cachePath());
      await file.writeAsString(
        jsonEncode(servers.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      _log('⚠ Could not cache the Lantern server list: $e');
    }
  }

  Future<void> loadServers(
    AppSettings settings, {
    bool refresh = false,
    bool check = false,
  }) async {
    if (isLoadingServers) return;
    isLoadingServers = true;
    serversError = null;
    notifyListeners();

    try {
      _log(refresh
          ? '→ Fetching Lantern servers (refresh)…'
          : '→ Loading Lantern server list…');
      final list = await cliFor(settings).fetchServers(
        refresh: refresh,
        check: check,
        timeout: const Duration(minutes: 5),
      );
      if (list == null) {
        serversError = 'command failed';
        _log('✗ Failed to load the Lantern server list — see the log above');
      } else {
        servers = list;
        serversLoaded = true;
        serversError = null;
        _log('★ Loaded ${list.length} Lantern servers');
        await _saveCachedServers();
      }
    } catch (e) {
      serversError = '$e';
      _log('✗ Failed to load the Lantern server list: $e');
    } finally {
      isLoadingServers = false;
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
  Future<LanternCommandResult?> runCommand(
    AppSettings settings,
    List<String> args, {
    required String label,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    if (isRunningCommand) {
      _log('→ Lantern: "$label" ignored — another command is running');
      return null;
    }

    isRunningCommand = true;
    runningLabel = label;
    lastCommandLabel = label;
    lastOutput = '';
    notifyListeners();

    try {
      final result = await cliFor(settings).run(args, timeout: timeout);
      lastOutput = result.output;
      if (result.ok) {
        _log('★ Lantern "$label" finished successfully');
      } else if (result.timedOut) {
        _log('⚠ Lantern "$label" timed out');
      } else if (result.binaryError != null) {
        _log('✗ Lantern "$label" could not run: ${result.binaryError}');
      } else {
        _log('⚠ Lantern "$label" exited with code ${result.exitCode}');
      }
      return result;
    } catch (e) {
      lastOutput = '$e';
      _log('✗ Lantern "$label" failed: $e');
      return null;
    } finally {
      isRunningCommand = false;
      runningLabel = '';
      notifyListeners();
    }
  }
}
