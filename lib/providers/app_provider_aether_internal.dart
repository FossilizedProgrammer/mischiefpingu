part of 'app_provider.dart';

extension AppProviderAetherInternal on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  _startAetherInternal — start یا restart داخلی.
  ///
  ///  ⚠️ تغییرات این نسخه:
  ///   • fast-path برای هر start اجرا می‌شود (نه فقط auto-reconnect)
  ///   • بعد از fail شدن fast-path، endpoint ذخیره‌شده پاک می‌شود
  ///   • آخرین endpoint واقعی از لاگ Aether استخراج و ذخیره می‌شود
  ///   • checkHappyTransition هنگام اتصال موفق
  ///   • ⚠️ FIX: isAutoTesting در try/finally — جلوگیری از گیر کردن دکمه
  ///   • ⚠️ FIX: چک userStoppedAether بعد از ensureHealthy
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _startAetherInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.aether;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelAetherTimer();
    }

    if (fromAutoReconnect && userStoppedAether) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isAutoTesting) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (already auto-testing)',
        source: src,
      );
      return;
    }

    if (processService.isAetherRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Aether is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    if (!await _preflightAetherBinary(src)) return;
    if (!await _preflightAetherPtDir(src)) return;
    if (!await _preflightAetherPort(src)) return;

    if (!fromAutoReconnect) {
      userStoppedAether = false;
    }

    touch();

    final wasRunning = processService.isAetherRunning;
    final wasConnected =
        wasRunning && aetherStatus.toLowerCase().contains('healthy');

    try {
      // ═══════════════════════════════════════════════════════════
      //  Fast-path: اول با تاریخچه/endpoint تلاش کن
      // ═══════════════════════════════════════════════════════════
      if (settings.aetherTryLastEndpointFirst &&
          settings.aetherCustomEndpoint.trim().isEmpty) {
        final fastResult = await _tryFastPath(src);

        // ⚠️ FIX: چک cancel بعد از fast-path
        if (userStoppedAether) {
          processService.addLog(
            '→ Aether start cancelled by user (after fast-path)',
            source: src,
          );
          return;
        }

        if (fastResult.success) {
          aetherStatus = 'Aether: Healthy (fast-path)';
          processService.setAetherProtocolNotification(
            settings.aetherProtocol == 'auto'
                ? 'auto'
                : settings.aetherProtocol,
          );

          _recordAetherSessionState();

          processService.checkHappyTransition(
            tunnelName: 'Aether',
            wasConnected: wasConnected,
            isConnected: true,
          );

          await AppDataService.fixDataDirOwnership();
          touch();
          return;
        }

        if (fastResult.endpointWasInvalid) {
          processService.addLog(
            '→ Clearing invalid saved endpoint (will not retry)',
            source: src,
          );
          await _aetherTestService.clearLastEndpoint();
        }

        processService.addLog(
          '→ Fast-path failed — falling back to full scan',
          source: src,
        );
      }

      // ═══════════════════════════════════════════════════════════
      //  اگر auto-reconnect است، orchestrator با ranked candidates
      // ═══════════════════════════════════════════════════════════
      if (fromAutoReconnect) {
        _aetherLogger.reconnectAttempt(
          settings: settings,
          attemptNumber: aetherReconnectCount + 1,
          protocol: lastAetherConnectedProtocol ?? 'unknown',
          masque: settings.masqueOption,
          endpoint: lastAetherConnectedGatewayKey ?? '',
        );

        final smartOk = await _trySmartReconnect();

        // ⚠️ FIX: چک cancel بعد از smart reconnect
        if (userStoppedAether) {
          processService.addLog(
            '→ Aether start cancelled by user (after smart reconnect)',
            source: src,
          );
          return;
        }

        if (smartOk) {
          aetherStatus = 'Aether: Healthy';
          processService.setAetherProtocolNotification(
            settings.aetherProtocol == 'auto'
                ? 'auto'
                : settings.aetherProtocol,
          );

          _recordAetherSessionState();

          processService.checkHappyTransition(
            tunnelName: 'Aether',
            wasConnected: wasConnected,
            isConnected: true,
          );

          await AppDataService.fixDataDirOwnership();
          touch();
          return;
        }

        processService.addLog(
          '→ Smart reconnect failed — falling back to full scan',
          source: src,
        );
      }

      // ═══════════════════════════════════════════════════════════
      //  مسیر نهایی: scan کامل
      //
      //  ⚠️ FIX مهم: isAutoTesting در try/finally ریست می‌شه
      //  تا اگر user cancel کرد یا exception رخ داد، flag گیر نکنه.
      // ═══════════════════════════════════════════════════════════
      aetherStatus = settings.aetherProtocol == 'auto'
          ? 'Aether: Auto-testing protocols…'
          : 'Aether: Starting…';
      touch();

      bool ok = false;
      isAutoTesting = true;
      try {
        ok = await _aetherTestService.ensureHealthy(showUi: true);
      } finally {
        // ⚠️ FIX: تضمین ریست در هر شرایطی
        isAutoTesting = false;
      }

      // ⚠️ FIX: چک cancel — اگر کاربر وسط کار cancel کرد، برنگردون موفق
      if (userStoppedAether) {
        processService.addLog(
          '→ Aether start cancelled by user (after ensureHealthy)',
          source: src,
        );
        aetherStatus = 'Aether: Stopped';
        touch();
        return;
      }

      if (ok) {
        aetherStatus = 'Aether: Healthy';
        _recordAetherSessionState();

        processService.checkHappyTransition(
          tunnelName: 'Aether',
          wasConnected: wasConnected,
          isConnected: true,
        );
      } else if (wasRunning && processService.isAetherRunning) {
        aetherStatus = 'Aether: Running (unverified but stable)';
        processService.addLog(
          '⚠ Auto-test failed but Aether was already running — '
          'keeping it alive',
          source: src,
        );
      } else if (processService.isAetherRunning) {
        aetherStatus = 'Aether: Running (unverified)';
      } else {
        aetherStatus = 'Aether: Auto-test failed';
      }
    } catch (e) {
      processService.addLog('✗ connectAether error: $e', source: src);
      aetherStatus = 'Aether: Error';
    } finally {
      // ⚠️ FIX: تضمین ریست flag حتی در exception
      if (isAutoTesting) {
        isAutoTesting = false;
      }
    }

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// نتیجهٔ تلاش fast-path.
  Future<({bool success, bool endpointWasInvalid})> _tryFastPath(
    String src,
  ) async {
    final orchestrator = _gatewayReconnectOrchestrator;
    if (orchestrator == null) {
      processService.addLog(
        '→ Fast-path skipped (no orchestrator)',
        source: src,
      );
      return (success: false, endpointWasInvalid: false);
    }

    processService.addLog(
      '→ Fast-path: trying last successful endpoint…',
      source: src,
    );

    final port = settings.aetherLocalPort;

    try {
      // ─── تلاش ۱: آخرین gateway موفق از DB ───
      final last = await orchestrator.getLastSuccessfulGateway();
      if (last != null && last.endpoint.trim().isNotEmpty) {
        processService.addLog(
          '→ Fast-path [1/2]: trying ${last.uniqueKey} '
          '(score=${last.score.toStringAsFixed(0)})',
          source: src,
        );

        final ok = await orchestrator.tryGateway(
          record: last,
          port: port,
          isCancelRequested: () => userStoppedAether || isShuttingDown,
        );

        if (ok) {
          processService.addLog(
            '★ Fast-path: connected via last successful gateway',
            source: src,
          );
          return (success: true, endpointWasInvalid: false);
        }

        processService.addLog(
          '→ Fast-path [1/2]: last gateway failed',
          source: src,
        );
      } else {
        processService.addLog(
          '→ Fast-path [1/2]: no gateway history',
          source: src,
        );
      }

      // ⚠️ FIX: چک cancel بین دو تلاش
      if (userStoppedAether) {
        return (success: false, endpointWasInvalid: false);
      }

      // ─── تلاش ۲: آخرین endpoint از SharedPreferences ───
      final endpoint = await _aetherTestService.getLastSuccessfulEndpoint();
      if (endpoint == null || endpoint.trim().isEmpty) {
        processService.addLog(
          '→ Fast-path [2/2]: no saved endpoint',
          source: src,
        );
        return (success: false, endpointWasInvalid: false);
      }

      final winner = await _aetherTestService.loadAutoWinner();
      final protocol = winner?.key ?? 'masque';
      final masque = winner?.value ?? 'HTTP-3';

      processService.addLog(
        '→ Fast-path [2/2]: trying saved endpoint $endpoint '
        '($protocol${masque.isNotEmpty ? "/$masque" : ""})',
        source: src,
      );

      final ok = await orchestrator.tryEndpointDirect(
        endpoint: endpoint,
        protocol: protocol,
        masque: masque,
        port: port,
        isCancelRequested: () => userStoppedAether || isShuttingDown,
      );

      if (ok) {
        processService.addLog(
          '★ Fast-path: connected via saved endpoint',
          source: src,
        );
        return (success: true, endpointWasInvalid: false);
      }

      processService.addLog(
        '→ Fast-path [2/2]: saved endpoint failed',
        source: src,
      );
      return (success: false, endpointWasInvalid: true);
    } catch (e) {
      processService.addLog('⚠ Fast-path threw: $e', source: src);
      return (success: false, endpointWasInvalid: false);
    }
  }

  /// ثبت session state برای UI status card (فاز ۶).
  void _recordAetherSessionState() {
    lastAetherConnectedProtocol =
        settings.aetherProtocol == 'auto' ? 'auto' : settings.aetherProtocol;
    lastAetherConnectedGatewayKey =
        '${settings.ip}:${settings.aetherLocalPort}';
    lastAetherConnectedAt = DateTime.now();
    touch();
  }

  /// restartAetherInternal — برای استفاده watchdog.
  Future<void> restartAetherInternal({required String reason}) async {
    const src = LogSource.aether;

    if (userStoppedAether || isShuttingDown) {
      processService.addLog(
        '→ restartAetherInternal skipped '
        '(userStopped=$userStoppedAether, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingAether) {
      processService.addLog(
        '→ restartAetherInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingAether = true;
    try {
      processService.addLog(
        '↻ Restarting Aether — reason: $reason',
        source: src,
      );
      processService.setSadNotification('Aether');

      if (lastAetherConnectedAt != null) {
        _aetherLogger.connectionLost(
          settings: settings,
          protocol: lastAetherConnectedProtocol ?? 'unknown',
          masque: settings.masqueOption,
          uptime: DateTime.now().difference(lastAetherConnectedAt!),
          reason: reason,
          reconnectCount: aetherReconnectCount,
        );
      }

      aetherReconnectCount++;

      try {
        await _aetherTestService.performanceTracker?.cancel();
      } catch (_) {}

      _reconnectManager.cancelAetherTimer();
      nextAetherGeneration();

      await processService.stopAether();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedAether && !isShuttingDown) {
        await _startAetherInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingAether = false;
    }
  }
}
