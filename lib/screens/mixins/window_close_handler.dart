import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../providers/app_provider.dart';

/// Mixin برای مدیریت بستن پنجره و disconnect کردن تونل‌ها.
///
/// ⚠️ نکته: کلاس استفاده‌کننده باید `WindowListener` را در `with` خود
/// قبل از این mixin بیاورد، مثلاً:
///
/// ```dart
/// class _MyState extends State<MyWidget>
///     with WindowListener, WindowCloseHandler {
/// ```
mixin WindowCloseHandler<T extends StatefulWidget> on State<T> {
  bool _closing = false;

  /// باید در initState صدا زده شود: `windowManager.addListener(this);`
  /// و در dispose: `windowManager.removeListener(this);`

  // ⚠️ توجه: این متد `onWindowClose` را از WindowListener که در کلاس
  // اصلی mix شده، override می‌کند. چون این mixin خودش WindowListener
  // نیست، نباید @override بگذاریم.
  void onWindowClose() async {
    if (_closing) return;
    _closing = true;

    final provider = context.read<AppProvider>();
    final ps = provider.processService;

    final hasActiveTunnel = ps.isPsiphonRunning ||
        ps.isAetherRunning ||
        ps.isTorRunning ||
        ps.isSstpRunning;

    // ─── مسیر A: هیچ تونلی فعال نیست → بستن سریع ───
    if (!hasActiveTunnel) {
      await _fastClose(provider);
      return;
    }

    // ─── مسیر B: تونل فعاله → disconnect کامل ───
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Disconnecting active tunnels…',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 15),
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
