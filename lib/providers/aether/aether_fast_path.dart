part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Fast-path Aether — تلاش سریع با endpoint ذخیره‌شده.
///
///  این منطق دو مرحله‌ای هست:
///    1. آخرین gateway موفق از DB
///    2. آخرین endpoint ذخیره‌شده از SharedPreferences
///
///  ⚠️ هدف: در auto-reconnect، بدون scan کامل، سریع وصل بشیم.
///
///  ⚠️ نکته: `endpointWasInvalid=true` یعنی endpoint ذخیره‌شده
///  fail شد و باید پاک بشه.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderAetherFastPath on AppProvider {
  /// تلاش fast-path.
  ///
  /// خروجی:
  ///   • `success=true` یعنی اتصال برقرار شد
  ///   • `endpointWasInvalid=true` یعنی endpoint ذخیره‌شده fail
  ///     شد و باید پاک بشه
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

    // ═══════════════════════════════════════════════════════════
    //  تلاش ۱: آخرین gateway موفق از DB
    // ═══════════════════════════════════════════════════════════
    final dbResult = await _tryFastPathFromDb(
      orchestrator: orchestrator,
      port: port,
      src: src,
    );
    if (dbResult != null) return dbResult;

    // چک cancel بین دو تلاش
    if (userStoppedAether) {
      return (success: false, endpointWasInvalid: false);
    }

    // ═══════════════════════════════════════════════════════════
    //  تلاش ۲: آخرین endpoint از SharedPreferences
    // ═══════════════════════════════════════════════════════════
    return _tryFastPathFromSavedEndpoint(
      orchestrator: orchestrator,
      port: port,
      src: src,
    );
  }

  /// تلاش fast-path از DB.
  ///
  /// خروجی null یعنی باید به تلاش دوم بریم.
  /// خروجی غیر null یعنی نتیجه نهایی (موفق یا ناموفق).
  Future<({bool success, bool endpointWasInvalid})?> _tryFastPathFromDb({
    required GatewayReconnectOrchestrator orchestrator,
    required int port,
    required String src,
  }) async {
    try {
      final last = await orchestrator.getLastSuccessfulGateway();

      if (last == null || last.endpoint.trim().isEmpty) {
        processService.addLog(
          '→ Fast-path [1/2]: no gateway history',
          source: src,
        );
        return null;
      }

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
      return null;
    } catch (e) {
      processService.addLog('⚠ Fast-path [1/2] threw: $e', source: src);
      return null;
    }
  }

  /// تلاش fast-path از endpoint ذخیره‌شده.
  Future<({bool success, bool endpointWasInvalid})>
      _tryFastPathFromSavedEndpoint({
    required GatewayReconnectOrchestrator orchestrator,
    required int port,
    required String src,
  }) async {
    try {
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
      processService.addLog('⚠ Fast-path [2/2] threw: $e', source: src);
      return (success: false, endpointWasInvalid: false);
    }
  }
}
