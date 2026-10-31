// test/services/core_update_npv_test.dart
//
// تست آپدیت هستهٔ NPV از مخزن FossilizedProgrammer/npv-go:
//   • سیم‌کشی در registry و صفحهٔ آپدیت
//   • انتخاب asset درست از رلیز واقعی (آرشیو، نه checksums.txt)
//   • تشخیص نسخه: باینری رلیز عدد دارد، بیلد محلی نه

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/screens/widgets/core_update/core_update_controller.dart';
import 'package:mischiefpingu/services/core_update/core_update_aether.dart';
import 'package:mischiefpingu/services/core_update/core_update_ffvpn.dart';
import 'package:mischiefpingu/services/core_update/core_update_lantern.dart';
import 'package:mischiefpingu/services/core_update/core_update_network.dart';
import 'package:mischiefpingu/services/core_update/core_update_npv.dart';
import 'package:mischiefpingu/services/core_update/core_update_pending.dart';
import 'package:mischiefpingu/services/core_update/core_update_process_utils.dart';
import 'package:mischiefpingu/services/core_update/core_update_psiphon.dart';
import 'package:mischiefpingu/services/core_update/core_update_sstp.dart';
import 'package:mischiefpingu/services/core_update/core_update_sunandlion.dart';
import 'package:mischiefpingu/services/core_update/core_update_tor.dart';
import 'package:mischiefpingu/services/core_update/core_updater_registry.dart';
import 'package:mischiefpingu/services/core_update/shared/archive_extractor.dart';
import 'package:mischiefpingu/services/core_update/shared/asset_picker.dart';
import 'package:mischiefpingu/services/core_update/shared/github_core_spec.dart';
import 'package:mischiefpingu/services/core_update/shared/github_release_checker.dart';
import 'package:mischiefpingu/services/core_update/wireguard/wireguard_updater.dart';
import 'package:mischiefpingu/services/core_update_service.dart';

/// شبکهٔ جعلی — فقط همان سه متدی که checker استفاده می‌کند override می‌شود.
class _FakeNetwork extends CoreUpdateNetwork {
  final Map<String, dynamic> release;

  _FakeNetwork(this.release);

  @override
  void logRoute(String? proxy) {}

  @override
  Future<Map<String, dynamic>> getJson(String url, String? proxy) async =>
      release;

  @override
  Future<String> detectArch() async => 'x86_64';
}

