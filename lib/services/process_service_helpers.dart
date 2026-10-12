part of 'process_service.dart';

extension ProcessServiceHelpers on ProcessService {
  Future<bool> checkBinaryExists({
    required String binaryPath,
    required String source,
    String? customMessage,
  }) async {
    try {
      if (await File(binaryPath).exists()) return true;
      final msg = customMessage ??
          'Binary not found. Please click "Show more" and download it from "Core Updates".';
      setBinaryMissingMessage(msg);
      addLog('✗ Binary missing: $binaryPath', source: source);
      return false;
    } catch (e) {
      addLog('✗ Error checking binary: $e', source: source);
      return false;
    }
  }

  Future<bool> checkPortAvailable({
    required int port,
    required String label,
    required String appLabel,
    required String source,
  }) async {
    if (!await ProcessService.isPortInUse(port)) return true;
    final msg =
        '$appLabel: $label port $port is already in use by another application. Cannot start.';
    setPortConflictMessage(msg);
    addLog(
      '✗ $label port $port is in use — $appLabel not started',
      source: source,
    );
    return false;
  }

  Future<Process?> spawnAndVerify({
    required String binaryPath,
    required List<String> args,
    required String workingDirectory,
    required String source,
    required String label,
    Map<String, String>? env,
    Duration startupGrace = const Duration(milliseconds: 700),
  }) async {
    try {
      // Process.start replaces the whole environment when `environment` is
      // non-null — merge so PATH/HOME/certs (and PT helpers) stay intact.
      final mergedEnv = env == null
          ? null
          : <String, String>{...Platform.environment, ...env};
      final proc = await Process.start(
        binaryPath,
        args,
        workingDirectory: workingDirectory,
        mode: ProcessStartMode.normal,
        environment: mergedEnv,
      );
      await Future.delayed(startupGrace);

      try {
        final code = await proc.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        addLog('$label exited immediately with code $code', source: source);
        // خروجی واقعی (مثلاً «unknown option '--api-fragment'») را بخوان تا
        // دلیل شکست در لاگ دیده شود؛ وگرنه فقط کد exit می‌ماند.
        final detail = await _readExitDetail(proc);
        if (detail.isNotEmpty) {
          addLog('  $detail', source: source);
        }
        return null;
      } catch (_) {
        return proc;
      }
    } catch (e) {
      addLog('Failed to start $label: $e', source: source);
      return null;
    }
  }

  /// خواندن stdout+stderr پروسه‌ای که همین حالا exit کرده (با timeout
  /// کوتاه چون پروسه دیگر زنده نیست و streamها به‌زودی بسته می‌شوند).
  Future<String> _readExitDetail(Process proc) async {
    Future<String> read(Stream<List<int>> stream) => stream
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 2), onTimeout: () => '');

    try {
      final parts = await Future.wait([read(proc.stdout), read(proc.stderr)]);
      final text = '${parts[0]}\n${parts[1]}'.trim();
      if (text.isEmpty) return '';
      // پروسه‌ها هنگام خطای فلگ کل help را چاپ می‌کنند؛ فقط اولین خط را نگه دار.
      final firstLine = text
          .split('\n')
          .map((l) => l.trim())
          .firstWhere((l) => l.isNotEmpty, orElse: () => '');
      return firstLine.length > 300
          ? '${firstLine.substring(0, 300)}…'
          : firstLine;
    } catch (_) {
      return '';
    }
  }

  void attachProcessListeners({
    required Process process,
    required void Function(String line) handleLine,
  }) {
    process.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });
  }

  Future<void> killProcessSafely(Process? proc, {int graceMs = 700}) async {
    if (proc == null) return;
    try {
      proc.kill(ProcessSignal.sigterm);
      await Future.delayed(Duration(milliseconds: graceMs));
      proc.kill(ProcessSignal.sigkill);
    } catch (_) {}
  }
}
