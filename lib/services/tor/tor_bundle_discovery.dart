library;

import '../app_data_service.dart';
import 'tor_bundle_fallbacks.dart';
import 'tor_download_page_parser.dart';
import 'tor_types.dart';

class TorBundleDiscovery {
  final TorLogFn log;
  final TorGetTextFn getText;
  final TorHeadFn headRequest;
  final TorArchFn linuxArch;

  late final TorDownloadPageParser _pageParser = TorDownloadPageParser(
    log: log,
    getText: getText,
  );

  TorBundleDiscovery({
    required this.log,
    required this.getText,
    required this.headRequest,
    required this.linuxArch,
  });

  /// نقطهٔ ورود اصلی — تلاش برای پیدا کردن URL bundle.
  Future<String?> discover(String? proxy) async {
    final arch = await linuxArch();
    final archTag = TorBundleFallbacks.archTag(arch);
    final isWin = AppDataService.isWindows;

    final pageUrl = await _pageParser.discover(proxy, isWin, archTag);
    if (pageUrl != null) return pageUrl;

    final versions = await _collectVersions(proxy);
    if (versions.isEmpty) {
      log('⚠ No versions discovered, jumping to hardcoded stable fallbacks');
      return TorBundleFallbacks.tryStable(
        proxy: proxy,
        archTag: archTag,
        headRequest: headRequest,
        log: log,
      );
    }

    versions.sort(TorBundleFallbacks.compareVersions);
    final sorted = versions.reversed.toList();
    log(
      '→ Will probe ${sorted.length} stable version(s), newest first: '
      '${sorted.take(8).join(', ')}${sorted.length > 8 ? ' …' : ''}',
    );

    for (final version in sorted.take(10)) {
      final url = await _probeVersion(version, archTag, isWin, proxy);
      if (url != null) return url;
    }

    log(
      '⚠ No expert bundle found via live probing, '
      'trying hardcoded stable fallbacks …',
    );
    return TorBundleFallbacks.tryStable(
      proxy: proxy,
      archTag: archTag,
      headRequest: headRequest,
      log: log,
    );
  }

  Future<List<String>> _collectVersions(String? proxy) async {
    final versions = <String>{};

    try {
      log('→ Fetching LATEST-VERSION from torproject.org …');
      final text = await getText(
        'https://www.torproject.org/dist/torbrowser/LATEST-VERSION',
        proxy,
        accept: 'text/plain',
        userAgent: 'mischiefpingu-CoreUpdater/1.0',
      );
      final latest = text.trim();
      if (latest.isNotEmpty) {
        log('→ LATEST-VERSION reports: $latest');
        versions.add(latest);
      }
    } catch (e) {
      log('⚠ LATEST-VERSION fetch failed: $e');
    }

    for (final baseUrl in [
      'https://www.torproject.org/dist/torbrowser/',
      'https://archive.torproject.org/tor-package-archive/torbrowser/',
    ]) {
      try {
        log('→ Parsing version index at $baseUrl …');
        final index = await getText(
          baseUrl,
          proxy,
          accept: 'text/html',
          userAgent: 'mischiefpingu-CoreUpdater/1.0',
        );
        final dirs = RegExp(r'href="(\d+\.\d+(?:\.\d+)?)\/"')
            .allMatches(index)
            .map((m) => m.group(1)!);
        versions.addAll(dirs);
        if (dirs.isNotEmpty) {
          log('→ Found ${dirs.length} STABLE version directories');
        }
      } catch (e) {
        log('⚠ Index parse failed for $baseUrl: $e');
      }
    }

    return versions.toList();
  }

  Future<String?> _probeVersion(
    String version,
    String archTag,
    bool isWin,
    String? proxy,
  ) async {
    final names = TorBundleFallbacks.bundleNames(version, archTag, isWin);
    for (final mirror in TorBundleFallbacks.mirrors) {
      for (final name in names) {
        final url = '$mirror/$version/$name';
        final head = await headRequest(url, proxy, timeoutSec: 10);
        if (head != null && head.status == 200) {
          log('→ ✓ Found Tor expert bundle: $name (v$version)');
          return url;
        }
      }
    }
    return null;
  }
}
