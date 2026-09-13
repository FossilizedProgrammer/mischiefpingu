// lib/services/psiphon_launcher.dart
part of 'process_service.dart';

extension ProcessServicePsiphonLauncher on ProcessService {
  /// spawn پروسه Psiphon + تنظیم forwarderها + اتصال listenerها
  Future<bool> launchPsiphonProcess({
    required String binaryPath,
    required String binaryName,
    required String dataDir,
    required String configJson,
    required int publicSocksPort,
    required int publicHttpPort,
    required bool shareLan,
  }) async {
    const src = LogSource.psiphon;

    // ─── اگر shareLan، پورت‌های داخلی رو جابجا کن ───
    int effectiveSocksPort = publicSocksPort;
    int effectiveHttpPort = publicHttpPort;
    String finalConfigJson = configJson;

    if (shareLan) {
      effectiveSocksPort = publicSocksPort + 10000;
      effectiveHttpPort = publicHttpPort + 10000;
      if (await ProcessService.isPortInUse(effectiveSocksPort)) {
        effectiveSocksPort = await findFreePort();
      }
      if (await ProcessService.isPortInUse(effectiveHttpPort)) {
        effectiveHttpPort = await findFreePort();
      }
      final configMap = jsonDecode(configJson) as Map<String, dynamic>;
      configMap['LocalSocksProxyPort'] = effectiveSocksPort;
      configMap['LocalHttpProxyPort'] = effectiveHttpPort;
      finalConfigJson = const JsonEncoder.withIndent('  ').convert(configMap);
      addLog(
        '→ Share on LAN (pure Dart): internal ports → SOCKS:$effectiveSocksPort  HTTP:$effectiveHttpPort',
        source: src,
      );
      addLog(
        '→ public ports remain → SOCKS:$publicSocksPort  HTTP:$publicHttpPort',
        source: src,
      );
    }

    // ─── نوشتن فایل کانفیگ ───
    final configFile = File(p.join(dataDir, 'config_temp.json'));
    await configFile.writeAsString(finalConfigJson);

    // ─── ساخت آرگومان‌ها ───
    final args = <String>['--config', configFile.path];
    final serverListPath = p.join(dataDir, 'server_list.dat');
    if (await File(serverListPath).exists()) {
      args.addAll(['--serverList', serverListPath]);
      addLog('Using server_list.dat', source: src);
    } else {
      addLog('Warning: server_list.dat not found', source: src);
    }

    // ─── spawn ───
    psiphonProcess = await Process.start(
      binaryPath,
      args,
      workingDirectory: dataDir,
      mode: ProcessStartMode.normal,
    );
    await Future.delayed(const Duration(milliseconds: 700));

    // ─── بررسی خروج سریع ───
    bool exitedQuickly = false;
    try {
      await psiphonProcess!.exitCode.timeout(
        const Duration(milliseconds: 200),
      );
      exitedQuickly = true;
    } catch (_) {
      exitedQuickly = false;
    }
    if (exitedQuickly) {
      isPsiphonRunning = false;
      psiphonProcess = null;
      currentPsiphonBinaryName = null;
      addLog('Psiphon exited immediately', source: src);
      touch();
      return false;
    }

    // ─── موفق ───
    isPsiphonRunning = true;
    lastPsiphonProtocol = null;
    currentPsiphonBinaryName = binaryName;
    addLog('Psiphon started ($binaryName) [PID: ${psiphonProcess!.pid}]',
        source: src);
    touch();

    // ─── forwarder برای LAN ───
    if (shareLan) {
      await startDartLanForwarders(
        publicSocksPort: publicSocksPort,
        publicHttpPort: publicHttpPort,
        internalSocksPort: effectiveSocksPort,
        internalHttpPort: effectiveHttpPort,
        source: src,
      );
    }

    // ─── listenerها ───
    _attachPsiphonListeners(binaryName);

    return true;
  }

  void _attachPsiphonListeners(String binaryName) {
    const src = LogSource.psiphon;

    void handleLine(String trimmed) {
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      if (trimmed.contains('"noticeType":"ActiveTunnel"')) {
        final protocol = LogLineParsers.parseActiveTunnelProtocol(trimmed);
        isPsiphonConnected = true;
        if (protocol != null) {
          lastPsiphonProtocol = protocol;
          pendingProtocolNotification = protocol;
          pendingProtocolBinary = binaryName;
        }
        touch();
      }
    }

    psiphonProcess!.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });
    psiphonProcess!.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });

    psiphonProcess!.exitCode.then((code) {
      isPsiphonRunning = false;
      isPsiphonConnected = false;
      lastPsiphonProtocol = null;
      pendingProtocolNotification = null;
      pendingProtocolBinary = null;
      currentPsiphonBinaryName = null;
      psiphonProcess = null;
      addLog('Psiphon exited with code $code', source: src);
      touch();
    });
  }
}
