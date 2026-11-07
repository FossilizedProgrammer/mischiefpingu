import 'dart:async';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  CdnSniScout — پیدا کردن SNIهایی که در شبکه فعلی کار می‌کنند
///
///  ⚠️ چرا این فایل لازمه؟
///  در ایران یه سری SNI فیلترن (مثل discord.com، reddit.com).
///  اگه اسکنر بخواد با این SNIها IP تست کنه، همه IPها به اشتباه
///  "مرده" تشخیص داده می‌شن. این scout اول یه IP مطمئن رو با
///  همه SNIهای کاندید تست می‌کنه و فقط اونایی که TLS handshake
///  موفق دارن رو برمی‌گردونه.
/// ═══════════════════════════════════════════════════════════════

/// نوع خروجی scout — به صورت typedef جدا برای جلوگیری از
/// خطای type inference در Dart
typedef ScoutedSni = ({String sni, int ms});

/// نتیجه scout
typedef ScoutResult = ({List<ScoutedSni> working, String? error});

class CdnSniScout {
  /// IPهای معیار برای تست SNI در Cloudflare
  static const List<String> _cloudflareTestIps = [
    '1.1.1.1',
    '1.0.0.1',
  ];

  /// IPهای معیار برای تست SNI در Google
  static const List<String> _googleTestIps = [
    '8.8.8.8',
    '8.8.4.4',
    '142.250.185.78',
  ];

  /// IPهای معیار برای تست SNI در Akamai
  static const List<String> _akamaiTestIps = [
    '23.215.0.206',
    '23.215.0.203',
  ];

  /// IPهای معیار برای Azure
  static const List<String> _azureTestIps = [
    '13.107.4.13',
    '20.190.160.14',
  ];

  /// IPهای معیار برای Amazon
  static const List<String> _amazonTestIps = [
    '13.32.0.32',
    '52.46.0.32',
  ];

  /// لیست گسترده SNIهای کاندید برای Cloudflare
  static const List<String> _cloudflareCandidates = [
    'www.cloudflare.com',
    'cloudflare.com',
    '1.1.1.1',
    'one.one.one.one',
    'developers.cloudflare.com',
    'blog.cloudflare.com',
    'support.cloudflare.com',
    'www.digitalocean.com',
    'www.upwork.com',
    'www.namecheap.com',
    'www.udemy.com',
    'medium.com',
    'www.medium.com',
    'www.notion.so',
    'www.zoom.us',
  ];

  static const List<String> _googleCandidates = [
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'ajax.googleapis.com',
    'ssl.gstatic.com',
    'www.gstatic.com',
    'storage.googleapis.com',
    'accounts.google.com',
    'www.google.com',
  ];

  static const List<String> _akamaiCandidates = [
    'a248.e.akamai.net',
    'a.akamaihd.net',
    'a.akamaized.net',
    'www.akamai.com',
    'ds-aksb.akamaized.net',
    'ak.net.akamaized.net',
  ];

  static const List<String> _azureCandidates = [
    'www.microsoft.com',
    'ajax.aspnetcdn.com',
    'cdn.office.net',
    'static.azureedge.net',
    'login.microsoftonline.com',
    'az416426.vo.msecnd.net',
  ];

  static const List<String> _amazonCandidates = [
    'd1.cloudfront.net',
    'd2.cloudfront.net',
    'd3.cloudfront.net',
    'aws.cloudfront.net',
    's3.amazonaws.com',
  ];

