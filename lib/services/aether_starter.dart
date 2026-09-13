// lib/services/aether_starter.dart
part of 'process_service.dart';

/// forwarder SOCKS مخصوص Aether در حالت Share-on-LAN
ServerSocket? _aetherSocksForwarder;

extension ProcessServiceAetherStarter on ProcessService {
  Future<bool> startAether(List<String> args) async {
    await ensureInitialized();
    if (isAetherRunning) return false;
    const src = LogSource.aether;

    try {
      final dataDir = await AppDataService.getDataDir();
      final binaryPath = await AppDataService.getBinaryPath('aether');

      if (!await checkBinaryExists(
        binaryPath: binaryPath,
        source: src,
        customMessage:
            'Aether binary not found. Please click "Show more" and download it from "Core Updates".',
      )) {
        return false;
      }

      final effectiveArgs = List<String>.from(args);
      final bindInfo = parseAetherBindArgs(effectiveArgs, (m) {
        addLog('ERROR: $m', source: src);
      });
      if (bindInfo == null) return false;

      final prepared = await prepareAetherArgs(
        effectiveArgs: effectiveArgs,
        info: bindInfo,
      );

      addLog('Starting Aether with args: ${prepared.args}', source: src);
      final proc = await spawnAndVerify(
        binaryPath: binaryPath,
        args: prepared.args,
        workingDirectory: dataDir,
        source: src,
        label: 'Aether',
        startupGrace: const Duration(milliseconds: 900),
      );
      if (proc == null) return false;

      aetherProcess = proc;
      isAetherRunning = true;
      addLog('Aether is running (PID: ${proc.pid})', source: src);

      // ─── forwarder برای LAN ───
      if (bindInfo.shareLan &&
          prepared.publicPort != null &&
          prepared.internalPort != null) {
        _aetherSocksForwarder = await setupAetherLanForwarder(
          publicPort: prepared.publicPort!,
          internalPort: prepared.internalPort!,
        );
        if (_aetherSocksForwarder == null) {
          addLog(
            '✗ Aether Share on LAN could not bind public port ${prepared.publicPort}',
            source: src,
          );
          await killProcessSafely(proc, graceMs: 500);
          aetherProcess = null;
          isAetherRunning = false;
          touch();
          return false;
        }
      }

      if (bindInfo.shareLan && prepared.publicPort != null) {
        addLog(
          '→ Share on LAN: SOCKS available on 0.0.0.0:${prepared.publicPort}',
          source: src,
        );
      } else if (prepared.internalPort != null) {
        addLog(
          '→ Aether SOCKS listening on 127.0.0.1:${prepared.internalPort}',
          source: src,
        );
      }
      touch();

      // ─── listenerها ───
      attachProcessListeners(
        process: proc,
        handleLine: (line) {
          if (line.isNotEmpty) addLog(line, source: src);
        },
      );

      proc.exitCode.then((code) async {
        try {
          await _aetherSocksForwarder?.close();
        } catch (_) {}
        _aetherSocksForwarder = null;
        isAetherRunning = false;
        aetherProcess = null;
        addLog('Aether exited with code $code', source: src);
        touch();
      });

      return true;
    } catch (e) {
      try {
        await _aetherSocksForwarder?.close();
      } catch (_) {}
      _aetherSocksForwarder = null;
      await killProcessSafely(aetherProcess);
      aetherProcess = null;
      isAetherRunning = false;
      addLog('Failed to start Aether: $e', source: src);
      touch();
      return false;
    }
  }
}
