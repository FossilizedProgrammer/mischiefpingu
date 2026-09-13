import 'package:flutter/material.dart';

/// حالت دکمه‌ی اتصال (Start/Stop/Cancel + رنگ + آیکون).
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

  /// منطق مشترک همهٔ دکمه‌های اتصال (Aether/Psiphon/Tor/SSTP).
  factory ConnectionButtonState.resolve({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
    required Color primaryColor,
  }) {
    // ─── در حال اتصال (bootstrap / start) ───
    if (isBusy) {
      return ConnectionButtonState(
        actionLabel: 'Cancel',
        icon: Icons.close_rounded,
        color: Colors.red.shade600,
        busy: true,
        connected: false,
      );
    }

    // ─── متصل شده ───
    if (isConnected) {
      return ConnectionButtonState(
        actionLabel: 'Stop',
        icon: Icons.stop_rounded,
        color: Colors.green.shade600,
        busy: false,
        connected: true,
      );
    }

    // ─── پروسه هست ولی هنوز وصل نشده ───
    if (isRunning) {
      return ConnectionButtonState(
        actionLabel: 'Stop',
        icon: Icons.stop_rounded,
        color: Colors.orange.shade700,
        busy: true,
        connected: false,
      );
    }

    // ─── خاموش ───
    return ConnectionButtonState(
      actionLabel: 'Start',
      icon: Icons.power_settings_new_rounded,
      color: primaryColor,
      busy: false,
      connected: false,
    );
  }

  /// متن وضعیت زیر دکمه.
  String statusText(int? progress) {
    if (progress != null) return '$progress%';
    if (busy && !connected) return 'Connecting…';
    if (connected) return 'Connected';
    return 'Disconnected';
  }

  /// رنگ متن وضعیت زیر دکمه.
  Color statusColor(Color primaryColor, Color onSurface) {
    if (busy && !connected) return color;
    if (connected) return Colors.green.shade600;
    return onSurface.withValues(alpha: 0.5);
  }
}
