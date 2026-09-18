part of 'process_service.dart';

extension ProcessServiceTorLauncher on ProcessService {
  Future<bool> launchTorProcess({
    required String torrcPath,
    required String workDir,
    required Map<String, String>? env,
    required bool shareLan,
    required int socksPort,
    required int httpPort,
    required int internalSocksPort,
    required int internalHttpPort,
  }) async {
    const src = LogSource.tor;

    try {
      final binaryPath =
          await AppDataService.findTorBinary() ??
          await AppDataService.getTorBinaryPath();
      if (!await File(binaryPath).exists()) {
        final torDir = await AppDataService.getTorDir();
        addLog(
          'ERROR: tor binary not found → $binaryPath '
          '(expert bundle installs into $torDir — use Core Updates)',
          source: src,
        );
        return false;
      }

      torProcess = await Process.start(
        binaryPath,
        ['-f', torrcPath],
        workingDirectory: workDir,
        mode: ProcessStartMode.normal,
        environment: env,
      );
      await Future.delayed(const Duration(milliseconds: 900));

      bool exitedQuickly = false;
      try {
        final code = await torProcess!.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('Tor exited immediately with code $code', source: src);
      } catch (_) {
        exitedQuickly = false;
      }
      if (exitedQuickly) {
        isTorRunning = false;
        torProcess = null;
        touch();
        return false;
      }

      isTorRunning = true;
      isTorConnected = false;
      torBootstrapProgress = 0;
      addLog('Tor is running (PID: ${torProcess!.pid})', source: src);
      touch();

      if (shareLan) {
        torSocksForwarder = await createForwarder(
          publicPort: socksPort,
          internalPort: internalSocksPort,
          label: 'Tor-SOCKS',
          source: src,
        );
        torHttpForwarder = await createForwarder(
          publicPort: httpPort,
          internalPort: internalHttpPort,
          label: 'Tor-HTTP',
          source: src,
        );
      }

      _attachTorListeners();
      return true;
    } catch (e) {
      addLog('Failed to start Tor: $e', source: LogSource.tor);
      isTorRunning = false;
      touch();
      return false;
    }
  }

  void _attachTorListeners() {
    const src = LogSource.tor;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final bootstrapMatch = RegExp(r'Bootstrapped (\d+)%').firstMatch(trimmed);
      if (bootstrapMatch != null) {
        final progress = int.tryParse(bootstrapMatch.group(1) ?? '0') ?? 0;
        if (progress != torBootstrapProgress) {
          torBootstrapProgress = progress;
          touch();
        }
      }

      if (trimmed.contains('Bootstrapped 100%')) {
        final wasConnected = isTorConnected;
        isTorConnected = true;
        torBootstrapProgress = 100;

        if (pendingTorTransportType != null) {
          setTorNotification(
            pendingTorTransportType!,
            pendingTorTransportDetailPrepared ?? '',
          );
        }

        checkHappyTransition(
          tunnelName: 'Tor',
          wasConnected: wasConnected,
          isConnected: true,
        );

        touch();
      }
    }

    torProcess!.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });
    torProcess!.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });

    torProcess!.exitCode.then((code) {
      final wasConnected = isTorConnected;
      isTorRunning = false;
      isTorConnected = false;
      torBootstrapProgress = 0;
      pendingTorTransportType = null;
      pendingTorTransportDetailPrepared = null;
      torProcess = null;

      checkHappyTransition(
        tunnelName: 'Tor',
        wasConnected: wasConnected,
        isConnected: false,
      );

      addLog('Tor exited with code $code', source: src);
      touch();
    });
  }
}
