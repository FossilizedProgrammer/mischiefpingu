part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderGephPreflight — چک باینری، حساب و پورت قبل از استارت گف.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderGephPreflight on AppProvider {
  /// مسیر باینری geph5-proxy را پیدا می‌کند؛ اگر نبود پیام می‌دهد و null
  /// برمی‌گرداند.
  Future<String?> _preflightGephBinary(String src) async {
    final path = await AppDataService.resolveBinaryPath('geph5-proxy');
    if (path != null) return path;

    processService.addLog(
      '✗ geph5-proxy binary not found. Place "geph5-proxy'
      '${AppDataService.exeExt}" in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      'geph5-proxy',
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'geph5-proxy${AppDataService.exeExt} binary not found. '
      'Place it in the data folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  /// پوشهٔ والدِ فایل حساب و کش را می‌سازد/بررسی می‌کند.
  ///
  /// اگر یکی از اجزای والد یک فایل باشد (مثلاً مسیر کاربر روی فایل دیگری
  /// بیفتد) باینری با خطای مبهم `File exists (os error 17)` می‌میرد؛ اینجا
  /// جلوتر با پیام روشن تشخیص داده می‌شود.
  Future<bool> _preflightGephPaths(String src) async {
    final cli = GephCliService(
      settings: settings,
      processService: processService,
    );
    for (final path in await cli.writablePaths()) {
      final parent = File(path).parent;
      try {
        await parent.create(recursive: true);
        if (!await parent.exists()) {
          throw FileSystemException('could not create', parent.path);
        }
      } catch (e) {
        processService.addLog(
          '✗ Geph cannot use the path "$path": $e — pick a different account '
          'file / folder in the Geph settings.',
          source: src,
        );
        gephStatus = 'Geph: bad account path';
        touch();
        return false;
      }
    }
    return true;
  }

  /// کد حساب گف باید از قبل آماده باشد؛ وگرنه `run` منتظر ورودی استاینر
  /// می‌ماند. false یعنی استارت انجام نشود.
  Future<bool> _preflightGephAccount(String src) async {
    if (!await _preflightGephPaths(src)) return false;

    final cli = GephCliService(
      settings: settings,
      processService: processService,
    );
    if (await cli.hasConfiguredAccount()) return true;

    final hint = settings.gephAccountSource == AppSettings.gephAccountSourceCode
        ? 'the login code is empty'
        : 'no readable account file at ${await cli.resolvedAccountFile()}';
    processService.addLog(
      '✗ No Geph account yet ($hint) — open "Geph Settings → Account" and '
      'press "Create account", or provide a login code / account file.',
      source: src,
    );
    gephStatus = 'Geph: no account';
    touch();
    return false;
  }

  /// پورت‌های SOCKS/HTTP گف را چک می‌کند (HTTP با 0 غیرفعال است).
  Future<bool> _preflightGephPorts(String src) async {
    final ports = <String, int>{
      'SOCKS': settings.gephSocksPort,
      'HTTP': settings.gephHttpPort,
    };
    for (final entry in ports.entries) {
      if (entry.value <= 0) continue;
      if (await ProcessService.isPortInUse(entry.value)) {
        processService.addLog(
          '✗ Geph ${entry.key} port ${entry.value} is already in use',
          source: src,
        );
        processService.setPortConflictMessage(
          'Geph: ${entry.key} port ${entry.value} is already in use '
          'by another program. Pick a different port in the Geph '
          'settings.',
        );
        touch();
        return false;
      }
    }
    return true;
  }
}
