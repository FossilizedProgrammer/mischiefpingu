library;

import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../core_update_network.dart';
import '../../tor/tor_bundle_discovery.dart';

class TorChecker {
  final CoreUpdateNetwork network;
  final void Function(String)? log;

  TorChecker({required this.network, this.log});

  void _log(String m) => log?.call(m);

  TorBundleDiscovery get _discovery => TorBundleDiscovery(
        log: _log,
        getText: (url, proxy, {accept = '*/*', userAgent = ''}) =>
            network.getText(url, proxy, accept: accept, userAgent: userAgent),
        headRequest: (url, proxy, {timeoutSec = 15}) =>
            network.headRequest(url, proxy, timeoutSec: timeoutSec),
        linuxArch: network.detectArch,
      );

  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
  }) async {
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
}
