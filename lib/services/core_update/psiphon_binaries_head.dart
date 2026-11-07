library;

import '../app_data_service.dart';
import 'core_update_network.dart';

class PsiphonBinariesHead {
  final CoreUpdateNetwork network;
  final void Function(String)? log;

  const PsiphonBinariesHead({required this.network, this.log});

  void _log(String m) => log?.call(m);

  bool get _isWin => AppDataService.isWindows;

  /// اطلاعات باینری رسمی Psiphon را از GitHub Contents API می‌گیرد.
  ///
  /// روی همه پلتفرم‌ها از فایل i686 استفاده می‌کنیم — چون
  /// در عمل روی ویندوز ۶۴ بیتی هم درست کار می‌کند.
  Future<({String sha, int size, String url})> fetch(String? proxy) async {
    final targetPath = _isWin
        ? 'windows/psiphon-tunnel-core-i686.exe'
        : 'linux/psiphon-tunnel-core-x86_64';

    final apiUrl =
        'https://api.github.com/repos/Psiphon-Labs/psiphon-tunnel-core-binaries/contents/$targetPath?ref=master';

    try {
      final info = await network.getJson(apiUrl, proxy);
      final sha = (info['sha'] as String? ?? '').trim();
      final size = (info['size'] as num? ?? 0).toInt();
      final url =
          'https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/$targetPath';
      return (sha: sha, size: size, url: url);
    } catch (e) {
      _log('⚠ Failed to fetch Psiphon binary info via Contents API: $e');
      rethrow;
    }
  }
}
