import 'dart:io';

class CoreUpdateCurl {
  static String get executable {
    if (!Platform.isWindows) return 'curl';
    final root =
        Platform.environment['SystemRoot'] ?? Platform.environment['WINDIR'];
    if (root == null || root.isEmpty) {
      throw StateError('Windows system directory not found.');
    }
    return '$root\\System32\\curl.exe';
  }

  static Map<String, String> get environment => {
        for (final entry in Platform.environment.entries)
          if (!{
            'http_proxy',
            'https_proxy',
            'all_proxy',
            'no_proxy',
            'curl_ca_bundle',
            'ssl_cert_file',
            'ssl_cert_dir',
            'curl_ssl_backend',
          }.contains(entry.key.toLowerCase()))
            entry.key: entry.value,
      };

  static List<String> arguments(String? proxy) => [
        '--disable',
        '--silent',
        '--show-error',
        '--location',
        '--fail',
        '--proto',
        '=http,https',
        '--proto-redir',
        '=https',
        '--noproxy',
        proxy == null || proxy.isEmpty ? '*' : '',
        if (proxy == null || proxy.isEmpty) ...[
          '--proxy',
          '',
        ] else ...[
          '--socks5-hostname',
          proxy,
        ],
      ];

  static bool usesWindowsCertificateStore(String version) {
    // Older Windows curl versions report Schannel as WinSSL.
    return RegExp(r'\b(?:Schannel|WinSSL)\b', caseSensitive: false)
        .hasMatch(version.split('\n').first);
  }

  static Future<void> ensureAvailable() async {
    final result = await Process.run(
      executable,
      ['--disable', '--version'],
      environment: environment,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0) {
      throw StateError('curl is unavailable for core updates.');
    }
    if (Platform.isWindows &&
        !usesWindowsCertificateStore(result.stdout as String)) {
      throw StateError(
          'Windows system curl must use Schannel certificate verification.');
    }
  }
}
