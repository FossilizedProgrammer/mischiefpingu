// lib/services/diagnostics/diagnostics_report_builder.dart

library;

import 'dart:convert';

import '../../models/settings_model.dart';
import '../database/gateway_history_store.dart';
import '../process_service.dart';
import 'diagnostics_report_redactor.dart';

/// ═══════════════════════════════════════════════════════════════
///  DiagnosticsReportBuilder — تولید گزارش تشخیصی از وضعیت برنامه.
///
///  گزارش شامل:
///    • اطلاعات نسخه و پلتفرم
///    • تنظیمات فعلی (با redaction)
///    • آخرین لاگ‌ها (با redaction)
///    • آخرین gatewayهای موفق
///    • وضعیت فعلی تونل‌ها
///
///  ⚠️ همه اطلاعات حساس قبل از نوشتن redact میشن.
/// ═══════════════════════════════════════════════════════════════
class DiagnosticsReportBuilder {
  final ProcessService processService;
  final GatewayHistoryStore? gatewayHistoryStore;
  final AppSettings settings;

  DiagnosticsReportBuilder({
    required this.processService,
    required this.settings,
    this.gatewayHistoryStore,
  });

  /// ساخت گزارش کامل به صورت یک رشته.
  Future<String> build() async {
    final sb = StringBuffer();

    _writeHeader(sb);
    _writeTimestamp(sb);
    _writeTunnelStates(sb);
    _writeSettings(sb);
    _writeRecentGateways(sb);
    _writeRecentLogs(sb);
    _writeFooter(sb);

    final raw = sb.toString();
    return DiagnosticsReportRedactor.redact(raw);
  }

  // ═══════════════════════════════════════════════════════════════
  //  بخش‌های گزارش
  // ═══════════════════════════════════════════════════════════════

  void _writeHeader(StringBuffer sb) {
    sb.writeln('═══════════════════════════════════════════════════');
    sb.writeln('  MischiefPingu — Diagnostics Report');
    sb.writeln('═══════════════════════════════════════════════════');
    sb.writeln();
  }

  void _writeTimestamp(StringBuffer sb) {
    sb.writeln('## Report Info');
    sb.writeln('Generated at: ${DateTime.now().toIso8601String()}');
    sb.writeln();
  }

  void _writeTunnelStates(StringBuffer sb) {
    sb.writeln('## Tunnel States');
    final ps = processService;
    sb.writeln('Psiphon running:    ${ps.isPsiphonRunning}');
    sb.writeln('Psiphon connected:  ${ps.isPsiphonConnected}');
    sb.writeln('Aether running:     ${ps.isAetherRunning}');
    sb.writeln('Aether ready:       ${ps.isAetherTunnelReady}');
    sb.writeln('Tor running:        ${ps.isTorRunning}');
    sb.writeln('Tor connected:      ${ps.isTorConnected}');
    sb.writeln('SSTP running:       ${ps.isSstpRunning}');
    sb.writeln('SSTP connected:     ${ps.isSstpConnected}');
    sb.writeln('WireGuard running:  ${ps.isWireGuardRunning}');
    sb.writeln('WireGuard connected:${ps.isWireGuardConnected}');
    sb.writeln();
  }

  void _writeSettings(StringBuffer sb) {
    sb.writeln('## Settings');
    final s = settings;

    sb.writeln('### Aether');
    sb.writeln('aetherProfile:           ${s.aetherProfile}');
    sb.writeln('aetherProtocol:          ${s.aetherProtocol}');
    sb.writeln('aetherScanMode:          ${s.aetherScanMode}');
    sb.writeln('aetherEndpointPinning:   ${s.aetherEndpointPinning}');
    sb.writeln('masqueOption:            ${s.masqueOption}');
    sb.writeln('obfuscation:             ${s.obfuscation}');
    sb.writeln('ipType:                  ${s.ipType}');
    sb.writeln('aetherLocalPort:         ${s.aetherLocalPort}');
    sb.writeln('aetherTryLastEndpoint:   ${s.aetherTryLastEndpointFirst}');
    sb.writeln('aetherCustomEndpoint:    ${_safe(s.aetherCustomEndpoint)}');
    sb.writeln();

    sb.writeln('### Psiphon');
    sb.writeln('upstreamType:            ${s.upstreamType}');
    sb.writeln('isFronted:               ${s.isFronted}');
    sb.writeln('useSunAndLion:           ${s.useSunAndLion}');
    sb.writeln('socksPort:               ${s.socksPort}');
    sb.writeln('httpPort:                ${s.httpPort}');
    sb.writeln('egressRegion:            ${s.egressRegion}');
    sb.writeln('ip:                      ${_safe(s.ip)}');
    sb.writeln('httpHost:                ${s.httpHost}');
    sb.writeln('tlsSni:                  ${s.tlsSni}');
    sb.writeln();

    sb.writeln('### Watchdog');
    sb.writeln('watchdogEnabled:         ${s.watchdogEnabled}');
    sb.writeln('watchdogProfile:         ${s.watchdogNetworkProfile}');
    sb.writeln();

    sb.writeln('### Other');
    sb.writeln('themeId:                 ${s.themeId}');
    sb.writeln('muted:                   ${s.muted}');
    sb.writeln('enabledLogSources:       ${s.enabledLogSources.join(", ")}');
    sb.writeln();
  }

  Future<void> _writeRecentGateways(StringBuffer sb) async {
    sb.writeln('## Recent Successful Gateways (Top 5)');
    final store = gatewayHistoryStore;
    if (store == null) {
      sb.writeln('(no gateway history store available)');
      sb.writeln();
      return;
    }

    try {
      final top = await store.getTopGateways(limit: 5);
      if (top.isEmpty) {
        sb.writeln('(no records)');
      } else {
        for (final r in top) {
          sb.writeln(
            '- ${r.protocol.toUpperCase()}'
            '${r.masqueOption.isNotEmpty ? "/${r.masqueOption}" : ""} '
            'score=${r.score.toStringAsFixed(1)} '
            'success=${r.successCount} '
            'failure=${r.failureCount} '
            'lat=${r.avgLatencyMs}ms '
            'endpoint=${_safe(r.endpoint)}',
          );
        }
      }
    } catch (e) {
      sb.writeln('(error reading gateway history: $e)');
    }
    sb.writeln();
  }

  void _writeRecentLogs(StringBuffer sb) {
    sb.writeln('## Recent Logs (last 200 lines)');
    final logs = processService.fullLog;
    final start = logs.length > 200 ? logs.length - 200 : 0;
    for (var i = start; i < logs.length; i++) {
      sb.writeln(logs[i]);
    }
    sb.writeln();
  }

  void _writeFooter(StringBuffer sb) {
    sb.writeln('═══════════════════════════════════════════════════');
    sb.writeln('  End of Report');
    sb.writeln('═══════════════════════════════════════════════════');
  }

  /// اگه رشته خالیه، یه placeholder برگردون.
  String _safe(String value) => value.isEmpty ? '(empty)' : value;
}

/// helper برای encode کردن settings به JSON (اختیاری).
String settingsToPrettyJson(AppSettings s) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(s.toJson());
}
