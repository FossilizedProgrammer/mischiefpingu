import 'package:flutter/material.dart';

/// Mixin برای نمایش SnackBarهای یکپارچه در صفحه اصلی.
mixin SnackBarMixin<T extends StatefulWidget> on State<T> {
  String? lastShownProtocol;
  String? lastShownAetherProtocol;
  String? lastShownTorTransport;
  String? lastShownSstpServer;
  String? lastShownPortConflict;
  String? lastShownBinaryMissing;

  void showUnifiedSnackBar({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.primary;
    final fgColor = theme.colorScheme.onPrimary;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: fgColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: fgColor)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: fgColor.withValues(alpha: 0.9))),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void showProtocolSnackBar(String protocol, String? binaryName) {
    final binaryLabel = binaryName == 'psiphon-tunnel-core-sunandlion'
        ? 'SunAndLion psiphon-tunnel-core'
        : 'Official psiphon-tunnel-core';
    showUnifiedSnackBar(
      title: 'Psiphon Connected via $protocol',
      subtitle: '($binaryLabel binary)',
      icon: Icons.check_circle_rounded,
    );
  }

  void showAetherProtocolSnackBar(String protocol) {
    showUnifiedSnackBar(
      title: 'Aether Connected',
      subtitle: 'via ${protocol.toUpperCase()}',
      icon: Icons.cloud_done_rounded,
    );
  }

  void showTorTransportSnackBar(String transport, String detail) {
    String transportLabel;
    switch (transport) {
      case 'direct':
        transportLabel = 'Direct Connection';
        break;
      case 'aether':
        transportLabel = 'Tor-over-Aether';
        break;
      case 'bridge':
        transportLabel = 'Bridge Connection';
        break;
      default:
        transportLabel = 'Unknown';
    }
    showUnifiedSnackBar(
      title: 'Tor Connected',
      subtitle: '$transportLabel ($detail)',
      icon: Icons.shield_outlined,
    );
  }

  /// SnackBar برای اتصال موفق SSTP
  void showSstpConnectedSnackBar(String serverInfo) {
    showUnifiedSnackBar(
      title: 'SSTP Connected',
      subtitle: 'Server: $serverInfo',
      icon: Icons.vpn_lock_outlined,
    );
  }

  void showPortConflictSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white)),
          ),
        ]),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 7),
      ),
    );
  }

  void showBinaryMissingSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.download_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Binary Not Found',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(message,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
        ]),
        backgroundColor: theme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 8),
      ),
    );
  }
}
