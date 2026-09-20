import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/settings_model.dart';
import '../services/process_service.dart';
import '../services/privilege_service.dart';
import '../services/app_data_service.dart';
import '../services/aether_auto_test_service.dart';
import '../services/aether/gateway_reconnect_orchestrator.dart';
import '../services/aether_logger.dart';
import '../services/psiphon_config_builder.dart';
import '../services/tor_config_builder.dart';
import '../services/sstp_config_builder.dart';
import '../services/settings_persistence_service.dart';
import '../services/auto_reconnect_manager.dart';
import '../services/core_update_service.dart';
import '../services/log_line_parsers.dart';
import '../services/port_manager.dart';
import '../services/tunnel_watchdog_manager.dart';
import '../services/tunnel_watchdog_factory.dart';
import '../services/psiphon/psiphon_log_watcher.dart';
import '../services/tor/tor_log_watcher.dart';
import '../services/sstp/sstp_log_watcher.dart';
import '../services/recovery/recovery_coordinator.dart';
import '../services/diagnostics/connectivity_probe.dart';
import '../services/watchdog/tunnel_watchdog.dart';
import '../services/database/database_initializer.dart';
import '../services/database/gateway_database.dart';
import '../services/database/gateway_history_store.dart';
import '../services/database/aether_event_store.dart';
import '../services/database/profile_performance_store.dart';
import '../services/aether/decision/aether_decision_engine.dart';
import '../services/aether/decision/ranked_candidate.dart';
import '../services/aether/connection_health.dart';
import '../services/aether/connection_health_monitor.dart';
import '../services/aether/quality_degradation_detector.dart';
import '../services/aether/quality_statistics_service.dart';
import '../services/health/tunnel_health_models.dart';
import '../services/health/tunnel_health_registry.dart';
import '../constants/default_lists.dart';
import 'internet_quality_provider.dart';

part 'app_provider_snapshot.dart';
part 'sstp/sstp_launch.dart';
part 'sstp/sstp_preflight.dart';
part 'tor/tor_launch.dart';
part 'app_provider_lifecycle.dart';
part 'app_provider_lifecycle_persistence.dart';
part 'app_provider_parsers.dart';
part 'app_provider_psiphon.dart';
part 'app_provider_psiphon_preflight.dart';
part 'aether/aether_smart_reconnect.dart';
part 'psiphon/psiphon_launch.dart';
part 'app_provider_aether.dart';
part 'app_provider_aether_internal.dart';
part 'app_provider_aether_preflight.dart';
part 'app_provider_tor.dart';
part 'app_provider_tor_assets.dart';
part 'app_provider_tor_upstream.dart';
part 'app_provider_tor_preflight.dart';
part 'app_provider_sstp.dart';
part 'app_provider_sstp_upstream.dart';
part 'app_provider_watchdogs.dart';
part 'app_provider_reconnect.dart';
part 'app_provider_log_watchers.dart';
part 'app_provider_process_listener.dart';
part 'app_provider_wrappers.dart';

class AppProvider extends ChangeNotifier {
  final ProcessService processService = ProcessService();
  late final AetherAutoTestService _aetherTestService;
  AetherAutoTestService get aetherTestService => _aetherTestService;

  final SettingsPersistenceService persistence = SettingsPersistenceService();
  final AutoReconnectManager _reconnectManager = AutoReconnectManager();
  AutoReconnectManager get reconnectManager => _reconnectManager;

  /// ═══════════════════════════════════════════════════════════════
  ///  RecoveryCoordinator — جلوگیری از restart همزمان
  /// ═══════════════════════════════════════════════════════════════
  late final RecoveryCoordinator _recoveryCoordinator;
  RecoveryCoordinator get recoveryCoordinator => _recoveryCoordinator;

  /// ═══════════════════════════════════════════════════════════════
  ///  ConnectivityProbe — تشخیص سریع Internet vs Tunnel
  /// ═══════════════════════════════════════════════════════════════
  late final ConnectivityProbe _connectivityProbe;
  ConnectivityProbe get connectivityProbe => _connectivityProbe;

