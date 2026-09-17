import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ConnectionButtonState {
  final String actionLabel;
  final IconData icon;
  final Color color;
  final bool busy;
  final bool connected;

  const ConnectionButtonState({
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.busy,
    required this.connected,
  });

  factory ConnectionButtonState.resolve({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
    required Color primaryColor,
    required AppLocalizations l10n,
  }) {
    if (isBusy) {
      return ConnectionButtonState(
        actionLabel: l10n.cancel,
        icon: Icons.close_rounded,
        color: Colors.red.shade600,
        busy: true,
        connected: false,
      );
    }

    if (isConnected) {
      return ConnectionButtonState(
        actionLabel: l10n.stop,
        icon: Icons.stop_rounded,
        color: Colors.green.shade600,
        busy: false,
        connected: true,
      );
    }

    if (isRunning) {
      return ConnectionButtonState(
        actionLabel: l10n.stop,
        icon: Icons.stop_rounded,
        color: Colors.orange.shade700,
        busy: true,
        connected: false,
      );
    }

    return ConnectionButtonState(
      actionLabel: l10n.start,
      icon: Icons.power_settings_new_rounded,
      color: primaryColor,
      busy: false,
      connected: false,
    );
  }

  String statusText(int? progress, AppLocalizations l10n) {
    if (progress != null) return '$progress%';
    if (busy && !connected) return l10n.connecting;
    if (connected) return l10n.connected;
    return l10n.disconnected;
  }

  Color statusColor(Color primaryColor, Color onSurface) {
    if (busy && !connected) return color;
    if (connected) return Colors.green.shade600;
    return onSurface.withValues(alpha: 0.5);
  }
}
