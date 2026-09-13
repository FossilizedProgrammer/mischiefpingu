// lib/services/process_service_tor.dart
part of 'process_service.dart';

extension ProcessServiceTor on ProcessService {
  Future<bool> startTor({
    required String torrcPath,
    required String workDir,
    required Map<String, String>? env,
    required bool shareLan,
    required int socksPort,
    required int httpPort,
    required int internalSocksPort,
    required int internalHttpPort,
  }) async {
    await ensureInitialized();
    if (isTorRunning) return false;

    return launchTorProcess(
      torrcPath: torrcPath,
      workDir: workDir,
      env: env,
      shareLan: shareLan,
      socksPort: socksPort,
      httpPort: httpPort,
      internalSocksPort: internalSocksPort,
      internalHttpPort: internalHttpPort,
    );
  }

  // ⚠️ stopTor رو اینجا تعریف نکن!
  // این متد در tor_stopper.dart (extension ProcessServiceTorStopper) تعریف شده.
}
