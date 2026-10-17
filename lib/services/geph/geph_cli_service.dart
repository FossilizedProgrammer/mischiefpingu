// lib/services/geph/geph_cli_service.dart
//
// اجرای دستورات باینری گف (`signup` ،`login` ،`countries` و `run`).
//
// اجرای `run` (تونل اصلی) در ProcessService انجام می‌شود؛ این سرویس ساخت
// argv و فراخوانی‌های «یک‌بارمصرف» را به عهده دارد:
//   • signup       → `geph5-proxy signup`
//   • login        → `geph5-proxy login`
//   • countries    → `geph5-proxy countries [--level …]`
//   • run          → `geph5-proxy run --country …`  (در ProcessService)

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/settings_model.dart';
import '../app_data_service.dart';
import '../process_service.dart';
import 'geph_upstream_builder.dart';

/// نتیجهٔ یک فراخوانی یک‌بارمصرف CLI.
class GephCommandResult {
  final int exitCode;
  final String output;
  final bool timedOut;
  final String? binaryError;

  const GephCommandResult({
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

/// یک کشور از `geph5-proxy countries`.
class GephCountryInfo {
  final String code;
  final String name;
  final int exits;
  final bool free;
  final String cities;

  const GephCountryInfo({
    required this.code,
    required this.name,
    required this.exits,
    required this.free,
    required this.cities,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'exits': exits,
        'free': free,
        'cities': cities,
      };

  factory GephCountryInfo.fromJson(Map<String, dynamic> m) => GephCountryInfo(
        code: (m['code'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        exits: m['exits'] is int ? m['exits'] as int : 0,
        free: m['free'] == true,
        cities: (m['cities'] ?? '').toString(),
      );

  /// برچسب نمایشی برای dropdown انتخاب کشور.
  String get label {
    final suffix = free ? 'free' : 'plus';
    return '$code — $name ($suffix, $exits)';
  }
}

class GephCliService {
  GephCliService({
    required this.settings,
    required this.processService,
  });

  final AppSettings settings;
  final ProcessService processService;

  static const String binaryName = 'geph5-proxy';

  /// نام پوشهٔ دادهٔ گف داخل پوشهٔ دادهٔ برنامه.
  ///
  /// ⚠️ این نام نباید با نام باینری (`geph5-proxy`) یکی باشد: خود باینری
  /// داخل پوشهٔ داده به‌صورت فایلِ `geph5-proxy` قرار می‌گیرد و اگر این
  /// نام هم‌نام باشد، ساخت فایل حساب/کش با خطای `File exists (os error 17)`
  /// (چون والدِ مسیر یک فایل است نه پوشه) شکست می‌خورد.
  static const String dataSubdir = 'geph';

  /// محیط اجرای باینری.
  ///
  /// geph5-proxy پیش‌فرض `geph=debug` است که صدها خط DEBUG در ثانیه می‌دهد
  /// و پنل لاگ را پر می‌کند؛ با `geph=info` فقط رویدادهای مهم می‌مانند.
  /// خطوط وضعیت (`SOCKS5 proxy :` ،`connected :`) چاپ مستقیم‌اند و از
  /// فیلتر رد می‌شوند.
  static const Map<String, String> environment = {'RUST_LOG': 'geph=info'};

  Future<String?> resolveBinary() =>
      AppDataService.resolveBinaryPath(binaryName);

  /// فایلی که کد حساب در آن نگهداری می‌شود — داخل پوشهٔ دادهٔ برنامه تا
  /// هم لو نرود (کنار تنظیمات) و هم با پاک شدن کش سیستم از بین نرود.
  static Future<String> accountFilePath() async {
    final dir = await AppDataService.getDataDir();
    return '$dir/$dataSubdir/account.txt';
  }

  /// مسیر مؤثر فایل کد حساب: مسیر دلخواه کاربر اگر داده شده باشد، وگرنه
  /// مسیر پیش‌فرض داخل پوشهٔ داده.
  static Future<String> resolveAccountFile(AppSettings settings) async {
    final custom = settings.gephAccountFile.trim();
    return custom.isNotEmpty ? custom : accountFilePath();
  }

  /// مسیر مؤثر فایل کد حساب برای تنظیمات فعلی.
  Future<String> resolvedAccountFile() => resolveAccountFile(settings);

  /// آیا منبع کد حساب روی «کد لاگین» است و کدی هم وارد شده؟
  bool get usesLoginCode =>
      settings.gephAccountSource == AppSettings.gephAccountSourceCode &&
      settings.gephAccountCode.trim().isNotEmpty;

  /// کد لاگینی که باید به‌صورت `--secret` فرستاده شود، یا null در حالت فایل.
  String? get _loginSecretOrNull =>
      usesLoginCode ? settings.gephAccountCode.trim() : null;

  /// کش SQLite مربوط به خروجی‌ها — باز هم داخل پوشهٔ دادهٔ برنامه.
  static Future<String> cachePath() async {
    final dir = await AppDataService.getDataDir();
    return '$dir/$dataSubdir/db';
  }

  /// مسیرهایی که پیش از اجرا باید والدشان یک پوشهٔ موجود باشد
  /// (فایل حساب و کش).
  Future<List<String>> writablePaths() async => [
        await resolvedAccountFile(),
        await cachePath(),
      ];

  /// آیا در مسیر داده‌شده کد حسابی ذخیره شده است؟
  static Future<bool> hasAccountAtFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      return (await file.readAsString()).trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// آیا کد حساب برای منبع انتخاب‌شدهٔ فعلی آماده است؟
  ///
  /// در حالت «کد لاگین» کافی است کد در تنظیمات پر باشد؛ در حالت فایل
  /// باید فایل مؤثر وجود داشته باشد و خالی نباشد.
  Future<bool> hasConfiguredAccount() async {
    if (settings.gephAccountSource == AppSettings.gephAccountSourceCode) {
      return settings.gephAccountCode.trim().isNotEmpty;
    }
    return hasAccountAtFile(await resolvedAccountFile());
  }

  /// کد ذخیره‌شده در فایل حساب را می‌خواند (بعد از `signup`).
  Future<String?> readAccountCode() async {
    try {
      final file = File(await resolvedAccountFile());
      if (!await file.exists()) return null;
      final code = (await file.readAsString()).trim();
      return code.isEmpty ? null : code;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  ساخت argv
  // ═══════════════════════════════════════════════════════════════

  /// فلگ‌های سراسری که قبل از زیرفرمان می‌آیند.
  ///
  /// اگر [upstreamUrl] داده نشود، آپ‌استریم از روی تنظیمات اتصال
  /// (`gephUpstreamType`) خودکار انتخاب می‌شود.
  Future<List<String>> globalArgs({String? upstreamUrl}) async {
    final args = <String>[
      '--account-file',
      await resolvedAccountFile(),
    ];

    final upstream = upstreamUrl ?? _configuredUpstreamUrl();
    if (upstream.isNotEmpty) {
      args.addAll(['--upstream', upstream]);
    }

    return args;
  }

  /// زیرفرمان `run` با تنظیمات فعلی.
  Future<List<String>> runArgs({String? upstreamUrl}) async {
    final country = settings.gephCountry.trim();
    final secret = _loginSecretOrNull;
    return <String>[
      ...await globalArgs(upstreamUrl: upstreamUrl),
      'run',
      if (secret != null) ...['--secret', secret],
      '--country',
      country.isEmpty ? 'auto' : country,
      '--socks',
      '${settings.gephSocksPort}',
      if (settings.gephHttpPort > 0) ...[
        '--http',
        '${settings.gephHttpPort}',
      ] else ...[
        '--http',
        'none',
      ],
      if (settings.gephShareLan) '--share-lan',
      '--cache',
      await cachePath(),
    ];
  }

  /// زیرفرمان `countries` (لیست خروجی‌ها).
  Future<List<String>> countriesArgs({String level = 'all'}) async {
    return <String>[
      ...await globalArgs(),
      'countries',
      '--level',
      level,
    ];
  }

  /// زیرفرمان `signup` (ساخت حساب جدید).
  Future<List<String>> signupArgs() async {
    return <String>[...await globalArgs(), 'signup'];
  }

  /// زیرفرمان `login` (اعتبارسنجی کد حساب).
  ///
  /// اگر [secret] داده شود از آن استفاده می‌شود؛ وگرنه در حالت «کد لاگین»
  /// کد تنظیمات و در حالت فایل، خود باینری از فایل می‌خواند.
  Future<List<String>> loginArgs({String? secret}) async {
    final given = secret?.trim();
    final effective =
        (given != null && given.isNotEmpty) ? given : _loginSecretOrNull;
    return <String>[
      ...await globalArgs(),
      'login',
      if (effective != null) ...['--secret', effective],
    ];
  }

  /// argv را برای نمایش در لاگ، بدون اطلاعات حساس می‌کند.
  static String maskArgs(List<String> args) {
    final out = <String>[];
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      if (a == '--secret' || a == '--upstream') {
        out.add(a);
        if (i + 1 < args.length) {
          out.add(
            a == '--secret'
                ? '****'
                : GephUpstreamBuilder.maskCredentials(args[i + 1]),
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
  /// گف فرستاده می‌شوند و خروجی کامل برگردانده می‌شود.
  Future<GephCommandResult> run(
    List<String> args, {
    Duration timeout = const Duration(minutes: 3),
    bool logOutput = true,
    void Function(String line)? onLine,
  }) async {
    const src = LogSource.geph;

    final binary = await resolveBinary();
    if (binary == null) {
      final msg = '✗ geph5-proxy binary not found. Place "geph5-proxy'
          '${AppDataService.exeExt}" in the data folder.';
      if (logOutput) processService.addLog(msg, source: src);
      return GephCommandResult(
        exitCode: 127,
        output: '',
        binaryError: msg,
      );
    }

    if (logOutput) {
      processService.addLog(
        '→ geph5-proxy ${maskArgs(args)}',
        source: src,
      );
    }

    final buffer = StringBuffer();
    try {
      final process = await Process.start(binary, args, environment: environment);
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
          '⚠ geph5-proxy command timed out after ${timeout.inSeconds}s',
          source: src,
        );
      }
      return GephCommandResult(
        exitCode: exitCode,
        output: buffer.toString(),
        timedOut: timedOut,
      );
    } catch (e) {
      if (logOutput) {
        processService.addLog('✗ geph5-proxy command failed: $e', source: src);
      }
      return GephCommandResult(exitCode: 1, output: '$e');
    }
  }

  /// لیست کشورها را می‌گیرد و parse می‌کند؛ در صورت خطا null برمی‌گردد.
  Future<List<GephCountryInfo>?> fetchCountries({
    String level = 'all',
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final result = await run(
      await countriesArgs(level: level),
      timeout: timeout,
    );
    if (!result.ok) return null;
    return parseCountries(result.output);
  }

  /// خروجی متنی `countries` را parse می‌کند.
  ///
  /// هر خط شبیه `NL   Netherlands                3 free   Amsterdam(2)` است؛
  /// چون نام کشور می‌تواند از ستون‌ها جلو بزند، از سمت راست (سطح free/plus
  /// و تعداد) به عقب خوانده می‌شود.
  static List<GephCountryInfo>? parseCountries(String output) {
    final countries = <GephCountryInfo>[];
    final row = RegExp(
      r'^\s*([A-Za-z]{2})\s+(.+?)\s+(\d+)\s+(free|plus)\s*(.*)$',
    );

    for (final raw in const LineSplitter().convert(output)) {
      final line = raw.trimRight();
      if (line.isEmpty) continue;
      final m = row.firstMatch(line);
      if (m == null) continue;
      countries.add(GephCountryInfo(
        code: m.group(1)!.toUpperCase(),
        name: m.group(2)!.trim(),
        exits: int.tryParse(m.group(3)!) ?? 0,
        free: m.group(4) == 'free',
        cities: (m.group(5) ?? '').trim(),
      ));
    }
    return countries.isEmpty ? null : countries;
  }

  /// آپ‌استریم پیکربندی‌شده — همان که اتصال از آن استفاده می‌کند.
  String _configuredUpstreamUrl() {
    final builder = GephUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    if (!builder.hasUpstream) return '';
    if (!builder.isAvailable) {
      processService.addLog(
        '→ Geph: upstream ${builder.label} is not running — running the '
        'command without --upstream',
        source: LogSource.geph,
      );
      return '';
    }
    return builder.buildUrl();
  }

  /// کدهای ANSI/کنترلی خروجی (رنگ، cursor، spinner، OSC) را پاک می‌کند.
  static final RegExp _ansiSeq = RegExp(
    r'\x1B(?:\][^\x07\x1B]*(?:\x07|\x1B\\)|\[[0-9;?]*[ -/]*[@-~]|[= >])',
  );

  static String sanitizeLine(String raw) {
    final line = maskSecretLine(raw.replaceAll(_ansiSeq, '').trim());
    if (_progressTicker.hasMatch(line) && !line.endsWith('100%')) return '';
    return line;
  }

  /// ticker پیشرفت `signup` (`solving...  42%`) که با `\r` بازنویسی می‌شود؛
  /// فقط حالت پایانی نگه داشته می‌شود تا پنل لاگ با صدها خط پر نشود.
  static final RegExp _progressTicker = RegExp(r'^solving\.\.\.\s*\d+%$');

  /// کد حساب (bearer secret) نباید در پنل لاگ پخش شود: signup یک توکن بلند
  /// تنها را در یک خط چاپ می‌کند و آن خط را ماسک می‌کنیم.
  static String maskSecretLine(String line) {
    final t = line.trim();
    if (t.isEmpty) return line;
    if (t.contains(' ') || t.length < 16) return line;
    return line.replaceFirst(t, '****');
  }
}
