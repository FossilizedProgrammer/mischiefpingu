// lib/screens/widgets/core_update/core_update_proxy_resolver.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class CoreUpdateProxyResolver {
  final String proxyMode;
  const CoreUpdateProxyResolver(this.proxyMode);

  String? resolve(BuildContext context) {
    final p = context.read<AppProvider>();
    String? pick(String mode) {
      switch (mode) {
        case 'psiphon':
          return p.processService.isPsiphonConnected
              ? '127.0.0.1:${p.settings.socksPort}'
              : null;
        case 'aether':
          return p.processService.isAetherRunning
              ? '127.0.0.1:${p.settings.aetherLocalPort}'
              : null;
        case 'tor':
          return p.processService.isTorConnected
              ? '127.0.0.1:${p.settings.torSocksPort}'
              : null;
        case 'sstp':
          return p.processService.isSstpConnected
              ? '127.0.0.1:${p.settings.sstpSocksPort}'
              : null;
        default:
          return null;
      }
    }

    if (proxyMode == 'direct') return null;
    if (proxyMode != 'auto') {
      final v = pick(proxyMode);
      if (v == null) {
        throw StateError(
          '$proxyMode is not running — start it first or use Auto/Direct.',
        );
      }
      return v;
    }
    for (final m in ['psiphon', 'aether', 'tor', 'sstp']) {
      final v = pick(m);
      if (v != null) return v;
    }
    return null;
  }
}

List<DropdownMenuItem<String>> buildCoreUpdateProxyItems(dynamic l10n) {
  return [
    DropdownMenuItem(value: 'auto', child: Text(l10n.autoFirstProxy)),
    DropdownMenuItem(value: 'direct', child: Text(l10n.directNoProxyOption)),
    const DropdownMenuItem(value: 'psiphon', child: Text('Psiphon')),
    const DropdownMenuItem(value: 'aether', child: Text('Aether')),
    const DropdownMenuItem(value: 'tor', child: Text('Tor')),
    const DropdownMenuItem(value: 'sstp', child: Text('SSTP')),
  ];
}

const List<DropdownMenuItem<String>> coreUpdateProxyItems = [
  DropdownMenuItem(value: 'auto', child: Text('Auto')),
  DropdownMenuItem(value: 'direct', child: Text('Direct')),
  DropdownMenuItem(value: 'psiphon', child: Text('Psiphon')),
  DropdownMenuItem(value: 'aether', child: Text('Aether')),
  DropdownMenuItem(value: 'tor', child: Text('Tor')),
  DropdownMenuItem(value: 'sstp', child: Text('SSTP')),
];
