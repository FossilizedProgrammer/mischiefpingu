// lib/services/lantern/lantern_cli_service.dart
//
// اجرای دستورات جانبی باینری لنترن (`servers` ،`update` ،`auth`).
//
// اجرای `start` (تونل اصلی) در ProcessService انجام می‌شود؛ این سرویس فقط
// برای فراخوانی‌های «یک‌بارمصرف» است که خروجی‌شان را برمی‌گردانند:
//   • fetchServers  → `lantern servers [--refresh] [--check] --json`
//   • update        → `lantern update --via …`
//   • auth          → `lantern auth login|signup|logout`

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/settings_model.dart';
import '../app_data_service.dart';
import '../process_service.dart';
import 'lantern_upstream_builder.dart';

/// نتیجهٔ یک فراخوانی یک‌بارمصرف CLI.
class LanternCommandResult {
  final int exitCode;
  final String output;
  final bool timedOut;
  final String? binaryError;

  const LanternCommandResult({
    required this.exitCode,
    required this.output,
    this.timedOut = false,
    this.binaryError,
  });

  bool get ok => binaryError == null && !timedOut && exitCode == 0;

  /// خطوط مفید خروجی (بدون خطوط خالی).
  List<String> get lines => const LineSplitter()
      .convert(output)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

/// یک سرور از `lantern servers --json`.
class LanternServerInfo {
  final String name;
  final String address;
  final String protocol;
  final String countryCode;
  final String country;
  final String city;
  final bool trusted;
  final bool? reachable;

  const LanternServerInfo({
    required this.name,
    required this.address,
    required this.protocol,
    required this.countryCode,
    required this.country,
    required this.city,
    required this.trusted,
    this.reachable,
  });

  factory LanternServerInfo.fromJson(Map<String, dynamic> m) =>
      LanternServerInfo(
        name: (m['name'] ?? '').toString(),
        address: (m['addr'] ?? '').toString(),
        protocol: (m['protocol'] ?? '').toString(),
        countryCode: (m['country_code'] ?? '').toString(),
        country: (m['country'] ?? '').toString(),
        city: (m['city'] ?? '').toString(),
        trusted: m['trusted'] == true,
        reachable: m['reachable'] is bool ? m['reachable'] as bool : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'addr': address,
        'protocol': protocol,
        'country_code': countryCode,
        'country': country,
        'city': city,
        'trusted': trusted,
        if (reachable != null) 'reachable': reachable,
      };

  /// برچسب نمایشی برای dropdown انتخاب سرور (پین کردن).
  String get pinLabel {
    final loc = [countryCode, country, city].where((e) => e.isNotEmpty).join(' · ');
    return loc.isEmpty ? name : '$name — $loc';
  }
}

class LanternCliService {
  LanternCliService({
    required this.settings,
    required this.processService,
  });

  final AppSettings settings;
  final ProcessService processService;

  Future<String?> resolveBinary() =>
      AppDataService.resolveBinaryPath('lantern');

  // ═══════════════════════════════════════════════════════════════
  //  ساخت argv
  // ═══════════════════════════════════════════════════════════════

  /// فلگ‌های سراسری که قبل از زیرفرمان می‌آیند.
  ///
  /// اگر [upstreamUrl] داده نشود، آپ‌استریم از روی تنظیمات اتصال
  /// (`lanternUpstreamType`) خودکار انتخاب می‌شود — همان چیزی که برای
  /// `start` استفاده می‌شود. اگر «بدون آپ‌استریم» انتخاب شده باشد، دستور
  /// مستقیم اجرا می‌شود.
  List<String> globalArgs({String? upstreamUrl}) {
    final args = <String>[];

    // همیشه --raw تا رنگ‌ها/کدهای ANSI در لاگ برنامه پاک بمانند.
    args.add('--raw');

    final upstream = upstreamUrl ?? _configuredUpstreamUrl();
    if (upstream.isNotEmpty) {
      args.addAll(['--upstream-proxy', upstream]);
    }

    return args;
  }

  /// زیرفرمان `start` با تنظیمات فعلی.
  List<String> startArgs({String? upstreamUrl}) {
    return <String>[
      ...globalArgs(upstreamUrl: upstreamUrl),
      'start',
      '--socks-proxy-addr',
      '127.0.0.1:${settings.lanternSocksPort}',
      if (settings.lanternHttpPort > 0) ...[
        '--http-proxy-addr',
        '127.0.0.1:${settings.lanternHttpPort}',
      ],
    ];
  }

  /// زیرفرمان `servers` (لیست سرورها).
  List<String> serversArgs({
    bool refresh = false,
    bool check = false,
    bool json = true,
  }) {
    final args = <String>[...globalArgs(), 'servers'];
    if (refresh) args.add('--refresh');
    if (check) args.add('--check');
    if (json) args.add('--json');
    return args;
  }

  /// زیرفرمان `update` (بروزرسانی لیست سرورهای کش‌شده).
  List<String> updateArgs() {
    return <String>[...globalArgs(), 'update'];
  }

  /// زیرفرمان `auth login|signup|logout`.
  List<String> authArgs(String action, {String? email, String? password}) {
    final args = <String>[...globalArgs(), 'auth', action];
    if (email != null && email.trim().isNotEmpty) {
      args.addAll(['--email', email.trim()]);
    }
    if (password != null && password.isNotEmpty) {
      args.addAll(['--password', password]);
    }
    return args;
  }

