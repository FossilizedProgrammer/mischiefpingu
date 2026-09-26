part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  _startAetherInternal — start یا restart داخلی.
///
///  ⚠️ بازآرایی: این فایل حالا فقط orchestrator هست.
///  منطق در فایل‌های part جداگانه:
///    • aether/aether_start_guards.dart → _checkAetherStartGuards
///    • aether/aether_fast_path.dart    → _tryFastPath و helperها
///    • aether/aether_restart.dart      → restartAetherInternal
///
///  ⚠️ تغییرات این نسخه:
///   • fast-path حالا به تابع جدا منتقل شده
///   • guardها در یک تابع متمرکز شدن
///   • isAutoTesting در try/finally — جلوگیری از گیر کردن دکمه
///   • چک userStoppedAether بعد از ensureHealthy
/// ═══════════════════════════════════════════════════════════════
extension AppProviderAetherInternal on AppProvider {
  Future<void> _startAetherInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.aether;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelAetherTimer();
    }

    // ═══════════════════════════════════════════════════════════
    //  Guardها — بررسی می‌کنن که آیا باید ادامه بدیم
    // ═══════════════════════════════════════════════════════════
    final guards = _checkAetherStartGuards(src, fromAutoReconnect);
    if (!guards.proceed) return;

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

        // چک cancel بعد از fast-path
        if (userStoppedAether) {
          processService.addLog(
            '→ Aether start cancelled by user (after fast-path)',
            source: src,
          );
          return;
        }

        if (fastResult.success) {
          _finalizeAetherSuccess(
            src: src,
            wasConnected: wasConnected,
            statusText: 'Aether: Healthy (fast-path)',
          );
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
        final smartResult = await _trySmartReconnectWithLogging(src);

        // چک cancel بعد از smart reconnect
        if (userStoppedAether) {
          processService.addLog(
            '→ Aether start cancelled by user (after smart reconnect)',
            source: src,
          );
          return;
        }

        if (smartResult) {
          _finalizeAetherSuccess(
            src: src,
            wasConnected: wasConnected,
            statusText: 'Aether: Healthy',
          );
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
      //  isAutoTesting در try/finally ریست می‌شه تا اگر user
      //  cancel کرد یا exception رخ داد، flag گیر نکنه.
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
        isAutoTesting = false;
      }

      // چک cancel — اگر کاربر وسط کار cancel کرد، برنگردون موفق
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
      if (isAutoTesting) {
        isAutoTesting = false;
      }
    }

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  Smart reconnect با لاگ شروع.
  ///
  ///  این متد فقط پوشش لاگ و فراخوانی _trySmartReconnect هست.
  ///  منطق اصلی در `aether/aether_smart_reconnect.dart` قرار داره.
  /// ═══════════════════════════════════════════════════════════════
  Future<bool> _trySmartReconnectWithLogging(String src) async {
    _aetherLogger.reconnectAttempt(
      settings: settings,
      attemptNumber: aetherReconnectCount + 1,
      protocol: lastAetherConnectedProtocol ?? 'unknown',
      masque: settings.masqueOption,
      endpoint: lastAetherConnectedGatewayKey ?? '',
    );

    return _trySmartReconnect();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  نهایی‌سازی موفقیت (fast-path یا smart reconnect).
  ///
  ///  این متد مشترک بین دو مسیر هست تا کد تکراری حذف بشه.
  /// ═══════════════════════════════════════════════════════════════
  void _finalizeAetherSuccess({
    required String src,
    required bool wasConnected,
    required String statusText,
  }) {
    aetherStatus = statusText;
    processService.setAetherProtocolNotification(
      settings.aetherProtocol == 'auto' ? 'auto' : settings.aetherProtocol,
    );

    _recordAetherSessionState();

    processService.checkHappyTransition(
      tunnelName: 'Aether',
      wasConnected: wasConnected,
      isConnected: true,
    );
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
}