  /// ═══════════════════════════════════════════════════════════════
  ///  GatewayHistoryStore — تاریخچه Gatewayها (فاز ۱)
  /// ═══════════════════════════════════════════════════════════════
  late final GatewayHistoryStore _gatewayHistoryStore;
  GatewayHistoryStore get gatewayHistoryStore => _gatewayHistoryStore;

  /// ═══════════════════════════════════════════════════════════════
  ///  AetherEventStore — Structured Logging (فاز v2)
  /// ═══════════════════════════════════════════════════════════════
  late final AetherEventStore _aetherEventStore;
  AetherEventStore get aetherEventStore => _aetherEventStore;

  /// ═══════════════════════════════════════════════════════════════
  ///  AetherLogger — Logger مرکزی برای رویدادهای Aether
  /// ═══════════════════════════════════════════════════════════════
  late final AetherLogger _aetherLogger;
  AetherLogger get aetherLogger => _aetherLogger;

  /// ═══════════════════════════════════════════════════════════════
  ///  ProfilePerformanceStore — Smart Cache (فاز v3)
  /// ═══════════════════════════════════════════════════════════════
  late final ProfilePerformanceStore _profilePerformanceStore;
  ProfilePerformanceStore get profilePerformanceStore =>
      _profilePerformanceStore;

  /// ═══════════════════════════════════════════════════════════════
  ///  فاز v4: DecisionEngine — لایهٔ مرکزی تصمیم‌گیری
  /// ═══════════════════════════════════════════════════════════════
  late final AetherDecisionEngine _decisionEngine;
  AetherDecisionEngine get decisionEngine => _decisionEngine;

  /// ═══════════════════════════════════════════════════════════════
  ///  فاز v4: ConnectionHealthMonitor — Health Score زنده
  /// ═══════════════════════════════════════════════════════════════
  late final ConnectionHealthMonitor _healthMonitor;
  ConnectionHealth? _currentHealth;
  ConnectionHealth? get currentHealth => _currentHealth;

  /// ═══════════════════════════════════════════════════════════════
  ///  فاز v4: QualityDegradationDetector — تشخیص افت کیفیت + escalation
  /// ═══════════════════════════════════════════════════════════════
  late final QualityDegradationDetector _degradationDetector;

  /// ═══════════════════════════════════════════════════════════════
  ///  فاز v4: QualityStatisticsService — گزارش آماری
  /// ═══════════════════════════════════════════════════════════════
  late final QualityStatisticsService _statsService;
  QualityStatisticsService get statsService => _statsService;

  /// ═══════════════════════════════════════════════════════════════
  ///  TunnelHealthRegistry — health مشترک بین همهٔ تونل‌ها.
  ///
  ///  این registry:
  ///    • monitor اختصاصی هر تونل رو نگه می‌داره
  ///    • adapterهای لاگ رو مدیریت می‌کنه
  ///    • degradation رو تشخیص می‌ده و callback می‌زنه
  ///
  ///  ⚠️ Aether از این registry استفاده نمی‌کنه چون:
  ///    • monitor اختصاصی خودش (ConnectionHealthMonitor) رو داره
  ///    • escalation logic خودش رو داره
  ///
  ///  برای بقیهٔ تونل‌ها (Psiphon/Tor/SSTP) این registry
  ///  تنها منبع health است.
  /// ═══════════════════════════════════════════════════════════════
  late final TunnelHealthRegistry _healthRegistry;
  TunnelHealthRegistry get healthRegistry => _healthRegistry;

  /// کاندید فعال فعلی (برای ثبت session end).
  RankedCandidate? _currentActiveCandidate;
  RankedCandidate? get currentActiveCandidate => _currentActiveCandidate;

  /// Timer برای poll کردن lastReport و ingest در healthMonitor.
  Timer? _healthPollTimer;