  /// argv را برای نمایش در لاگ، بدون اطلاعات حساس می‌کند.
  static String maskArgs(List<String> args) {
    final out = <String>[];
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      if (a == '--password' || a == '--upstream-proxy') {
        out.add(a);
        if (i + 1 < args.length) {
          out.add(
            a == '--password'
                ? '****'
                : LanternUpstreamBuilder.maskCredentials(args[i + 1]),
          );
          i++;
        }
        continue;
      }
      out.add(a);
    }
    return out.join(' ');
  }

  // ═══════════════════════════════════════════════════════════════
  //  اجرا
  // ═══════════════════════════════════════════════════════════════

  /// یک دستور یک‌بارمصرف را اجرا می‌کند؛ خطوط خروجی به [onLine] و لاگ
  /// لنترن فرستاده می‌شوند و خروجی کامل برگردانده می‌شود.
  Future<LanternCommandResult> run(
    List<String> args, {
    Duration timeout = const Duration(minutes: 3),
    bool logOutput = true,
    void Function(String line)? onLine,
  }) async {
    const src = LogSource.lantern;

    final binary = await resolveBinary();
    if (binary == null) {
      final msg = '✗ lantern binary not found. Place "lantern'
          '${AppDataService.exeExt}" in the data folder.';
      if (logOutput) processService.addLog(msg, source: src);
      return LanternCommandResult(
        exitCode: 127,
        output: '',
        binaryError: msg,
      );
    }

    if (logOutput) {
      processService.addLog(
        '→ lantern ${maskArgs(args)}',
        source: src,
      );
    }

    final buffer = StringBuffer();
    try {
      final process = await Process.start(binary, args);
      final done = Completer<void>();

      void handleLine(String raw) {
        final line = sanitizeLine(raw);
        if (line.isEmpty) return;
        buffer.writeln(line);
        onLine?.call(line);
        if (logOutput) processService.addLog(line, source: src);
      }

      process.stdout
          .transform(utf8.decoder)
          .listen((d) => d.split(RegExp(r'[\r\n]+')).forEach(handleLine));
      process.stderr
          .transform(utf8.decoder)
          .listen((d) => d.split(RegExp(r'[\r\n]+')).forEach(handleLine));
      process.exitCode.then((_) {
        if (!done.isCompleted) done.complete();
      });

      var timedOut = false;
      await done.future.timeout(timeout, onTimeout: () {
        timedOut = true;
        try {
          process.kill(ProcessSignal.sigkill);
        } catch (_) {}
      });

      final exitCode = timedOut ? -1 : await process.exitCode;
      if (timedOut && logOutput) {
        processService.addLog(
          '⚠ lantern command timed out after ${timeout.inSeconds}s',
          source: src,
        );
      }
      return LanternCommandResult(
        exitCode: exitCode,
        output: buffer.toString(),
        timedOut: timedOut,
      );
    } catch (e) {
      if (logOutput) {
        processService.addLog('✗ lantern command failed: $e', source: src);
      }
      return LanternCommandResult(exitCode: 1, output: '$e');
    }
  }

  /// لیست سرورها را می‌گیرد و parse می‌کند؛ در صورت خطا null برمی‌گردد.
  Future<List<LanternServerInfo>?> fetchServers({
    bool refresh = false,
    bool check = false,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final result = await run(
      serversArgs(refresh: refresh, check: check),
      timeout: timeout,
    );
    if (!result.ok) return null;
    return parseServersJson(result.output);
  }

  /// JSON خروجی `servers --json` / `update --json` را parse می‌کند.
  ///
  /// بین اولین `[` و آخرین `]` می‌گردد تا خطوط اضافی pterm مزاحم نشوند.
  static List<LanternServerInfo>? parseServersJson(String output) {
    final start = output.indexOf('[');
    final end = output.lastIndexOf(']');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(output.substring(start, end + 1));
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((m) => LanternServerInfo.fromJson(
              Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// آپ‌استریم پیکربندی‌شده برای دستورات جانبی — همان که اتصال از آن
  /// استفاده می‌کند.
  ///
  /// اگر «بدون آپ‌استریم» (`direct`) انتخاب شده باشد رشتهٔ خالی برمی‌گردد.
  /// برای تونل‌های داخلی (Psiphon/Tor/…) فقط وقتی URL برمی‌گردد که تونل
  /// همین الان بالا باشد؛ وگرنه با هشدار مستقیم ادامه می‌دهیم.
  String _configuredUpstreamUrl() {
    final builder = LanternUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    if (!builder.hasUpstream) return '';
    if (!builder.isAvailable) {
      processService.addLog(
        '→ Lantern: upstream ${builder.label} is not running — running the '
        'command without --upstream-proxy',
        source: LogSource.lantern,
      );
      return '';
    }
    return builder.buildUrl();
  }

  /// کدهای ANSI/کنترلی pterm (رنگ، cursor، spinner، OSC) را پاک می‌کند.
  static final RegExp _ansiSeq = RegExp(
    r'\x1B(?:\][^\x07\x1B]*(?:\x07|\x1B\\)|\[[0-9;?]*[ -/]*[@-~]|[= >])',
  );

  static String sanitizeLine(String raw) =>
      raw.replaceAll(_ansiSeq, '').trim();
}
