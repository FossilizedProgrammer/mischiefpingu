// lib/screens/widgets/snackbar_mixin.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'snackbar_builders.dart';

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
    SnackBarBuilders.showUnified(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
  }

  void showProtocolSnackBar(String protocol, String? binaryName) {
    final l10n = AppLocalizations.of(context);
    final binaryLabel = binaryName == 'psiphon-tunnel-core-sunandlion'
        ? 'SunAndLion psiphon-tunnel-core'
        : 'Official psiphon-tunnel-core';
    showUnifiedSnackBar(
      title: '${l10n.psiphonConnectedVia} $protocol',
      subtitle: '($binaryLabel)',
      icon: Icons.check_circle_rounded,
    );
  }

  void showAetherProtocolSnackBar(String protocol) {
    final l10n = AppLocalizations.of(context);
    showUnifiedSnackBar(
      title: l10n.aetherConnected,
      subtitle: 'via ${protocol.toUpperCase()}',
      icon: Icons.cloud_done_rounded,
    );
  }

  void showTorTransportSnackBar(String transport, String detail) {
    final l10n = AppLocalizations.of(context);
    String transportLabel;
    switch (transport) {
      case 'direct':
        transportLabel = l10n.torDirect;
        break;
      case 'aether':
        transportLabel = l10n.torViaAether;
        break;
      case 'bridge':
        transportLabel = l10n.torBridge;
        break;
      default:
        transportLabel = transport;
    }
    showUnifiedSnackBar(
      title: l10n.torConnected,
      subtitle: '$transportLabel ($detail)',
      icon: Icons.shield_outlined,
    );
  }

  void showSstpConnectedSnackBar(String serverInfo) {
    final l10n = AppLocalizations.of(context);
    showUnifiedSnackBar(
      title: l10n.sstpConnected,
      subtitle: '${l10n.server}: $serverInfo',
      icon: Icons.vpn_lock_outlined,
    );
  }

  void showPortConflictSnackBar(String message) {
    if (!mounted) return;
    SnackBarBuilders.showPortConflict(context, message);
  }

  void showBinaryMissingSnackBar(String message) {
    if (!mounted) return;
    SnackBarBuilders.showBinaryMissing(context, message);
  }
}