  /// ═══════════════════════════════════════════════════════════════
  ///  GatewayReconnectOrchestrator — reconnect هوشمند (فاز ۴)
  /// ═══════════════════════════════════════════════════════════════
  GatewayReconnectOrchestrator? _gatewayReconnectOrchestrator;
  GatewayReconnectOrchestrator? get gatewayReconnectOrchestrator =>
      _gatewayReconnectOrchestrator;

  /// ═══════════════════════════════════════════════════════════════
  ///  InternetQualityProvider — کیفیت کامل اینترنت (اختیاری)
  /// ═══════════════════════════════════════════════════════════════
  InternetQualityProvider? _qualityProvider;
  InternetQualityProvider? get qualityProvider => _qualityProvider;

  /// تزریق provider کیفیت از main.dart.
  void attachQualityProvider(InternetQualityProvider provider) {
    _qualityProvider = provider;
    processService.addLog(
      '→ AppProvider: InternetQualityProvider attached '
      '(watchdog will use full quality diagnostics)',
      source: LogSource.app,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  Generation counters — جلوگیری از race condition در callbackها
  /// ═══════════════════════════════════════════════════════════════
  int _psiphonGeneration = 0;
  int _aetherGeneration = 0;
  int _torGeneration = 0;
  int _sstpGeneration = 0;

  int get psiphonGeneration => _psiphonGeneration;
  int get aetherGeneration => _aetherGeneration;
  int get torGeneration => _torGeneration;
  int get sstpGeneration => _sstpGeneration;

  int nextPsiphonGeneration() => ++_psiphonGeneration;
  int nextAetherGeneration() => ++_aetherGeneration;
  int nextTorGeneration() => ++_torGeneration;
  int nextSstpGeneration() => ++_sstpGeneration;

  TunnelWatchdogManager? _watchdogManager;
  TunnelWatchdogManager? get watchdogManager => _watchdogManager;

  late final PsiphonLogWatcher _psiphonLog;
  late final TorLogWatcher _torLog;
  late final SstpLogWatcher _sstpLog;

  PsiphonLogWatcher get psiphonLog => _psiphonLog;
  TorLogWatcher get torLog => _torLog;
  SstpLogWatcher get sstpLog => _sstpLog;

  StreamSubscription<String>? _logSubscription;
  StreamSubscription<String>? get logSubscription => _logSubscription;

  _TunnelStateSnapshot? _lastTunnelState;

  AppSettings settings = AppSettings();
  List<String> ipList = List.from(DefaultLists.ipList);
  List<String> httpHostList = List.from(DefaultLists.httpHostList);
  List<String> tlsSniList = List.from(DefaultLists.tlsSniList);

  bool isLoading = false;
  bool isPsiphonBusy = false;
  bool isTorBusy = false;
  bool isSstpBusy = false;
  bool loggingEnabled = true;
  String aetherStatus = 'Aether: Ready';
  String torStatus = 'Tor: Ready';
  String sstpStatus = 'SSTP: Ready';
  bool isElevated = false;

  bool isAutoTesting = false;

  bool userStoppedPsiphon = true;
  bool userStoppedAether = true;
  bool userStoppedTor = true;
  bool userStoppedSstp = true;

  bool isShuttingDown = false;

  bool restartingPsiphon = false;
  bool restartingAether = false;
  bool restartingTor = false;
  bool restartingSstp = false;

  // ═══════════════════════════════════════════════════════════════
  //  Aether session state (فاز ۶) — برای UI status card
  // ═══════════════════════════════════════════════════════════════

  /// آخرین پروتکل موفقی که Aether به آن وصل شد.
  String? lastAetherConnectedProtocol;

  /// آخرین Gateway موفقی که Aether به آن وصل شد (uniqueKey).
  String? lastAetherConnectedGatewayKey;

  /// زمان آخرین اتصال موفق Aether.
  DateTime? lastAetherConnectedAt;

  /// تعداد reconnectهای Aether در این session.
  int aetherReconnectCount = 0;

  /// ═══════════════════════════════════════════════════════════════
  ///  ⚠️ auto-escalation state
  ///
  ///  وقتی تونل زنده‌ست ولی داده عبور نمی‌کنه، profile رو
  ///  خودکار escalate می‌کنیم. این flag جلوگیری می‌کنه از
  ///  escalation پشت سر هم در یک session.
  /// ═══════════════════════════════════════════════════════════════
  bool _escalationInProgress = false;

  String cleanIp(String ip) => ip.replaceAll(r'\', '').trim();
  List<String> cleanIpList(List<String> list) =>
      list.map(cleanIp).where((e) => e.isNotEmpty).toSet().toList();

  AppProvider() {
    processService.ensureInitialized();
    processService.addListener(handleProcessServiceChange);

    _psiphonLog = PsiphonLogWatcher(log: processService.addLog);
    _torLog = TorLogWatcher(log: processService.addLog);
    _sstpLog = SstpLogWatcher(log: processService.addLog);

    _logSubscription = processService.logStream.listen(
      feedLogWatchers,
      onError: (e) {
        processService.addLog('⚠ logStream error: $e', source: LogSource.app);
      },
    );

    _recoveryCoordinator = RecoveryCoordinator(log: processService.addLog);
    _connectivityProbe = ConnectivityProbe(log: processService.addLog);

    // ─── Gateway History Store (فاز ۱) ───
    _gatewayHistoryStore = GatewayHistoryStore(
      log: (msg, {source = LogSource.empty}) =>
          processService.addLog(msg, source: source),
    );

    // ─── Structured Logging (فاز v2) ───
    _aetherEventStore = AetherEventStore(log: processService.addLog);
    _aetherLogger = AetherLogger(
      store: _aetherEventStore,
      log: processService.addLog,
    );

    // ─── Smart Cache (فاز v3) ───
    _profilePerformanceStore = ProfilePerformanceStore(
      log: processService.addLog,
    );

    _aetherTestService = AetherAutoTestService(
      processService: processService,
      settings: settings,
    );

    // ═══════════════════════════════════════════════════════════════
    //  فاز v4: DecisionEngine — باید قبل از attachAllStores ساخته شود
    // ═══════════════════════════════════════════════════════════════
    _decisionEngine = AetherDecisionEngine(
      settings: settings,
      historyStore: _gatewayHistoryStore,
      profileStore: _profilePerformanceStore,
      logger: _aetherLogger,
      log: processService.addLog,
    );

    // ─── تزریق همهٔ Storeها با یک rebuild واحد ───
    _aetherTestService.attachAllStores(
      historyStore: _gatewayHistoryStore,
      profileStore: _profilePerformanceStore,
      logger: _aetherLogger,
      decisionEngine: _decisionEngine,
    );

    // ═══════════════════════════════════════════════════════════════
    //  فاز v4: HealthMonitor + DegradationDetector + Stats
    // ═══════════════════════════════════════════════════════════════
    _healthMonitor = ConnectionHealthMonitor(
      onUpdate: (h) {
        _currentHealth = h;
        if (!isShuttingDown) touch();
      },
      log: processService.addLog,
    );

    // ═══════════════════════════════════════════════════════════════
    //  ⚠️ تغییرات در DegradationDetector:
    //    • onEscalateProfile اضافه شد
    //    • وقتی packet loss 100% هست، به جای restart کردن،
    //      profile رو به profile سخت‌گیرتر escalate می‌کنه
    // ═══════════════════════════════════════════════════════════════
    _degradationDetector = QualityDegradationDetector(
      onDegradationDetected: (reason) {
        if (userStoppedAether || isShuttingDown) return;
        processService.addLog(
          '↻ Preemptive Aether restart triggered: $reason',
          source: LogSource.aether,
        );
        // fire-and-forget
        // ignore: discarded_futures
        restartAetherInternal(reason: 'quality degradation: $reason');
      },
      onEscalateProfile: (reason) {
        if (userStoppedAether || isShuttingDown) return;
        if (_escalationInProgress) {
          processService.addLog(
            '→ Escalation skipped (already in progress)',
            source: LogSource.aether,
          );
          return;
        }

        final current = settings.aetherProfile;
        final next = _nextProfile(current);

        if (next == null) {
          processService.addLog(
            '⚠ Cannot escalate profile: already at strict. '
            'Reason: $reason',
            source: LogSource.aether,
          );
          // آخرین راه‌حل: restart کن
          // ignore: discarded_futures
          restartAetherInternal(reason: 'no profile left: $reason');
          return;
        }

        _escalationInProgress = true;
        processService.addLog(
          '↻ Auto-escalating Aether profile: '
          '$current → $next (reason: $reason)',
          source: LogSource.aether,
        );

        settings.applyAetherProfile(next);
        saveSettings();

        // fire-and-forget
        // ignore: discarded_futures
        _performEscalationRestart(reason: reason);
      },
      log: processService.addLog,
    );

    _statsService = QualityStatisticsService(
      eventStore: _aetherEventStore,
      log: processService.addLog,
    );

    // ═══════════════════════════════════════════════════════════════
    //  TunnelHealthRegistry — health مشترک Psiphon/Tor/SSTP
    //
    //  این registry:
    //    • برای هر تونل یک monitor می‌سازه
    //    • لاگ‌ها رو به adapter اختصاصی هر تونل feed می‌کنه
    //    • degradation رو تشخیص می‌ده و restart می‌کنه
    //
    //  ⚠️ Aether در registry ثبت می‌شه ولی از monitor خودش
    //  استفاده می‌کنه. یعنی Aether report جداگانه نمی‌ده.
    // ═══════════════════════════════════════════════════════════════
    _healthRegistry = TunnelHealthRegistry(
      log: processService.addLog,
      onReport: (kind, report) {
        // Aether مسیر خودش رو داره (healthMonitor جدا)
        if (kind == TunnelKind.aether) return;
        if (isShuttingDown) return;
        touch();
      },
      onDegradationDetected: (kind, reason) {
        if (isShuttingDown) return;

        // Aether مسیر خودش رو داره (degradationDetector جدا)
        if (kind == TunnelKind.aether) return;

        // اگه کاربر دستی stop کرده، دخالت نکن
        switch (kind) {
          case TunnelKind.psiphon:
            if (userStoppedPsiphon) return;
            break;
          case TunnelKind.tor:
            if (userStoppedTor) return;
            break;
          case TunnelKind.sstp:
            if (userStoppedSstp) return;
            break;
          case TunnelKind.aether:
            return;
        }

        processService.addLog(
          '↻ ${kind.displayName} preemptive restart '
          'triggered: $reason',
          source: LogSource.app,
        );

        // fire-and-forget
        switch (kind) {
          case TunnelKind.psiphon:
            // ignore: discarded_futures
            restartPsiphonInternal(
              reason: 'health degradation: $reason',
            );
            break;
          case TunnelKind.tor:
            // ignore: discarded_futures
            restartTorInternal(
              reason: 'health degradation: $reason',
            );
            break;
          case TunnelKind.sstp:
            // ignore: discarded_futures
            restartSstpInternal(
              reason: 'health degradation: $reason',
            );
            break;
          case TunnelKind.aether:
            break;
        }
      },
      onEscalateProfile: (kind, reason) {
        // فقط Aether escalate داره — این callback عملاً
        // صدا زده نمی‌شه چون registry برای Aether escalate نمی‌کنه
        if (kind != TunnelKind.aether) return;
      },
    );
    _healthRegistry.initialize();

    // ─── Orquestrator برای reconnect هوشمند (فاز ۴ + v4) ───
    _gatewayReconnectOrchestrator = GatewayReconnectOrchestrator(
      processService: processService,
      historyStore: _gatewayHistoryStore,
      runner: _aetherTestService.internalRunner,
      performanceTracker: _aetherTestService.performanceTracker,
      decisionEngine: _decisionEngine,
    );

    _reconnectManager.acquireLease = (tunnel) async {
      final tunnelName = _tunnelDisplayName(tunnel);
      final lease = _recoveryCoordinator.tryAcquire(
        tunnel: tunnelName,
        action: RecoveryAction.autoReconnect,
        reason: 'process exited unexpectedly',
      );
      return lease != null;
    };

    _reconnectManager.releaseLease = (tunnel) {
      final tunnelName = _tunnelDisplayName(tunnel);
      _recoveryCoordinator.releaseLeaseByTunnel(tunnelName);
    };

    // ═══════════════════════════════════════════════════════════════
    //  فاز v4: Health poll timer
    // ═══════════════════════════════════════════════════════════════
    _startHealthPollTimer();

    Future.microtask(initializeProvider);
  }

  /// پروفایل بعدی در زنجیرهٔ escalation.
  ///
  /// ترتیب: adaptive → patchy → strict → null
  /// manual → null (به manual دست نمی‌زنیم)
  String? _nextProfile(String current) {
    switch (current) {
      case 'adaptive':
        return 'patchy';
      case 'patchy':
        return 'strict';
      case 'strict':
        return null;
      case 'manual':
        return null;
      default:
        return 'strict';
    }
  }

  /// اجرای restart پس از escalation.
  ///
  /// این متد تضمین می‌کنه که flag `_escalationInProgress` پس از
  /// اتمام restart ریست بشه، حتی اگه خطا رخ بده.
  Future<void> _performEscalationRestart({required String reason}) async {
    try {
      // چند لحظه صبر کن تا Aether فعلی کاملاً stop بشه
      await Future.delayed(const Duration(milliseconds: 500));

      if (userStoppedAether || isShuttingDown) {
        processService.addLog(
          '→ Escalation restart skipped (user stopped or shutting down)',
          source: LogSource.aether,
        );
        return;
      }

      await restartAetherInternal(reason: 'profile escalation: $reason');
    } catch (e) {
      processService.addLog(
        '⚠ Escalation restart failed: $e',
        source: LogSource.aether,
      );
    } finally {
      // cooldown کوتاه برای جلوگیری از escalation پشت سر هم
      await Future.delayed(const Duration(seconds: 30));
      _escalationInProgress = false;
    }
  }

  /// شروع timer poll برای Health.
  void _startHealthPollTimer() {
    _healthPollTimer?.cancel();
    _healthPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isShuttingDown) return;
      if (!processService.isAetherRunning) return;

      final tracker = _aetherTestService.performanceTracker;
      final report = tracker?.lastReport;
      if (report == null || !report.isValid) return;

      _healthMonitor.ingestReport(report);

      final health = _currentHealth;
      if (health != null && health.isValid) {
        _degradationDetector.ingest(health);
      }
    });
  }

