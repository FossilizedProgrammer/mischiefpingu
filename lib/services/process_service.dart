// lib/services/process_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'app_data_service.dart';
import 'log_line_parsers.dart';
import 'port_manager.dart';
import 'process/log_source.dart';
import 'process/process_notifications.dart';
import 'process/process_forwarder.dart';

// ─── Re-export ───
export 'process/log_source.dart' show LogSource;

// ─── helpers ───
part 'process_service_helpers.dart';
part 'process_service_aether_lan.dart';

// ─── Psiphon ───
part 'psiphon_launcher.dart';
part 'psiphon_stopper.dart';
part 'process_service_psiphon.dart';

// ─── Aether ───
part 'aether_starter.dart';
part 'aether_stopper.dart';

// ─── Tor ───
part 'tor_launcher.dart';
part 'tor_stopper.dart';
part 'process_service_tor.dart';

// ─── SSTP ───
part 'sstp_launcher.dart';
part 'sstp_stopper.dart';
part 'process_service_sstp.dart';

class ProcessService extends ChangeNotifier with ProcessNotifications {
  // ═══════════════════════════════════════════════════════════════
  //  Process fields
  // ═══════════════════════════════════════════════════════════════
  Process? psiphonProcess;
  Process? aetherProcess;
  Process? torProcess;
  Process? sstpProcess;

  // ─── Forwarders ───
  ServerSocket? psiphonSocksForwarder;
  ServerSocket? psiphonHttpForwarder;
  ServerSocket? torSocksForwarder;
  ServerSocket? torHttpForwarder;

  final List<String> _logs = [];
  bool _initialized = false;
  bool _loggingEnabled = true;

  late final ProcessForwarder forwarder = ProcessForwarder(
    addLog: (message, {source = LogSource.empty}) =>
        addLog(message, source: source),
  );

  // ═══════════════════════════════════════════
  //  Override — برای notifyListeners
  // ═══════════════════════════════════════════
  @override
  void setPortConflictMessage(String message) {
    super.setPortConflictMessage(message);
    notifyListeners();
  }

  @override
  void setBinaryMissingMessage(String message) {
    super.setBinaryMissingMessage(message);
    notifyListeners();
  }

  // ─── PID getters ───
  int? get aetherPid => aetherProcess?.pid;
  int? get psiphonPid => psiphonProcess?.pid;
  int? get torPid => torProcess?.pid;
  int? get sstpPid => sstpProcess?.pid;

  // ─── Lifecycle ───
  void touch() => notifyListeners();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await AppDataService.initializeDataFiles();
    for (final msg in AppDataService.initLogs) {
      addLog(msg, source: LogSource.system);
    }
    _initialized = true;
  }

  // ─── Logging ───
  List<String> get fullLog => List.unmodifiable(_logs);

  void addLog(String message, {String source = LogSource.empty}) {
    if (!_loggingEnabled) return;
    final time = DateTime.now().toString().substring(11, 19);
    final tag = source.isNotEmpty ? '[$source] ' : '';
    _logs.add('$time $tag$message');
    if (_logs.length > 1000) _logs.removeAt(0);
    notifyListeners();
  }

  bool get loggingEnabled => _loggingEnabled;
  set loggingEnabled(bool v) {
    _loggingEnabled = v;
    notifyListeners();
  }

  void clearLog() {
    _logs.clear();
    notifyListeners();
  }

  // ─── Port check (static) ───
  static Future<bool> isPortInUse(int port) async {
    return PortManager.isInUse(port);
  }

  Future<int> findFreePort() => PortManager.findFree(preferred: const []);

  // ─── LAN forwarders (delegating) ───
  Future<void> startDartLanForwarders({
    required int publicSocksPort,
    required int publicHttpPort,
    required int internalSocksPort,
    required int internalHttpPort,
    required String source,
  }) =>
      forwarder.startDartLanForwarders(
        publicSocksPort: publicSocksPort,
        publicHttpPort: publicHttpPort,
        internalSocksPort: internalSocksPort,
        internalHttpPort: internalHttpPort,
        source: source,
        onReady: (socks, http) {
          psiphonSocksForwarder = socks;
          psiphonHttpForwarder = http;
        },
      );

  Future<ServerSocket?> createForwarder({
    required int publicPort,
    required int internalPort,
    required String label,
    required String source,
  }) =>
      forwarder.createForwarder(
        publicPort: publicPort,
        internalPort: internalPort,
        label: label,
        source: source,
      );
}
