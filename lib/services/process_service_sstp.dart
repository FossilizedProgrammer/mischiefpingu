part of 'process_service.dart';

extension ProcessServiceSstp on ProcessService {
  Future<bool> startSstp({
    required List<String> args,
    required bool shareLan,
    required int socksPort,
    required int httpPort,
  }) async {
    await ensureInitialized();
    if (isSstpRunning) return false;

    return launchSstpProcess(
      args: args,
      shareLan: shareLan,
      socksPort: socksPort,
      httpPort: httpPort,
    );
  }
}
