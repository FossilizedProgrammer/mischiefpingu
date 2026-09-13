import 'dart:async';
import 'dart:io';
import 'dart:math';

class CdnCheckResult {
  final String ip;
  final bool ok;
  final int latencyMs;
  final int reliability;
  final String sni;
  final String message;
  final double score;

  CdnCheckResult({
    required this.ip,
    required this.ok,
    required this.latencyMs,
    this.reliability = 0,
    required this.sni,
    required this.message,
    required this.score,
  });
}

class CdnIpChecker {
  Future<SecureSocket?> _connectTls(
    String ip,
    String sni, {
    Duration timeout = const Duration(milliseconds: 3000),
  }) async {
    Socket? raw;
    try {
      raw = await Socket.connect(ip, 443, timeout: timeout);
      final secure = await SecureSocket.secure(
        raw,
        host: sni,
        onBadCertificate: (_) => true,
      );
      return secure;
    } catch (_) {
      try {
        await raw?.close();
      } catch (_) {}
      return null;
    }
  }

  Future<({bool ok, int ms})> tlsOnce(
    String ip,
    String sni, {
    Duration timeout = const Duration(milliseconds: 3000),
  }) async {
    final sw = Stopwatch()..start();
    SecureSocket? sock;
    try {
      sock = await _connectTls(ip, sni, timeout: timeout);
      if (sock == null) {
        sw.stop();
        return (ok: false, ms: sw.elapsedMilliseconds);
      }
      sock.write(
        'HEAD / HTTP/1.1\r\n'
        'Host: $sni\r\n'
        'User-Agent: Mozilla/5.0\r\n'
        'Connection: close\r\n'
        '\r\n',
      );
      await sock.flush();
      try {
        await sock.timeout(const Duration(seconds: 2)).first;
      } catch (_) {}
      sw.stop();
      return (ok: true, ms: sw.elapsedMilliseconds);
    } catch (_) {
      sw.stop();
      return (ok: false, ms: sw.elapsedMilliseconds);
    } finally {
      try {
        await sock?.close();
      } catch (_) {}
    }
  }

  Future<({bool reliable, int success, int avgMs})> reliability(
    String ip,
    String sni, {
    int tries = 5,
    int minOk = 3,
  }) async {
    var success = 0;
    final lats = <int>[];
    for (var i = 0; i < tries; i++) {
      final r = await tlsOnce(ip, sni);
      if (r.ok) {
        success++;
        lats.add(r.ms);
      }
      await Future.delayed(const Duration(milliseconds: 80));
    }
    final avg = lats.isEmpty
        ? 9999
        : (lats.reduce((a, b) => a + b) / lats.length).round();
    return (reliable: success >= minOk, success: success, avgMs: avg);
  }

  double score({required int latencyMs, required int reliabilitySuccess}) {
    final l = max(0.0, 1 - latencyMs / 600.0) * 60;
    final rel = (reliabilitySuccess / 5.0) * 40;
    return double.parse((l + rel).toStringAsFixed(1));
  }

  Future<CdnCheckResult> checkFull(String ip, List<String> snis) async {
    String? goodSni;
    int bestLat = 9999;
    for (final sni in snis) {
      final r = await tlsOnce(ip, sni);
      if (r.ok) {
        goodSni = sni;
        bestLat = r.ms;
        break;
      }
    }
    if (goodSni == null) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: bestLat,
        sni: snis.isNotEmpty ? snis.first : '',
        message: 'tls fail',
        score: 0,
      );
    }
    final rel = await reliability(ip, goodSni);
    if (!rel.reliable) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: rel.avgMs,
        reliability: rel.success,
        sni: goodSni,
        message: 'unstable ${rel.success}/5',
        score: 0,
      );
    }
    final sc = score(latencyMs: rel.avgMs, reliabilitySuccess: rel.success);
    return CdnCheckResult(
      ip: ip,
      ok: true,
      latencyMs: rel.avgMs,
      reliability: rel.success,
      sni: goodSni,
      message: 'good',
      score: sc,
    );
  }
}
