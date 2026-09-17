// lib/services/core_update/core_update_tor.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../app_data_service.dart';
import '../core_update_models.dart';
import '../core_update_utils.dart';
import '../tor/tor_bundle_discovery.dart';
import '../tor/tor_bundle_installer.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'core_update_tor_version.dart';

class TorUpdater {
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  TorUpdater({
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);
  String get _exeExt => AppDataService.exeExt;

  TorBundleDiscovery get _discovery => TorBundleDiscovery(
        log: _log,
        getText: (url, proxy, {accept = '*/*', userAgent = ''}) =>
            network.getText(url, proxy, accept: accept, userAgent: userAgent),
        headRequest: (url, proxy, {timeoutSec = 15}) =>
            network.headRequest(url, proxy, timeoutSec: timeoutSec),
        linuxArch: network.detectArch,
      );

  Future<CoreUpdateInfo> check(String? proxy,
      {required String installed}) async {
    network.logRoute(proxy);
    String discoveredUrl = '';
    String latestVer = installed;
    try {
      final url = await _discovery.discover(proxy);
      if (url != null) {
        discoveredUrl = url;
        final vMatch =
            RegExp(r'tor-expert-bundle[^/]*?(\d+\.\d+\.\d+)').firstMatch(url);
        if (vMatch != null) latestVer = vMatch.group(1)!;
      }
    } catch (e) {
      _log('⚠ Tor bundle discovery during check failed: $e');
    }
    return CoreUpdateInfo(
      coreId: 'tor',
      displayName: 'Tor (Onion Routing)',
      installedVersion: installed,
      latestVersion: latestVer,
      hasUpdate: CoreUpdateUtils.isMissingVersion(installed) ||
          (latestVer != installed && latestVer != 'not installed'),
      downloadUrl: discoveredUrl,
      releaseNotes: CoreUpdateUtils.isMissingVersion(installed)
          ? 'Tor binary is missing — Update will download it.'
          : 'Tor Expert Bundle from torproject.org.',
      downloadSizeBytes: 0,
    );
  }

  Future<bool> update({
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    network.logRoute(proxy);
    _log('→ Locating latest STABLE Tor expert bundle …');
    onProgress?.call(5);
    final url = await _discovery.discover(proxy);
    if (url == null) {
      throw StateError(
          'Could not locate a stable Tor expert-bundle from torproject.org.');
    }
    _log('→ Downloading Tor bundle from: ${url.split('/').last}');
    final tmp = await Directory.systemTemp.createTemp('mischiefpingu_tor_');
    try {
      final isZip = url.toLowerCase().endsWith('.zip');
      final archiveName = isZip ? 'tor.zip' : 'tor.tar.gz';
      final archive = '${tmp.path}/$archiveName';
      await network.download(url, archive,
          proxy: proxy, onProgress: onProgress, onCancelCheck: onCancelCheck);
      onProgress?.call(80);
      final extractDir = Directory('${tmp.path}/extract');
      await extractDir.create(recursive: true);
      await processUtils.extractArchive(archive, extractDir.path);
      final searchName = 'tor$_exeExt';
      final torBin = await CoreUpdateUtils.findFile(extractDir, searchName);
      if (torBin == null) {
        throw StateError('`$searchName` binary not found inside the bundle.');
      }
      final srcRoot = TorBundleInstaller.bundleRoot(extractDir, torBin);
      onProgress?.call(90);
      final torDir = await AppDataService.ensureTorDir();
      final dest = p.join(torDir, searchName);
      final isRunning = await processUtils.isProcessRunning(searchName);
      if (isRunning) {
        await _deferUpdate(
          srcRoot: srcRoot,
          torBin: torBin,
          dest: dest,
          onProgress: onProgress,
        );
        return true;
      }
      final oldSize = await CoreUpdateUtils.fileSize(dest);
      final count = await TorBundleInstaller.installTree(
          srcRoot: srcRoot, torDir: torDir, log: _log);
      if (count == 0) {
        throw StateError('Tor bundle install failed (0 files copied).');
      }
      await processUtils.updateExecutableDirBinary('tor', torBin);
      await AppDataService.fixDataDirOwnership();
      var installedBin = dest;
      if (!await File(installedBin).exists()) {
        final found =
            await CoreUpdateUtils.findFile(Directory(torDir), searchName);
        if (found != null) installedBin = found;
      }
      final newSize = await CoreUpdateUtils.fileSize(installedBin);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');
      final newVer =
          await TorVersionQuery.queryAndParse(installedBin) ?? 'bundle';
      onProgress?.call(100);
      _log(
          '★ Tor installed: $installed → $newVer ($count files, ${CoreUpdateUtils.formatBytes(oldSize)} → ${CoreUpdateUtils.formatBytes(newSize)}) → $torDir');
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }

  Future<void> _deferUpdate({
    required String srcRoot,
    required String torBin,
    required String dest,
    void Function(int percent)? onProgress,
  }) async {
    final stagingDir =
        await Directory.systemTemp.createTemp('mischiefpingu_deferred_tor_');
    final stagingRoot = Directory(p.join(stagingDir.path, 'bundle'));
    await stagingRoot.create(recursive: true);
    await TorBundleInstaller.installTree(
        srcRoot: srcRoot, torDir: stagingRoot.path, log: _log);
    final stagingPath =
        p.join(stagingRoot.path, p.relative(torBin, from: srcRoot));
    await pending.add(PendingCoreUpdate(
      coreId: 'tor',
      stagingPath: stagingPath,
      destPath: dest,
      version: 'bundle',
      createdAt: DateTime.now(),
    ));
    onProgress?.call(100);
    _log('★ Tor update downloaded — deferred, will apply on next startup');
  }
}
