import 'package:flutter/material.dart';
import 'connection_state.dart';

/// داده‌های محاسبه‌شده برای یک دکمه اتصال.
class ConnectionButtonData {
  final ConnectionButtonState state;
  final int? progress;

  const ConnectionButtonData({required this.state, this.progress});
}

/// سازندهٔ state دکمه‌ها بر اساس وضعیت ProcessService.
class ConnectionButtonBuilder {
  final Color primaryColor;
  const ConnectionButtonBuilder({required this.primaryColor});

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
      ),
      progress: progress,
    );
  }
}
