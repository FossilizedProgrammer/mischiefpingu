library;

import 'tor_types.dart';

class TorDownloadPageParser {
  final TorLogFn log;
  final TorGetTextFn getText;

  TorDownloadPageParser({
    required this.log,
    required this.getText,
  });

  static const String _browserUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  /// پارس صفحه رسمی دانلود تور و برگرداندن URL مستقیم bundle.
  Future<String?> discover(
    String? proxy,
    bool isWin,
    String archTag,
  ) async {
    try {
      log('→ Fetching official download page: '
          'https://www.torproject.org/download/tor/ …');

      final html = await getText(
        'https://www.torproject.org/download/tor/',
        proxy,
        accept: 'text/html',
        userAgent: _browserUA,
      );

      final pattern = isWin
          ? r'href="([^"]*tor-expert-bundle-windows-x86_64-[^"]*\.tar\.gz)"'
          : r'href="([^"]*tor-expert-bundle-linux-' +
              archTag +
              r'-[^"]*\.tar\.gz)"';

      final match = RegExp(pattern).firstMatch(html);
      if (match == null) {
        log('⚠ Could not find expert bundle link in download page HTML.');
        return null;
      }

      var urlPath = match.group(1)!;
      if (urlPath.startsWith('/')) {
        urlPath = 'https://www.torproject.org$urlPath';
      } else if (!urlPath.startsWith('http')) {
        urlPath = 'https://www.torproject.org/download/$urlPath';
      }

      log('→ ✓ Found Tor expert bundle directly from download page: $urlPath');
      return urlPath;
    } catch (e) {
      log('⚠ Download page parse failed: $e');
      return null;
    }
  }
}
