library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'tls_client_hello_builder.dart';

enum SstpProbeKind { gotData, stillOpen, closed, error }

class SstpProbeOutcome {
  final SstpProbeKind kind;
  final int dataLength;
  final Object? error;

  const SstpProbeOutcome._(this.kind, {this.dataLength = 0, this.error});

  factory SstpProbeOutcome.gotData(int length) =>
      SstpProbeOutcome._(SstpProbeKind.gotData, dataLength: length);
  factory SstpProbeOutcome.stillOpen() =>
      const SstpProbeOutcome._(SstpProbeKind.stillOpen);
  factory SstpProbeOutcome.closed() =>
      const SstpProbeOutcome._(SstpProbeKind.closed);
  factory SstpProbeOutcome.error(Object e) =>
      SstpProbeOutcome._(SstpProbeKind.error, error: e);
}

class SstpTlsProbe {
  static const Duration firstByteTimeout = Duration(seconds: 4);

  /// ارسال ClientHello به سوکت و انتظار برای پاسخ.
  static Future<SstpProbeOutcome> sendClientHello(Socket sock) async {
    try {
      sock.add(TlsClientHelloBuilder.build());
      await sock.flush();
    } catch (e) {
      return SstpProbeOutcome.error(e);
    }

    final completer = Completer<SstpProbeOutcome>();
    StreamSubscription<Uint8List>? sub;
    Timer? timer;

    void finish(SstpProbeOutcome outcome) {
      if (completer.isCompleted) return;
      completer.complete(outcome);
    }

    try {
      sub = sock.listen(
        (data) {
          if (data.isNotEmpty) finish(SstpProbeOutcome.gotData(data.length));
        },
        onError: (Object e) => finish(SstpProbeOutcome.error(e)),
        onDone: () => finish(SstpProbeOutcome.closed()),
        cancelOnError: true,
      );

      timer = Timer(firstByteTimeout, () {
        finish(SstpProbeOutcome.stillOpen());
      });

      return await completer.future;
    } finally {
      timer?.cancel();
      try {
        await sub?.cancel();
      } catch (_) {}
    }
  }
}
