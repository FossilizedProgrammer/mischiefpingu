// lib/services/ffvpn/ffvpn_service.dart
//
// پل ارتباطی Dart با باینری ffvpn (پروکسی Firefox VPN) برای دو کار
// غیرتونلی:
//   • --list-countries : فهرست کشورهای خروجی (بدون احراز هویت)
//   • --usage          : مصرف سهمیهٔ پهنای باند ماهانه
//
// خروجی ffvpn با Go `log` روی stderr چاپ می‌شود؛ هر دو استریم خوانده
// و تجزیه می‌شوند.

import 'dart:async';
import 'dart:io';

import '../app_data_service.dart';

enum FfvpnErrorKind {
  /// حساب Firefox اشتراک Mozilla VPN ندارد (HTTP 403).
  notEntitled,

  /// سرویس در منطقهٔ کاربر ارائه نمی‌شود (HTTP 451).
  region,

  /// sessionToken نامعتبر یا منقضی است (HTTP 401).
  badToken,

  /// سهمیهٔ پهنای باند تمام شده است (HTTP 429).
  quota,

  /// باینری ffvpn پیدا نشد.
  binaryMissing,

  /// خطای شبکه/زمان انتظار.
  network,

  /// بقیهٔ خطاها.
  other,
}

class FfvpnException implements Exception {
  final FfvpnErrorKind kind;
  final String detail;
  final int? exitCode;

  const FfvpnException(this.kind, this.detail, {this.exitCode});

  @override
  String toString() => 'FfvpnException($kind): $detail';
}

/// یک کشور خروجی از لیست سرورهای Remote Settings.
class FfvpnCountry {
  final String code;
  final String name;
  final bool locked; // فقط برای کاربران premium باز است
  final int servers;
  final int cities;

  const FfvpnCountry({
    required this.code,
    required this.name,
    required this.locked,
    required this.servers,
    required this.cities,
  });
}

/// مصرف سهمیهٔ پهنای باند از هدرهای X-Quota-* گاردین.
class FfvpnUsage {
  final bool unlimited;
  final int usedBytes;
  final int limitBytes;
  final int remainingBytes;
  final DateTime? reset;

  const FfvpnUsage({
    required this.unlimited,
    required this.usedBytes,
    required this.limitBytes,
    required this.remainingBytes,
    this.reset,
  });

  double? get usedFraction {
    if (unlimited || limitBytes <= 0) return null;
    return (usedBytes / limitBytes).clamp(0.0, 1.0);
  }
}

class FfvpnService {
  FfvpnService._();

  static Future<String?> resolveBinary() =>
      AppDataService.resolveBinaryPath('ffvpn');

  /// فهرست کشورهای خروجی. `includePremium == false` یعنی فقط کشورهای
  /// اشتراک رایگان (--free-only)، مثل پیش‌فرض خود فایرفاکس.
  static Future<List<FfvpnCountry>> listCountries({
    required bool includePremium,
    void Function(String message)? log,
  }) async {
    final args = <String>['--list-countries'];
    if (!includePremium) args.add('--free-only');

    final output = await _run(args, log: log);
    return parseCountriesOutput(output);
  }

  /// مصرف سهمیهٔ پهنای باند. نیازمند sessionToken حساب Firefox.
  static Future<FfvpnUsage> fetchUsage({
    required String sessionToken,
    void Function(String message)? log,
  }) async {
    final output = await _run(
      ['--usage', '--session-token', sessionToken],
      sessionToken: sessionToken,
      log: log,
    );
    final usage = parseUsageOutput(output);
    if (usage == null) {
      throw FfvpnException(
        FfvpnErrorKind.other,
        'Could not parse quota info from ffvpn output',
      );
    }
    return usage;
  }

  // ────────────────────────────────────────────────────────────────
  //  اجرای باینری
  // ────────────────────────────────────────────────────────────────

  static Future<String> _run(
    List<String> args, {
    String? sessionToken,
    void Function(String message)? log,
  }) async {
    final binaryPath = await resolveBinary();
    if (binaryPath == null) {
      throw const FfvpnException(
        FfvpnErrorKind.binaryMissing,
        'ffvpn binary not found',
      );
    }

    // ⚠️ sessionToken معادل کلید حساب است — در لاگ ماسک می‌شود.
    final echo = args
        .map((a) => (sessionToken != null && a == sessionToken) ? '****' : a)
        .join(' ');
    log?.call('ffvpn query: $binaryPath $echo');

    final results = await Process.run(binaryPath, args).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw const FfvpnException(
        FfvpnErrorKind.network,
        'ffvpn timed out after 45s',
      ),
    );

    final stdout = results.stdout.toString();
    final stderr = results.stderr.toString();
    final combined = '$stdout\n$stderr';

    for (final line in combined.split('\n')) {
      final t = line.trim();
      if (t.isNotEmpty) log?.call(t);
    }