  /// به‌روزرسانی کاندید فعال (توسط AetherAutoTestService).
  void setCurrentActiveCandidate(RankedCandidate? candidate) {
    _currentActiveCandidate = candidate;
  }

  /// پاک‌کردن کاندید فعال.
  void clearCurrentActiveCandidate() {
    _currentActiveCandidate = null;
  }

  /// گرفتن آمار 24 ساعت اخیر.
  Future<ProtocolStats> computeStats24h() => _statsService.computeLast24h();

  /// گرفتن آمار 7 روز اخیر.
  Future<ProtocolStats> computeStats7d() => _statsService.computeLast7d();

  // ═══════════════════════════════════════════════════════════════
  //  Health API — برای UI مشترک
  // ═══════════════════════════════════════════════════════════════

  /// گرفتن health report یک تونل به صورت یکپارچه.
  ///
  /// برای Aether: از ConnectionHealth داخلی نگاشت می‌شه.
  /// برای بقیه: از TunnelHealthRegistry گرفته می‌شه.
  TunnelHealthReport? healthReportFor(TunnelKind kind) {
    if (kind == TunnelKind.aether) {
      final h = _currentHealth;
      if (h == null || !h.isValid) return null;
      return TunnelHealthReport(
        kind: TunnelKind.aether,
        timestamp: DateTime.now(),
        score: h.score,
        latencyMs: h.latencyMs,
        jitterMs: h.jitterMs,
        packetLossPct: h.packetLossPct,
        uptime: h.uptime,
        reconnectCount: h.reconnectCount,
        errorCount: h.errorCount,
        trend: h.trend,
        successCount: 1,
        totalSamples: 1,
        extra: const {},
      );
    }
    return _healthRegistry.reportFor(kind);
  }

