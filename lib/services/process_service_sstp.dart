// lib/services/process_service_sstp.dart
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

  // ⚠️ stopSstp رو اینجا تعریف نکن!
  // این متد در sstp_stopper.dart (extension ProcessServiceSstpStopper) تعریف شده.
}
