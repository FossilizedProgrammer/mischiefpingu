part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  آماده‌سازی config برای SSTP.
///
///  این تابع config می‌سازه، notification آماده می‌کنه و
///  args نهایی رو برمی‌گردونه.
///
///  خروجی:
///    • `null` یعنی user در طول کار cancel کرد — caller باید
///      بلافاصله return کنه
///    • `({List<String> args})` یعنی args آماده‌ست
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpLaunchPrepare on AppProvider {
  Future<({List<String> args})?> _prepareSstpConfig(String src) async {
    try {
      final builder = SstpConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final args = builder.buildArgs();

      // ⚠️ چک cancel بعد از build
      if (userStoppedSstp) {
        _logSstpCancel(src, 'after config build');
        return null;
      }

      // ─── prepare notification ───
      final serverInfo = '${settings.sstpServer}:${settings.sstpPort}';
      processService.prepareSstpNotification(
        serverInfo,
        'Server: $serverInfo',
      );

      return (args: args);
    } catch (e) {
      processService.addLog(
        '✗ SSTP config build failed: $e',
        source: src,
      );
      rethrow;
    }
  }
}
