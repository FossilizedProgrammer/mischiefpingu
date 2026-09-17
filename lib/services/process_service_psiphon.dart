part of 'process_service.dart';

extension ProcessServicePsiphon on ProcessService {
  Future<bool> startPsiphon({
    required String configJson,
    required bool useSunAndLion,
    required bool shareLan,
    required int socksPort,
    required int httpPort,
  }) async {
    await ensureInitialized();
    if (isPsiphonRunning) return false;
    const src = LogSource.psiphon;

    try {
      final dataDir = await AppDataService.getDataDir();
      final binaryName = useSunAndLion
          ? 'psiphon-tunnel-core-sunandlion'
          : 'psiphon-tunnel-core';
      final binaryPath = await AppDataService.getBinaryPath(binaryName);

      if (!await File(binaryPath).exists()) {
        addLog('ERROR: Binary not found → $binaryPath', source: src);
        return false;
      }

      return await launchPsiphonProcess(
        binaryPath: binaryPath,
        binaryName: binaryName,
        dataDir: dataDir,
        configJson: configJson,
        publicSocksPort: socksPort,
        publicHttpPort: httpPort,
        shareLan: shareLan,
      );
    } catch (e) {
      addLog('Failed to start Psiphon: $e', source: src);
      isPsiphonRunning = false;
      currentPsiphonBinaryName = null;
      touch();
      return false;
    }
  }

  Future<void> stopPsiphon() => shutdownPsiphonProcess();
}
