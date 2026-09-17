import 'dart:async';
import 'dart:io';

/// سوکت‌های فعال forward (برای بستن در زمان shutdown).
final List<Socket> activeForwardSockets = [];

/// forwarderهای محلی برای Share-on-LAN.
class ProcessForwarder {
  final void Function(String message, {String source}) addLog;

  ProcessForwarder({required this.addLog});

  Future<void> startDartLanForwarders({
    required int publicSocksPort,
    required int publicHttpPort,
    required int internalSocksPort,
    required int internalHttpPort,
    required String source,
    required void Function(ServerSocket? socks, ServerSocket? http) onReady,
  }) async {
    try {
      final socks = await createForwarder(
        publicPort: publicSocksPort,
        internalPort: internalSocksPort,
        label: 'SOCKS',
        source: source,
      );
      final http = await createForwarder(
        publicPort: publicHttpPort,
        internalPort: internalHttpPort,
        label: 'HTTP',
        source: source,
      );
      onReady(socks, http);
    } catch (e) {
      addLog('⚠ Failed to start Dart LAN forwarders: $e', source: source);
    }
  }

  Future<ServerSocket?> createForwarder({
    required int publicPort,
    required int internalPort,
    required String label,
    required String source,
  }) async {
    try {
      final server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        publicPort,
      );
      addLog(
        '★ Dart forwarder: $label $publicPort → 127.0.0.1:$internalPort (LAN ready)',
        source: source,
      );
      server.listen((client) async {
        Socket? target;
        try {
          target = await Socket.connect(
            '127.0.0.1',
            internalPort,
            timeout: const Duration(seconds: 5),
          );
          activeForwardSockets.add(client);
          activeForwardSockets.add(target);
          client.listen(
            (data) {
              try {
                target?.add(data);
              } catch (_) {
                _closePair(client, target);
              }
            },
            onError: (_) => _closePair(client, target),
            onDone: () => _closePair(client, target),
            cancelOnError: true,
          );
          target.listen(
            (data) {
              try {
                client.add(data);
              } catch (_) {
                _closePair(client, target);
              }
            },
            onError: (_) => _closePair(client, target),
            onDone: () => _closePair(client, target),
            cancelOnError: true,
          );
        } catch (e) {
          addLog('⚠ Forward $label connection failed: $e', source: source);
          try {
            await client.close();
          } catch (_) {}
          try {
            await target?.close();
          } catch (_) {}
        }
      });
      return server;
    } catch (e) {
      addLog('⚠ Cannot bind Dart forwarder on $publicPort ($label): $e',
          source: source);
      return null;
    }
  }

  void _closePair(Socket? a, Socket? b) {
    try {
      a?.destroy();
    } catch (_) {}
    try {
      b?.destroy();
    } catch (_) {}
    activeForwardSockets.remove(a);
    activeForwardSockets.remove(b);
  }

  /// بستن همهٔ socketهای forward فعال.
  Future<void> closeAllForwardSockets() async {
    for (final s in List<Socket>.from(activeForwardSockets)) {
      try {
        s.destroy();
      } catch (_) {}
    }
    activeForwardSockets.clear();
  }
}
