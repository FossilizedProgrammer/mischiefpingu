library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  CumulusLocations — خروجی `cumulusvpn list --locations --json`.
///
///  هر ردیف یک شهر/لوکیشن است که ممکن است چند گیت‌وی داشته باشد.
///  `loadPct` بار بهترین گیت‌وی همان لوکیشن است و `id` را می‌توان
///  مستقیم به `--country` داد (`US:New York`).
/// ═══════════════════════════════════════════════════════════════
class CumulusLocation {
  final String id;
  final String code;
  final String name;
  final String city;
  final int nodes;
  final int loadPct;
  final String tone;
  final int? latencyMs;

  const CumulusLocation({
    required this.id,
    required this.code,
    required this.name,
    required this.city,
    required this.nodes,
    required this.loadPct,
    required this.tone,
    required this.latencyMs,
  });

  String get label => city.isEmpty ? name : '$name · $city';

  /// ایموجی پرچم از کد دوحرفی؛ اگر کد نامعتبر بود پرچم خنثی.
  String get flag {
    final cc = code.toUpperCase();
    if (cc.length != 2 ||
        cc.codeUnitAt(0) < 65 ||
        cc.codeUnitAt(0) > 90 ||
        cc.codeUnitAt(1) < 65 ||
        cc.codeUnitAt(1) > 90) {
      return '🏳️';
    }
    return String.fromCharCodes([
      0x1F1E6 + cc.codeUnitAt(0) - 65,
      0x1F1E6 + cc.codeUnitAt(1) - 65,
    ]);
  }

  factory CumulusLocation.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] as String? ?? '').toUpperCase();
    final city = json['city'] as String? ?? '';
    final fallbackId = city.isEmpty ? code : '$code:$city';
    return CumulusLocation(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? (json['id'] as String).trim()
          : fallbackId,
      code: code,
      name: json['name'] as String? ?? code,
      city: city,
      nodes: (json['nodes'] as num?)?.toInt() ?? 1,
      loadPct: ((json['loadPct'] as num?)?.toInt() ?? 0).clamp(0, 100),
      tone: json['tone'] as String? ?? 'fair',
      latencyMs: (json['latencyMs'] as num?)?.toInt(),
    );
  }
}

class CumulusLocations {
  CumulusLocations._();

  /// لیست لوکیشن‌ها را با همان کانفیگ ایزولهٔ خود اپ می‌گیرد.
  ///
  /// عمداً `--no-latency` می‌زنیم: کاربر بار سرور را می‌خواهد و اندازه‌گیری
  /// ping همهٔ گیت‌وی‌ها می‌تواند خیلی طول بکشد. discovery خودش ممکن است
  /// چند ثانیه طول بکشد، پس timeout سخاوتمندانه است.
  static Future<List<CumulusLocation>> fetch({
    required String binaryPath,
    required String configHome,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    await Directory(configHome).create(recursive: true);

    final process = await Process.start(
      binaryPath,
      const ['list', '--locations', '--json', '--no-latency'],
      workingDirectory: configHome,
      environment: {
        if (Platform.isWindows)
          'APPDATA': configHome
        else
          'XDG_CONFIG_HOME': configHome,
      },
      includeParentEnvironment: true,
    );

    // خواندن همزمان stdout/stderr تا pipe پر نشود؛ بعد منتظر خروج می‌مانیم.
    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();

    int exitCode;
    try {
      exitCode = await process.exitCode.timeout(timeout);
    } on TimeoutException {
      process.kill();
      throw const CumulusLocationException('Server discovery timed out');
    }

    final stdoutText = await stdoutFuture;
    final stderr = (await stderrFuture).trim();

    if (exitCode != 0) {
      final line = stderr.isEmpty ? '' : stderr.split('\n').last.trim();
      throw CumulusLocationException(
        line.isEmpty ? 'cumulusvpn list exited with code $exitCode' : line,
      );
    }

    final raw = jsonDecode(stdoutText);
    if (raw is! List) {
      throw const CumulusLocationException('Unexpected server list response');
    }

    final locations = raw
        .whereType<Map<String, dynamic>>()
        .map(CumulusLocation.fromJson)
        .toList();

    // کم‌بارترین‌ها اول؛ نام و شهر فقط برای ترتیب پایدار.
    locations.sort((a, b) {
      final byLoad = a.loadPct.compareTo(b.loadPct);
      if (byLoad != 0) return byLoad;
      final byName = a.name.compareTo(b.name);
      if (byName != 0) return byName;
      return a.city.compareTo(b.city);
    });
    return locations;
  }
}

class CumulusLocationException implements Exception {
  final String message;

  const CumulusLocationException(this.message);

  @override
  String toString() => message;
}
