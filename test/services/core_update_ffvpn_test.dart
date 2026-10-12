// test/services/core_update_ffvpn_test.dart
//
// تست آپدیت هستهٔ Firefox VPN (ffvpn): سیم‌کشی در registry/UI و
// تشخیص نسخهٔ نصب‌شده از روی اندازهٔ باینری (چون ffvpn پرچم
// `--version` ندارد).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/screens/widgets/core_update/core_update_controller.dart';
import 'package:mischiefpingu/services/core_update/core_update_ffvpn.dart';
import 'package:mischiefpingu/services/core_update/core_update_network.dart';
import 'package:mischiefpingu/services/core_update/core_update_pending.dart';
import 'package:mischiefpingu/services/core_update/core_update_process_utils.dart';
import 'package:mischiefpingu/services/core_update/core_update_psiphon.dart';
import 'package:mischiefpingu/services/core_update/core_update_sstp.dart';
import 'package:mischiefpingu/services/core_update/core_update_sunandlion.dart';
import 'package:mischiefpingu/services/core_update/core_update_tor.dart';
import 'package:mischiefpingu/services/core_update/core_updater_registry.dart';
import 'package:mischiefpingu/services/core_update/shared/archive_extractor.dart';
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
  // اندازهٔ asset جعلی release — منطق بررسی فقط اندازه‌ها را مقایسه می‌کند.
  const assetSize = 5000;

  late Directory tmp;
  late File localBinary;

  Map<String, dynamic> releaseJson() => {
        'tag_name': 'v0.1.0',
        'body': 'release notes',
        'assets': [
          {
            'name': 'ffvpn-linux-amd64',
            'size': assetSize,
            'browser_download_url':
                'https://github.com/FossilizedProgrammer/firefox-vpn-go/'
                    'releases/download/v0.1.0/ffvpn-linux-amd64',
          },
        ],
      };

  GithubCoreSpec buildSpec({bool sizeBased = true}) => GithubCoreSpec(
        coreId: 'ffvpn',
        displayName: 'Firefox VPN (ffvpn)',
        owner: 'FossilizedProgrammer',
        repo: 'firefox-vpn-go',
        binaryBaseName: 'ffvpn',
        fallbackPattern: 'ffvpn',
        destPathResolver: () async => localBinary.path,
        tempPrefix: 'test_ffvpn_',
        defaultDownloadSize: 6500000,
        sizeBasedVersion: sizeBased,
      );

  Future<CoreUpdateInfo> runCheck({
    required String installed,
    bool sizeBased = true,
  }) {
    final checker = GithubReleaseChecker(
      spec: buildSpec(sizeBased: sizeBased),
      network: _FakeNetwork(releaseJson()),
    );
    return checker.check(null, installed: installed);
  }

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('ffvpn_updater_test_');
    localBinary = File('${tmp.path}/ffvpn');
  });

  tearDown(() async {
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  });

  group('wiring', () {
    test('registry exposes the ffvpn core', () {
      final network = CoreUpdateNetwork();
      final processUtils = CoreUpdateProcessUtils();
      final pending = CoreUpdatePendingManager(processUtils: processUtils);

      final registry = CoreUpdaterRegistry(
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
      );

      expect(registry.byId('ffvpn'), isNotNull);
      expect(registry.byId('ffvpn')!.coreId, 'ffvpn');
    });

    test('updates screen lists Firefox VPN with a ffvpn state entry', () {
      final controller = CoreUpdateController(
        serviceFactory: () => throw UnimplementedError(),
        proxyResolver: () => '',
        providerResolver: () => throw UnimplementedError(),
      );

      final ffvpnSpec = CoreUpdateController.specs
          .where((s) => s.kind == CoreKind.ffvpn)
          .single;
      expect(ffvpnSpec.displayName, 'Firefox VPN (ffvpn)');
      expect(controller.stateOf(CoreKind.ffvpn).coreId, 'ffvpn');
      controller.dispose();
    });

    test('release assets are handled as raw binaries', () {
      final extractor = ArchiveExtractor(processUtils: CoreUpdateProcessUtils());
      final raw = extractor.classifyArchive('ffvpn-linux-amd64', 'ffvpn');
      expect(raw.isArchive, isFalse);
      expect(raw.isRawBinary, isTrue);

      final exe = extractor.classifyArchive('ffvpn-windows-amd64.exe', 'ffvpn');
      expect(exe.isArchive, isFalse);
      expect(exe.isRawBinary, isTrue);
    });
  });

  group('size-based installed version', () {
    test('local binary matching the release asset is up to date', () async {
      await localBinary.writeAsBytes(List.filled(assetSize, 1));

      final info = await runCheck(installed: 'installed');

      expect(info.hasUpdate, isFalse);
      expect(info.installedVersion, '0.1.0');
      expect(info.latestVersion, '0.1.0');
      expect(info.downloadUrl, isNotEmpty);
    });

    test(
      'local binary differing from the release asset offers an update',
      () async {
        await localBinary.writeAsBytes(List.filled(assetSize + 1234, 1));

        final info = await runCheck(installed: 'installed');

        expect(info.hasUpdate, isTrue);
        expect(info.installedVersion, 'installed');
        expect(info.latestVersion, '0.1.0');
      },
    );

    test('missing local binary offers an update', () async {
      final info = await runCheck(installed: 'not installed');

      expect(info.hasUpdate, isTrue);
      expect(info.installedVersion, 'not installed');
    });

    test('a known installed version is trusted over the file size', () async {
      await localBinary.writeAsBytes(List.filled(assetSize + 1234, 1));

      final info = await runCheck(installed: '0.1.0');

      expect(info.hasUpdate, isFalse);
      expect(info.installedVersion, '0.1.0');
    });

    test('specs without sizeBasedVersion keep the old behaviour', () async {
      await localBinary.writeAsBytes(List.filled(assetSize, 1));

      final info = await runCheck(installed: 'installed', sizeBased: false);

      expect(info.hasUpdate, isTrue);
      expect(info.installedVersion, 'installed');
    });
  });

  group('installed version detection', () {
    test('ffvpn never reports "unknown" (it has no --version flag)', () async {
      final version = await CoreUpdateService()
          .getInstalledVersion('ffvpn')
          .timeout(const Duration(seconds: 30));

      expect(version, anyOf('not installed', 'installed'));
    });
  });
}