  /// ═══════════════════════════════════════════════════════════
  ///  تست سریع یک SNI روی یک IP
  /// ═══════════════════════════════════════════════════════════
  Future<({bool ok, int ms, String error})> testSni(
    String ip,
    String sni, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final sw = Stopwatch()..start();
    Socket? raw;
    SecureSocket? secure;

    try {
      raw = await Socket.connect(ip, 443, timeout: timeout);
      raw.setOption(SocketOption.tcpNoDelay, true);

      try {
        secure = await SecureSocket.secure(
          raw,
          host: sni,
          onBadCertificate: (_) => true,
          supportedProtocols: const ['http/1.1'],
        ).timeout(timeout);
      } on HandshakeException catch (e) {
        sw.stop();
        final msg = e.message.length > 50
            ? '${e.message.substring(0, 50)}…'
            : e.message;
        return (ok: false, ms: sw.elapsedMilliseconds, error: msg);
      } on TlsException catch (e) {
        sw.stop();
        final msg = e.message.length > 50
            ? '${e.message.substring(0, 50)}…'
            : e.message;
        return (ok: false, ms: sw.elapsedMilliseconds, error: msg);
      }

      secure.write('HEAD / HTTP/1.1\r\nHost: $sni\r\nConnection: close\r\n\r\n');
      await secure.flush();

      bool gotData = false;
      try {
        await secure.timeout(const Duration(seconds: 3)).first;
        gotData = true;
      } catch (_) {}

      sw.stop();

      if (!gotData) {
        return (ok: false, ms: sw.elapsedMilliseconds, error: 'no response');
      }

      return (ok: true, ms: sw.elapsedMilliseconds, error: '');
    } catch (e) {
      sw.stop();
      final s = e.toString();
      return (
        ok: false,
        ms: sw.elapsedMilliseconds,
        error: s.length > 50 ? '${s.substring(0, 50)}…' : s,
      );
    } finally {
      try {
        await secure?.close();
      } catch (_) {}
      try {
        raw?.destroy();
      } catch (_) {}
    }
  }

  /// ═══════════════════════════════════════════════════════════
  ///  Scout برای یک CDN — SNIهای سالم رو برمی‌گردونه
  ///
  ///  ⚠️ رفع خطای type inference:
  ///  از typedef `ScoutedSni` و `ScoutResult` استفاده می‌کنیم
  ///  و لیست‌های خالی رو با type صریح `<ScoutedSni>[]` می‌سازیم.
  /// ═══════════════════════════════════════════════════════════
  Future<ScoutResult> scoutFor({
    required String cdnId,
    int concurrency = 5,
    void Function(int done, int total)? onProgress,
  }) async {
    final testIps = _testIpsFor(cdnId);
    final candidates = _candidatesFor(cdnId);

    if (testIps.isEmpty || candidates.isEmpty) {
      return (
        working: <ScoutedSni>[],
        error: 'unknown CDN id: $cdnId',
      );
    }

    // ─── مرحله ۱: پیدا کردن یه IP معیار که باز باشه ───
    String? testIp;
    for (final ip in testIps) {
      final r = await testSni(ip, candidates.first);
      if (r.ok) {
        testIp = ip;
        break;
      }
      for (final sni in candidates.skip(1).take(3)) {
        final r2 = await testSni(ip, sni);
        if (r2.ok) {
          testIp = ip;
          break;
        }
      }
      if (testIp != null) break;
    }

    if (testIp == null) {
      return (
        working: <ScoutedSni>[],
        error: 'No test IP reachable for $cdnId '
            '(network issue or ISP blocking)',
      );
    }

    // ─── مرحله ۲: تست همه SNIها روی IP معیار ───
    final results = <ScoutedSni>[];
    final queue = List<String>.from(candidates);
    var next = 0;
    var done = 0;
    final total = queue.length;
    final resolvedIp = testIp; // برای closure

    Future<String?> takeNext() async {
      if (next >= queue.length) return null;
      return queue[next++];
    }

    Future<void> worker() async {
      while (true) {
        final sni = await takeNext();
        if (sni == null) return;

        final r = await testSni(resolvedIp, sni);
        if (r.ok) {
          results.add((sni: sni, ms: r.ms));
        }
        done++;
        onProgress?.call(done, total);

        await Future.delayed(const Duration(milliseconds: 80));
      }
    }

    final n = concurrency.clamp(1, 10);
    await Future.wait(List.generate(n, (_) => worker()));

    results.sort((a, b) => a.ms.compareTo(b.ms));
    return (working: results, error: null);
  }

  /// IPهای معیار بر اساس CDN
  List<String> _testIpsFor(String cdnId) {
    switch (cdnId) {
      case 'cloudflare':
        return _cloudflareTestIps;
      case 'google':
        return _googleTestIps;
      case 'akamai':
        return _akamaiTestIps;
      case 'azure':
        return _azureTestIps;
      case 'amazon':
        return _amazonTestIps;
      default:
        return _cloudflareTestIps;
    }
  }

  /// SNIهای کاندید بر اساس CDN
  List<String> _candidatesFor(String cdnId) {
    switch (cdnId) {
      case 'cloudflare':
        return _cloudflareCandidates;
      case 'google':
        return _googleCandidates;
      case 'akamai':
        return _akamaiCandidates;
      case 'azure':
        return _azureCandidates;
      case 'amazon':
        return _amazonCandidates;
      default:
        return _cloudflareCandidates;
    }
  }
}