  /// گرفتن snapshot از همهٔ تونل‌ها.
  HealthSnapshot healthSnapshot() {
    final reports = <TunnelKind, TunnelHealthReport>{};

    // Aether
    final aetherReport = healthReportFor(TunnelKind.aether);
    if (aetherReport != null) {
      reports[TunnelKind.aether] = aetherReport;
    }

    // بقیه از registry
    for (final kind in [
      TunnelKind.psiphon,
      TunnelKind.tor,
      TunnelKind.sstp,
    ]) {
      final r = _healthRegistry.reportFor(kind);
      if (r != null) reports[kind] = r;
    }

    return HealthSnapshot(
      reports: reports,
      timestamp: DateTime.now(),
    );
  }

  /// ثبت reconnect برای یک تونل غیر-Aether.
  ///
  /// برای Psiphon/Tor/SSTP صدا زده می‌شه از restartXInternal.
  void recordTunnelReconnect(TunnelKind kind) {
    if (kind == TunnelKind.aether) return;
    _healthRegistry.recordReconnect(kind);
  }

  /// ثبت error برای یک تونل غیر-Aether.
  void recordTunnelError(TunnelKind kind) {
    if (kind == TunnelKind.aether) return;
    _healthRegistry.recordError(kind);
  }

  String _tunnelDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'psiphon':
        return 'Psiphon';
      case 'aether':
        return 'Aether';
      case 'tor':
        return 'Tor';
      case 'sstp':
        return 'SSTP';
      default:
        return key;
    }
  }

  void touch() {
    if (isShuttingDown) return;
    notifyListeners();
  }

  Future<void> applyScannerResults({
    required List<String> ips,
    String? tlsSni,
  }) async {
    if (ips.isEmpty) return;
    final merged = <String>{...ipList, ...ips}.toList();
    await saveIpList(merged);
    settings.ip = ips.first;
    if (tlsSni != null && tlsSni.isNotEmpty) {
      settings.tlsSni = tlsSni;
      if (!tlsSniList.contains(tlsSni)) {
        await saveTlsSniList([...tlsSniList, tlsSni]);
      }
    }
    settings.isFronted = true;
    settings.useSunAndLion = true;
    settings.upstreamType = 0;
    await saveSettings();
    notifyListeners();
  }

  void applySetting(int number) {
    settings.applyPreset(number);
    saveSettings();
    notifyListeners();
  }

  Future<void> copyLogToClipboard() async {
    final text = processService.fullLog.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
  }

  void cancelAllAutoReconnect() {
    _reconnectManager.cancelAll();
    _watchdogManager?.stopAll();
    _recoveryCoordinator.releaseAll();
    try {
      _aetherTestService.requestCancel();
    } catch (_) {}
  }

  Future<void> shutdownAll() => shutdownAllInternal();

  @override
  void dispose() {
    isShuttingDown = true;

    // ═══════════════════════════════════════════════════════════════
    //  فاز v4: cleanup
    // ═══════════════════════════════════════════════════════════════
    _healthPollTimer?.cancel();
    _healthPollTimer = null;

    _healthMonitor.dispose();
    _degradationDetector.reset();
    _currentActiveCandidate = null;
    _currentHealth = null;
    _escalationInProgress = false;

    // ═══════════════════════════════════════════════════════════════
    //  TunnelHealthRegistry cleanup
    // ═══════════════════════════════════════════════════════════════
    _healthRegistry.dispose();

    _watchdogManager?.disposeAll();
    _recoveryCoordinator.dispose();

    _logSubscription?.cancel();
    _logSubscription = null;

    _aetherTestService.requestCancel();
    _reconnectManager.cancelAll();
    processService.removeListener(handleProcessServiceChange);
    super.dispose();
  }
}
