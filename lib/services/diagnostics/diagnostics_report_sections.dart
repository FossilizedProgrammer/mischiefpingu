part of 'diagnostics_report_builder.dart';

/// ═══════════════════════════════════════════════════════════════
///  بخش‌های گزارش تشخیصی — توابع top-level.
///
///  ⚠️ این توابع از `diagnostics_report_builder.dart` صدا زده
///  می‌شن و از طریق `part of` به imports اون دسترسی دارن.
///
///  چرا توابع top-level نه متد private؟
///    • نیاز به دسترسی به `_safe` ندارن (خودشون helper دارن)
///    • تست‌پذیرتر هستن (اگه یه روز export بشن)
///    • خوانایی بیشتری دارن
/// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
//  Header + Timestamp + Footer
// ═══════════════════════════════════════════════════════════════

/// نوشتن هدر گزارش.
void writeReportHeader(StringBuffer sb) {
  sb.writeln('═══════════════════════════════════════════════════');
  sb.writeln('  MischiefPingu — Diagnostics Report');
  sb.writeln('═══════════════════════════════════════════════════');
  sb.writeln();
}

/// نوشتن timestamp تولید گزارش.
void writeReportTimestamp(StringBuffer sb) {
  sb.writeln('## Report Info');
  sb.writeln('Generated at: ${DateTime.now().toIso8601String()}');
  sb.writeln();
}

/// نوشتن footer گزارش.
void writeReportFooter(StringBuffer sb) {
  sb.writeln('═══════════════════════════════════════════════════');
  sb.writeln('  End of Report');
  sb.writeln('═══════════════════════════════════════════════════');
}

// ═══════════════════════════════════════════════════════════════
//  Tunnel States
// ═══════════════════════════════════════════════════════════════

/// نوشتن وضعیت تونل‌های فعال.
void writeTunnelStates(StringBuffer sb, ProcessService ps) {
  sb.writeln('## Tunnel States');
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

// ═══════════════════════════════════════════════════════════════
//  Settings
// ═══════════════════════════════════════════════════════════════

/// نوشتن تنظیمات فعلی.
void writeSettingsSection(StringBuffer sb, AppSettings s) {
  sb.writeln('## Settings');

  _writeAetherSettings(sb, s);
  _writePsiphonSettings(sb, s);
  _writeWatchdogSettings(sb, s);
  _writeOtherSettings(sb, s);
}

void _writeAetherSettings(StringBuffer sb, AppSettings s) {
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
}

void _writePsiphonSettings(StringBuffer sb, AppSettings s) {
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
}

void _writeWatchdogSettings(StringBuffer sb, AppSettings s) {
  sb.writeln('### Watchdog');
  sb.writeln('watchdogEnabled:         ${s.watchdogEnabled}');
  sb.writeln('watchdogProfile:         ${s.watchdogNetworkProfile}');
  sb.writeln();
}

void _writeOtherSettings(StringBuffer sb, AppSettings s) {
  sb.writeln('### Other');
  sb.writeln('themeId:                 ${s.themeId}');
  sb.writeln('muted:                   ${s.muted}');
  sb.writeln('enabledLogSources:       ${s.enabledLogSources.join(", ")}');
  sb.writeln();
}

// ═══════════════════════════════════════════════════════════════
//  Recent Gateways
// ═══════════════════════════════════════════════════════════════

/// نوشتن تاریخچه Gatewayهای موفق.
Future<void> writeRecentGateways(
  StringBuffer sb,
  GatewayHistoryStore? store,
) async {
  sb.writeln('## Recent Successful Gateways (Top 5)');
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

// ═══════════════════════════════════════════════════════════════
//  Recent Logs
// ═══════════════════════════════════════════════════════════════

/// نوشتن آخرین ۲۰۰ خط لاگ.
void writeRecentLogs(StringBuffer sb, ProcessService ps) {
  sb.writeln('## Recent Logs (last 200 lines)');
  final logs = ps.fullLog;
  final start = logs.length > 200 ? logs.length - 200 : 0;
  for (var i = start; i < logs.length; i++) {
    sb.writeln(logs[i]);
  }
  sb.writeln();
}

// ═══════════════════════════════════════════════════════════════
//  Helper
// ═══════════════════════════════════════════════════════════════

/// اگه رشته خالیه، یه placeholder برگردون.
String _safe(String value) => value.isEmpty ? '(empty)' : value;
