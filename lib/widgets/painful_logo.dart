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

  /// ⚠️ flag برای جلوگیری از ساخت bridge تکراری
  bool _bridgeAttached = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _stateMachine.startInitial();
      _attachBridge();
    });
  }

  void _attachBridge() {
    if (_bridgeAttached || _bridge != null) return;
    _bridgeAttached = true;

    try {
      final app = context.read<AppProvider>();
      final ps = app.processService;

      _bridge = LogoNotificationBridge(
        processService: ps,
        onModeRequested: (mode) {
          if (mounted) _stateMachine.transitionTo(mode);
        },
      );
      _bridge!.attach();
      _bridge!.checkPendingNotifications();

      _audio.setMuted(app.settings.muted);
    } catch (e) {
      debugPrint('PainfulLogo: bridge attach failed → $e');
      _bridgeAttached = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bridge != null && mounted) {
      try {
        final muted = context.read<AppProvider>().settings.muted;
        _audio.setMuted(muted);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _bridge?.dispose();
    _bridge = null;
    _bridgeAttached = false;

    _resetTimer?.cancel();
    _resetTimer = null;

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

    return Consumer<AppProvider>(
      builder: (context, app, _) {
        _audio.setMuted(app.settings.muted);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _onHurt,
            onSecondaryTap: _onHurt,
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
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
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