void main() {
  // اندازهٔ واقعی asset لینوکس در رلیز v1.0.0.
  const linuxSize = 12910150;
  const windowsSize = 12665331;

  final assetName =
      Platform.isWindows ? 'npv-windows-amd64.zip' : 'npv-linux-amd64.tar.gz';
  final assetSize = Platform.isWindows ? windowsSize : linuxSize;

  Map<String, dynamic> releaseJson() => {
        'tag_name': 'v1.1.0',
        'body': 'release notes',
        'assets': [
          {
            'name': 'npv-linux-amd64.tar.gz',
            'size': linuxSize,
            'browser_download_url':
                'https://github.com/FossilizedProgrammer/npv-go/'
                    'releases/download/v1.1.0/npv-linux-amd64.tar.gz',
          },
          {
            'name': 'npv-windows-amd64.zip',
            'size': windowsSize,
            'browser_download_url':
                'https://github.com/FossilizedProgrammer/npv-go/'
                    'releases/download/v1.1.0/npv-windows-amd64.zip',
          },
          {
            'name': 'checksums.txt',
            'size': 177,
            'browser_download_url':
                'https://github.com/FossilizedProgrammer/npv-go/'
                    'releases/download/v1.1.0/checksums.txt',
          },
        ],
      };

  GithubCoreSpec buildSpec(String dest) => GithubCoreSpec(
        coreId: 'npv',
        displayName: 'NPV Tunnel (npv)',
        owner: 'FossilizedProgrammer',
        repo: 'npv-go',
        binaryBaseName: 'npv',
        fallbackPattern: 'npv',
        destPathResolver: () async => dest,
        tempPrefix: 'test_npv_',
        defaultDownloadSize: 13000000,
        sizeBasedVersion: true,
      );

  Future<CoreUpdateInfo> runCheck({
    required String installed,
    required String dest,
  }) async {
    final checker = GithubReleaseChecker(
      spec: buildSpec(dest),
      network: _FakeNetwork(releaseJson()),
    );
    return checker.check(null, installed: installed);
  }

  group('wiring', () {
    test('registry exposes the npv core', () {
      final network = CoreUpdateNetwork();
      final processUtils = CoreUpdateProcessUtils();
      final pending = CoreUpdatePendingManager(processUtils: processUtils);

      final registry = CoreUpdaterRegistry(
        aether: AetherUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        tor: TorUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        psiphon: PsiphonUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        sunAndLion: SunAndLionUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        sstp: SstpProxyUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        wireguard: WireGuardUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        wireguardAwg: WireGuardAwgUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        ffvpn: FfvpnUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        lantern: LanternUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
        npv: NpvUpdater(
          network: network,
          pending: pending,
          processUtils: processUtils,
        ),
      );

      expect(registry.byId('npv'), isNotNull);
      expect(registry.byId('npv')!.coreId, 'npv');
    });

    test('updates screen lists NPV with a npv state entry', () {
      final controller = CoreUpdateController(
        serviceFactory: () => throw UnimplementedError(),
        proxyResolver: () => '',
        providerResolver: () => throw UnimplementedError(),
      );

      final spec = CoreUpdateController.specs
          .where((s) => s.kind == CoreKind.npv)
          .single;
      expect(spec.displayName, 'NPV Tunnel (npv)');
      expect(controller.stateOf(CoreKind.npv).coreId, 'npv');
      controller.dispose();
    });
  });

  group('asset selection', () {
    test('picks this platform archive, never checksums.txt', () {
      final picked =
          AssetPicker.pick(releaseJson()['assets']! as List<dynamic>, 'x86_64');
      expect(picked, isNotNull);
      expect(picked!['name'], assetName);
    });

    test('both assets are unpacked rather than used as raw binaries', () {
      final extractor =
          ArchiveExtractor(processUtils: CoreUpdateProcessUtils());

      final tar = extractor.classifyArchive('npv-linux-amd64.tar.gz', 'npv');
      expect(tar.isArchive, isTrue);
      expect(tar.isZip, isFalse);

      final zip = extractor.classifyArchive('npv-windows-amd64.zip', 'npv');
      expect(zip.isArchive, isTrue);
      expect(zip.isZip, isTrue);
    });
  });

  group('version detection', () {
    late Directory tmp;
    late String dest;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('npv_updater_test_');
      dest = '${tmp.path}/npv';
    });

    tearDown(() async {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    });

    Future<void> writeBinary(int size) =>
        File(dest).writeAsBytes(List<int>.filled(size, 0));

    test('a stamped binary matching the release is up to date', () async {
      await writeBinary(1000);
      final info = await runCheck(installed: '1.1.0', dest: dest);
      expect(info.latestVersion, '1.1.0');
      expect(info.hasUpdate, isFalse);
      expect(info.downloadUrl, endsWith(assetName));
    });

    test('an older stamped binary offers the release', () async {
      await writeBinary(1000);
      final info = await runCheck(installed: '1.0.0', dest: dest);
      expect(info.hasUpdate, isTrue);
    });

    test('a missing binary is reported and offers the release', () async {
      final info = await runCheck(installed: 'not installed', dest: dest);
      expect(info.hasUpdate, isTrue);
    });

    test('an unstamped build falls back to the asset size', () async {
      // باینری بدون ldflags عدد ندارد؛ اگر اندازه‌ها یکی بود همان رلیز است.
      await writeBinary(assetSize);
      final same = await runCheck(installed: 'installed', dest: dest);
      expect(same.hasUpdate, isFalse);
      expect(same.installedVersion, '1.1.0');

      // باینری قدیمی‌تر/متفاوت → آپدیت پیشنهاد می‌شود.
      await writeBinary(1000);
      final older = await runCheck(installed: 'installed', dest: dest);
      expect(older.hasUpdate, isTrue);
    });
  });
}
