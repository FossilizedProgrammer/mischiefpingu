import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'connection_state.dart';

class ConnectionButtonData {
  final ConnectionButtonState state;
  final int? progress;

  const ConnectionButtonData({required this.state, this.progress});
}

class ConnectionButtonBuilder {
  final Color primaryColor;
  final AppLocalizations l10n;
  const ConnectionButtonBuilder({
    required this.primaryColor,
    required this.l10n,
  });

  ConnectionButtonData forAether({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
    required int? progress,
  }) =>
      _build(
        isRunning: isRunning,
        isConnected: isConnected,
        isBusy: isBusy,
        progress: progress,
      );

  ConnectionButtonData forPsiphon({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
  }) =>
      _build(
        isRunning: isRunning,
        isConnected: isConnected,
        isBusy: isBusy,
      );

  ConnectionButtonData forTor({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
    required int? progress,
  }) =>
      _build(
        isRunning: isRunning,
        isConnected: isConnected,
        isBusy: isBusy,
        progress: progress,
      );

  ConnectionButtonData forSstp({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
  }) =>
      _build(
        isRunning: isRunning,
        isConnected: isConnected,
        isBusy: isBusy,
      );

  ConnectionButtonData _build({
    required bool isRunning,
    required bool isConnected,
    required bool isBusy,
    int? progress,
  }) {
    return ConnectionButtonData(
      state: ConnectionButtonState.resolve(
        isRunning: isRunning,
        isConnected: isConnected,
        isBusy: isBusy,
        primaryColor: primaryColor,
        l10n: l10n,
      ),
      progress: progress,
    );
  }
}
