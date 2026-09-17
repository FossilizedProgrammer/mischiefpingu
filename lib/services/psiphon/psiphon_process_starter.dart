part of '../process_service.dart';

extension ProcessServicePsiphonStarter on ProcessService {
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

    final configFile = File(p.join(dataDir, 'config_temp.json'));
    await configFile.writeAsString(finalConfigJson);

    final args = <String>['--config', configFile.path];
    final serverListPath = p.join(dataDir, 'server_list.dat');
    if (await File(serverListPath).exists()) {
      args.addAll(['--serverList', serverListPath]);
      addLog('Using server_list.dat', source: src);
    } else {
      addLog(
          'No server_list.dat — Psiphon will fetch a fresh list from the network',
          source: src);
    }

    psiphonProcess = await Process.start(
      binaryPath,
      args,
      workingDirectory: dataDir,
      mode: ProcessStartMode.normal,
    );
    await Future.delayed(const Duration(milliseconds: 700));

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

    isPsiphonRunning = true;
    lastPsiphonProtocol = null;
    currentPsiphonBinaryName = binaryName;
    addLog('Psiphon started ($binaryName) [PID: ${psiphonProcess!.pid}]',
        source: src);
    touch();

    if (shareLan) {
      await startDartLanForwarders(
        publicSocksPort: publicSocksPort,
        publicHttpPort: publicHttpPort,
        internalSocksPort: effectiveSocksPort,
        internalHttpPort: effectiveHttpPort,
        source: src,
      );
    }

    attachPsiphonListeners(binaryName);

    return true;
  }
}
