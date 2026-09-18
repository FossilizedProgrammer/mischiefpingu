part of 'process_service.dart';

extension ProcessServiceLan on ProcessService {
  Future<void> startDartLanForwarders({
    required int publicSocksPort,
    required int publicHttpPort,
    required int internalSocksPort,
    required int internalHttpPort,
    required String source,
  }) => forwarder.startDartLanForwarders(
    publicSocksPort: publicSocksPort,
    publicHttpPort: publicHttpPort,
    internalSocksPort: internalSocksPort,
    internalHttpPort: internalHttpPort,
    source: source,
    onReady: (socks, http) {
      psiphonSocksForwarder = socks;
      psiphonHttpForwarder = http;
    },
  );

  Future<ServerSocket?> createForwarder({
    required int publicPort,
    required int internalPort,
    required String label,
    required String source,
  }) => forwarder.createForwarder(
    publicPort: publicPort,
    internalPort: internalPort,
    label: label,
    source: source,
  );

  Future<void> closeAllForwardSockets() async {
    for (final s in List<Socket>.from(activeForwardSockets)) {
      try {
        s.destroy();
      } catch (_) {}
    }
    activeForwardSockets.clear();
  }
}
