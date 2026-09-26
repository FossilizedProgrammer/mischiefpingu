part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  آماده‌سازی config برای Tor.
///
///  این تابع:
///    • data dir و tor dir رو آماده می‌کنه
///    • internal portها رو انتخاب می‌کنه (اگه Share on LAN فعال باشه)
///    • assetهای Tor (lyrebird, conjure, geoip) رو پیدا می‌کنه
///    • torrc رو build و ذخیره می‌کنه
///
///  خروجی:
///    • `null` یعنی user در طول کار cancel کرد — caller باید
///      بلافاصله return کنه
///    • رکورد args + torrc path + work dir + env + internal ports
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorLaunchPrepare on AppProvider {
  Future<
      ({
        String torrcPath,
        String workDir,
        Map<String, String>? env,
        int internalSocks,
        int internalHttp,
      })?> _prepareTorConfig(String src) async {
    try {
      // ─── data dir + tor dir ───
      final dataDir = await AppDataService.getDataDir();
      final torDir = await AppDataService.ensureTorDir();
      final torDataDir = '$torDir/tordata';
      await Directory(torDataDir).create(recursive: true);

      if (userStoppedTor) {
        _logTorCancel(src, 'after ensureTorDir');
        return null;
      }

      // ─── internal ports ───
      var internalSocks = settings.torSocksPort;
      var internalHttp = settings.torHttpPort;
      if (settings.torShareLan) {
        internalSocks = await pickInternalPort(settings.torSocksPort);
        internalHttp = await pickInternalPort(settings.torHttpPort);
      }

      // ─── assets ───
      final assets = await resolveTorAssets(dataDir: dataDir, torDir: torDir);

      if (userStoppedTor) {
        _logTorCancel(src, 'after resolveTorAssets');
        return null;
      }

      // ─── build torrc ───
      final builder = TorConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final res = builder.build(
        socksPort: internalSocks,
        httpPort: internalHttp,
        torDataDir: torDataDir,
        geoipPath: assets.geoipPath,
        geoip6Path: assets.geoip6Path,
        lyrebirdPath: assets.lyrebirdPath,
        conjurePath: assets.conjurePath,
        aetherSocks:
            settings.torTransport == 'aether' ? settings.aetherLocalPort : null,
        psiphonSocks:
            settings.torTransport == 'psiphon' ? settings.socksPort : null,
        sstpSocks:
            settings.torTransport == 'sstp' ? settings.sstpSocksPort : null,
      );

      // ─── write torrc ───
      final torrcPath = '$torDir/torrc';
      await File(torrcPath).writeAsString(res.torrc);

      if (userStoppedTor) {
        _logTorCancel(src, 'after writing torrc');
        return null;
      }

      return (
        torrcPath: torrcPath,
        workDir: torDir,
        env: res.env,
        internalSocks: internalSocks,
        internalHttp: internalHttp,
      );
    } catch (e) {
      processService.addLog(
        '✗ Tor config build failed: $e',
        source: src,
      );
      rethrow;
    }
  }
}
