part of 'app_provider.dart';

extension AppProviderAetherInternal on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  _startAetherInternal — start یا restart داخلی.
  ///
  ///  ⚠️ تغییرات این نسخه:
  ///   • fast-path برای هر start اجرا می‌شود (نه فقط auto-reconnect)
  ///   • بعد از fail شدن fast-path، endpoint ذخیره‌شده پاک می‌شود
  ///   • آخرین endpoint واقعی از لاگ Aether استخراج و ذخیره می‌شود
  ///   • ⚠️ اضافه‌شده: checkHappyTransition هنگام اتصال موفق
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
        if (fastResult.success) {
          aetherStatus = 'Aether: Healthy (fast-path)';
          processService.setAetherProtocolNotification(
            settings.aetherProtocol == 'auto'
                ? 'auto'
                : settings.aetherProtocol,
          );

          _recordAetherSessionState();

          // ═══════════════════════════════════════════════════════════
          //  ⚠️ نوتیف شادی هنگام اتصال موفق (fast-path)
          // ═══════════════════════════════════════════════════════════
          processService.checkHappyTransition(
            tunnelName: 'Aether',
            wasConnected: wasConnected,
            isConnected: true,
          );

          await AppDataService.fixDataDirOwnership();
          touch();
          return;
        }

        // ═══════════════════════════════════════════════════════
        //  ⚠️ اگر fast-path از endpoint ذخیره‌شده استفاده کرد و
        //  آن fail شد، آن را پاک کن تا بار بعد تلاش نکنیم.
        // ═══════════════════════════════════════════════════════
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
        if (smartOk) {
          aetherStatus = 'Aether: Healthy';
          processService.setAetherProtocolNotification(
            settings.aetherProtocol == 'auto'
                ? 'auto'
                : settings.aetherProtocol,
          );

          _recordAetherSessionState();

          // ═══════════════════════════════════════════════════════════
          //  ⚠️ نوتیف شادی هنگام اتصال موفق (smart reconnect)
          // ═══════════════════════════════════════════════════════════
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
      // ═══════════════════════════════════════════════════════════
      aetherStatus = settings.aetherProtocol == 'auto'
          ? 'Aether: Auto-testing protocols…'
          : 'Aether: Starting…';
      touch();

      isAutoTesting = true;
      final ok = await _aetherTestService.ensureHealthy(showUi: true);
      isAutoTesting = false;

      if (ok) {
        aetherStatus = 'Aether: Healthy';
        _recordAetherSessionState();

        // ═══════════════════════════════════════════════════════════
        //  ⚠️ نوتیف شادی هنگام اتصال موفق (full scan)
        // ═══════════════════════════════════════════════════════════
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
      // ⚠️ این endpoint نامعتبر بود، باید پاک شود
      return (success: false, endpointWasInvalid: true);
    } catch (e) {
      processService.addLog('⚠ Fast-path threw: $e', source: src);
      return (success: false, endpointWasInvalid: false);
    }
  }

  /// ثبت session state برای UI status card (فاز ۶).
  void _recordAetherSessionState() {
    lastAetherConnectedProtocol = settings.aetherProtocol == 'auto'
        ? 'auto'
        : settings.aetherProtocol;
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