    if (results.exitCode != 0) {
      throw FfvpnException(
        classifyError(combined),
        _lastMeaningfulLine(combined),
        exitCode: results.exitCode,
      );
    }
    return combined;
  }

  static FfvpnErrorKind classifyError(String output) {
    if (output.contains('session token rejected') ||
        output.contains('unauthorized') ||
        output.contains('HTTP 401') ||
        output.contains('bad --session-token')) {
      return FfvpnErrorKind.badToken;
    }
    if (output.contains('no VPN entitlement') || output.contains('HTTP 403')) {
      return FfvpnErrorKind.notEntitled;
    }
    if (output.contains('not available in this region') ||
        output.contains('HTTP 451')) {
      return FfvpnErrorKind.region;
    }
    if (output.contains('quota exceeded') || output.contains('HTTP 429')) {
      return FfvpnErrorKind.quota;
    }
    if (output.contains('fetching server list') ||
        output.contains('Failed host lookup') ||
        output.contains('SocketException') ||
        output.contains('HandshakeException') ||
        output.contains('timed out')) {
      return FfvpnErrorKind.network;
    }
    return FfvpnErrorKind.other;
  }

  static String _lastMeaningfulLine(String output) {
    final lines = output
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return lines.isEmpty ? 'unknown ffvpn error' : lines.last;
  }

  // ────────────────────────────────────────────────────────────────
  //  تجزیهٔ خروجی
  //
  //  ⚠️ هر خط با پیشوند زمان Go log (مثل "12:11:35 ") شروع می‌شود،
  //  پس الگوها را بدون لنگر `^` می‌سازیم.
  // ────────────────────────────────────────────────────────────────

  // فرمت چاپ در main.go: `  %-4s %-22s %s, %s%s` با شمارش
  // server/servers و city/cities و پس‌وند اختیاری " (locked)".
  static final RegExp _countryLine = RegExp(
    r'([A-Z]{2,3})\s+(\S.*?)\s{2,}(\d+) servers?, (\d+) cit(?:y|ies)( \(locked\))?\s*$',
  );

  static List<FfvpnCountry> parseCountriesOutput(String output) {
    final byCode = <String, FfvpnCountry>{};
    for (final line in output.split('\n')) {
      final m = _countryLine.firstMatch(line);
      if (m == null) continue;
      final code = m.group(1)!;
      if (code == 'REC') continue; // ردیف Recommended سرور است
      final country = FfvpnCountry(
        code: code,
        name: m.group(2)!.trim(),
        locked: m.group(5) != null,
        servers: int.parse(m.group(3)!),
        cities: int.parse(m.group(4)!),
      );
      final existing = byCode[code];
      if (existing == null) {
        byCode[code] = country;
        continue;
      }
      // یک کد می‌تواند چند ردیف داشته باشد (مثلاً "CatchAll Anycast"
      // برای US) — نام واقعی کشور را نگه می‌داریم و شمارش‌ها را جمع می‌زنیم.
      var name = existing.name;
      if (_isPseudoEntry(name) && !_isPseudoEntry(country.name)) {
        name = country.name;
      }
      byCode[code] = FfvpnCountry(
        code: code,
        name: name,
        locked: existing.locked || country.locked,
        servers: existing.servers + country.servers,
        cities: existing.cities + country.cities,
      );
    }
    final list = byCode.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// ردیف anycast سرور، نه یک کشور واقعی.
  static bool _isPseudoEntry(String name) =>
      name.toLowerCase().contains('anycast');

  static final RegExp _usageUnlimited =
      RegExp(r'Bandwidth:\s*unlimited');

  static final RegExp _usageHuman = RegExp(
    r'Bandwidth:\s*(\d+(?:\.\d+)?) (\w+) of (\d+(?:\.\d+)?) (\w+) used \((\d+)%\), (\d+(?:\.\d+)?) (\w+) left(?: resets (\d{4}-\d{2}-\d{2}))?',
  );

  static final RegExp _usageRaw = RegExp(
    r'Bandwidth:\s*remaining=(\d+) limit=(\d+)(?: resets (\d{4}-\d{2}-\d{2}))?',
  );

  static FfvpnUsage? parseUsageOutput(String output) {
    if (_usageUnlimited.hasMatch(output)) {
      return const FfvpnUsage(
        unlimited: true,
        usedBytes: 0,
        limitBytes: 0,
        remainingBytes: 0,
      );
    }

    final human = _usageHuman.firstMatch(output);
    if (human != null) {
      final resetDate = human.group(8);
      return FfvpnUsage(
        unlimited: false,
        usedBytes: _parseBytes(human.group(1)!, human.group(2)!),
        limitBytes: _parseBytes(human.group(3)!, human.group(4)!),
        remainingBytes: _parseBytes(human.group(6)!, human.group(7)!),
        reset: resetDate == null ? null : DateTime.tryParse(resetDate),
      );
    }

    final raw = _usageRaw.firstMatch(output);
    if (raw != null) {
      final remaining = int.tryParse(raw.group(1)!) ?? 0;
      final limit = int.tryParse(raw.group(2)!) ?? 0;
      final resetDate = raw.group(3);
      return FfvpnUsage(
        unlimited: false,
        usedBytes: (limit - remaining).clamp(0, limit),
        limitBytes: limit,
        remainingBytes: remaining,
        reset: resetDate == null ? null : DateTime.tryParse(resetDate),
      );
    }
    return null;
  }

  static int _parseBytes(String value, String unit) {
    final num = double.tryParse(value);
    if (num == null) return 0;
    const gib = 1024 * 1024 * 1024;
    switch (unit) {
      case 'GiB':
        return (num * gib).round();
      case 'MiB':
        return (num * 1024 * 1024).round();
      case 'KiB':
        return (num * 1024).round();
      default:
        return num.round();
    }
  }

  /// نمایش انسانی بایت‌ها (GiB/MiB/KiB) برای UI سهمیه.
  static String formatBytes(int bytes) {
    const gib = 1024 * 1024 * 1024;
    if (bytes >= gib) return '${(bytes / gib).toStringAsFixed(1)} GiB';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KiB';
    return '$bytes B';
  }
}
