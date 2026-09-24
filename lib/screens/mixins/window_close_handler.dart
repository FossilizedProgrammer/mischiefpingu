import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';

mixin WindowCloseHandler<T extends StatefulWidget> on State<T> {
  bool _closing = false;

  void onWindowClose() async {
    if (_closing) return;
    _closing = true;

    final provider = context.read<AppProvider>();
    final ps = provider.processService;

    final hasActiveTunnel = ps.isPsiphonRunning ||
        ps.isAetherRunning ||
        ps.isTorRunning ||
        ps.isSstpRunning ||
        ps.isWireGuardRunning; // ← اضافه شد

    if (!hasActiveTunnel) {
      await _fastClose(provider);
      return;
    }

    await _safeClose(provider);
  }

  Future<void> _fastClose(AppProvider provider) async {
    try {
      provider.cancelAllAutoReconnect();
      await windowManager.setPreventClose(false);
      await Future.delayed(const Duration(milliseconds: 50));
      await windowManager.destroy();
    } catch (_) {
      try {
        await windowManager.setPreventClose(false);
      } catch (_) {}
      try {
        await windowManager.destroy();
      } catch (_) {}
    }
  }

  Future<void> _safeClose(AppProvider provider) async {
    final l10n = AppLocalizations.of(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.disconnectingTunnels,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 15),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    provider.cancelAllAutoReconnect();

    try {
      await provider.shutdownAll().timeout(
        const Duration(seconds: 14),
        onTimeout: () {
          debugPrint('[shutdown] timeout — forcing close');
        },
      );
    } catch (e) {
      debugPrint('[shutdown] error: $e');
    }

    try {
      await windowManager.setPreventClose(false);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 80));

    try {
      await windowManager.destroy();
    } catch (_) {}
  }
}
