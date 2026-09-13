import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// لوگوی تعاملی که با کلیک، صدا پخش می‌کنه و ۲ ثانیه تصویرش عوض می‌شه.
class PainfulLogo extends StatefulWidget {
  final double size;
  final Duration hurtDuration;

  const PainfulLogo({
    super.key,
    this.size = 80,
    this.hurtDuration = const Duration(seconds: 2),
  });

  @override
  State<PainfulLogo> createState() => _PainfulLogoState();
}

class _PainfulLogoState extends State<PainfulLogo> {
  static const String _normalAsset = 'assets/images/logo.png';
  static const String _hurtAsset = 'assets/images/logo_hurt.png';
  static const String _soundAsset = 'sounds/ouch.mp3';

  bool _isHurt = false;
  Timer? _resetTimer;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // اگه کاربر سریع پشت‌سرهم کلیک کنه، صداها روی هم نیفتن
    _player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    // ۱. پخش صدا (از اول، حتی اگه قبلاً در حال پخش باشه)
    try {
      await _player.stop();
      await _player.play(AssetSource(_soundAsset));
    } catch (e) {
      // اگه صدا نبود یا پلتفرم پشتیبانی نکرد، فقط لاگ کن و ادامه بده
      debugPrint('PainfulLogo: sound playback failed → $e');
    }

    // ۲. تغییر به تصویر دردناک
    if (mounted) {
      setState(() => _isHurt = true);
    }

    // ۳. ریست بعد از مدت مشخص (از آخرین کلیک حساب می‌شه)
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.hurtDuration, () {
      if (mounted) {
        setState(() => _isHurt = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _isHurt
                ? Image.asset(
                    _hurtAsset,
                    key: const ValueKey('hurt'),
                    height: widget.size,
                    width: widget.size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _placeholder(theme, Icons.sentiment_very_dissatisfied),
                  )
                : Image.asset(
                    _normalAsset,
                    key: const ValueKey('normal'),
                    height: widget.size,
                    width: widget.size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _placeholder(theme, Icons.image_not_supported),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme, IconData icon) {
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: theme.colorScheme.primary),
    );
  }
}
