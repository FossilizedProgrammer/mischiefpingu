// lib/widgets/painful_logo.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'painful_logo/logo_mode.dart';
import 'painful_logo/logo_audio_manager.dart';
import 'painful_logo/logo_state_machine.dart';
import 'painful_logo/logo_asset_resolver.dart';
import 'painful_logo/logo_notification_bridge.dart';

class PainfulLogo extends StatefulWidget {
  final double size;
  final Duration hurtDuration;
  final Duration sadDuration;
  final Duration happyDuration;
  final Duration hiDuration;

  const PainfulLogo({
    super.key,
    this.size = 80,
    this.hurtDuration = const Duration(seconds: 2),
    this.sadDuration = const Duration(seconds: 6),
    this.happyDuration = const Duration(seconds: 4),
    this.hiDuration = const Duration(seconds: 4),
  });

  @override
  State<PainfulLogo> createState() => _PainfulLogoState();
}

class _PainfulLogoState extends State<PainfulLogo> {
  LogoMode _mode = LogoMode.hi;
  Timer? _resetTimer;

  late final LogoAudioManager _audio;
  late final LogoStateMachine _stateMachine;
  late final LogoAssetResolver _assetResolver;

  LogoNotificationBridge? _bridge;

  @override
  void initState() {
    super.initState();

    _audio = LogoAudioManager();
    _assetResolver = LogoAssetResolver(size: widget.size);

    _stateMachine = LogoStateMachine(
      audio: _audio,
      onModeChanged: (mode) {
        if (mounted) setState(() => _mode = mode);
      },
      hurtDuration: widget.hurtDuration,
      sadDuration: widget.sadDuration,
      happyDuration: widget.happyDuration,
      hiDuration: widget.hiDuration,
      onTimerCreated: (timer) => _resetTimer = timer,
    );

    // ⚠️ شروع اولیه با hi — اینجا هنوز در initState هستیم.
    // setState از داخل startInitial صدا زده می‌شود ولی چون
    // هنوز در initState هستیم، با addPostFrameCallback به تأخیر می‌اندازیم.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _stateMachine.startInitial();
    });

    // ⚠️ bridge رو در اولین فرصت بعد از build بساز.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachBridge();
    });
  }

  void _attachBridge() {
    try {
      final app = context.read<AppProvider>();
      final ps = app.processService;

      _bridge = LogoNotificationBridge(
        processService: ps,
        onModeRequested: _stateMachine.transitionTo,
      );
      _bridge!.attach();
      _bridge!.checkPendingNotifications();

      // ⚠️ sync اولیه mute از settings
      _audio.setMuted(app.settings.muted);

      debugPrint('PainfulLogo: bridge attached successfully');
    } catch (e) {
      debugPrint('PainfulLogo: bridge attach failed → $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠️ mute رو دوباره sync کن — ولی بدون context.watch
    // (context.read کافی است چون فقط یک بار می‌خواهیم بخوانیم)
    if (_bridge != null) {
      try {
        final muted = context.read<AppProvider>().settings.muted;
        _audio.setMuted(muted);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _bridge?.dispose();
    _stateMachine.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _onHurt() {
    if (_mode == LogoMode.sad) return;
    _stateMachine.transitionTo(LogoMode.hurt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ⚠️ Consumer برای sync کردن mute — بدون context.watch در
    // didChangeDependencies. Consumer فقط وقتی rebuild می‌شود که
    // مقدار انتخاب‌شده تغییر کند.
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        // sync mute در هر rebuild — چون Consumer فقط وقتی صدا زده
        // می‌شود که AppProvider تغییر کند.
        _audio.setMuted(app.settings.muted);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _onHurt,
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _assetResolver.resolve(_mode, theme),
              ),
            ),
          ),
        );
      },
    );
  }
}
