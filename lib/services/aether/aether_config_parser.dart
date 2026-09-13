// lib/services/aether/aether_config_parser.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../app_data_service.dart';

/// استخراج endpoint از فایل‌های کانفیگ Aether (TOML).
class AetherConfigParser {
  AetherConfigParser._();

  /// لیست فایل‌های کانفیگ ممکن بر اساس پروتکل.
  static List<String> filesForProtocol(String protocol) {
    switch (protocol) {
      case 'wireguard':
        return const ['aether-wireguard.toml', 'aether.toml'];
      case 'gool':
        return const ['aether-gool.toml', 'aether.toml'];
      case 'masque':
        return const ['aether-masque.toml', 'aether.toml'];
      default:
        return const [
          'aether-masque.toml',
          'aether-wireguard.toml',
          'aether-gool.toml',
          'aether.toml',
        ];
    }
  }

  /// استخراج endpoint از فایل کانفیگ (اولین مورد معتبر).
  static Future<String?> extractEndpoint(String protocol) async {
    try {
      final dataDir = await AppDataService.getDataDir();
      final configFiles = <String>[
        ...filesForProtocol(protocol),
        // fallback عمومی
        'aether-masque.toml',
        'aether-wireguard.toml',
        'aether-gool.toml',
        'aether.toml',
      ];

      for (final configFile in configFiles.toSet()) {
        final f = File(p.join(dataDir, configFile));
        if (!await f.exists()) continue;

        final content = await f.readAsString();
        final lines = content.split('\n');
        final result = _scanLines(lines);
        if (result != null) return result;
      }
    } catch (_) {}
    return null;
  }

  static final List<RegExp> _patterns = [
    // peer = "ip:port" یا peer = 'ip:port'
    RegExp(r'''peer\s*=\s*["']([^"']+)["']'''),
    // gateway = "ip:port"
    RegExp(r'''gateway\s*=\s*["']([^"']+)["']'''),
    // endpoint = "ip:port"
    RegExp(r'''endpoint\s*=\s*["']([^"']+)["']'''),
    // Address = "ip:port" (WireGuard style)
    RegExp(r'''Address\s*=\s*["']?([^"'\s]+)["']?'''),
    // الگوی عمومی ip:port
    RegExp(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{2,5})'),
  ];

  static String? _scanLines(List<String> lines) {
    for (final pattern in _patterns) {
      for (final line in lines) {
        final match = pattern.firstMatch(line.trim());
        if (match == null) continue;
        final candidate = match.group(1)?.trim() ?? '';
        if (candidate.isEmpty) continue;
        if (_isValidIpPort(candidate)) return candidate;
      }
    }
    return null;
  }

  static bool _isValidIpPort(String candidate) {
    if (!candidate.contains(':')) return false;
    final parts = candidate.split(':');
    if (parts.length != 2) return false;
    final portNum = int.tryParse(parts[1]);
    return portNum != null && portNum > 0 && portNum <= 65535;
  }
}
