library;

import 'package:flutter/material.dart';
import 'logo_mode.dart';

class LogoAssets {
  LogoAssets._();

  static const String normal = 'assets/images/logo.png';
  static const String hurt = 'assets/images/logo_hurt.png';
  static const String sad = 'assets/images/logo_sad.png';
  static const String happy = 'assets/images/logo_happy.png';
  static const String hi = 'assets/images/logo_hi.png';
}

class LogoAssetResolver {
  final double size;
  const LogoAssetResolver({required this.size});

  /// رزولوشن تصویر مناسب برای هر mode.
  Widget resolve(LogoMode mode, ThemeData theme) {
    switch (mode) {
      case LogoMode.hurt:
        return _asset(
          LogoAssets.hurt,
          'hurt',
          fallbackIcon: Icons.sentiment_very_dissatisfied,
          theme: theme,
        );
      case LogoMode.sad:
        return _asset(
          LogoAssets.sad,
          'sad',
          fallbackIcon: Icons.sentiment_dissatisfied,
          theme: theme,
        );
      case LogoMode.happy:
        return _asset(
          LogoAssets.happy,
          'happy',
          fallbackIcon: Icons.sentiment_very_satisfied,
          theme: theme,
        );
      case LogoMode.hi:
        return _asset(
          LogoAssets.hi,
          'hi',
          fallbackIcon: Icons.waving_hand,
          theme: theme,
        );
      case LogoMode.normal:
        return _asset(
          LogoAssets.normal,
          'normal',
          fallbackIcon: Icons.image_not_supported,
          theme: theme,
        );
    }
  }

  Widget _asset(
    String path,
    String key, {
    required IconData fallbackIcon,
    required ThemeData theme,
  }) {
    return Image.asset(
      path,
      key: ValueKey(key),
      height: size,
      width: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(theme, fallbackIcon),
    );
  }

  Widget _placeholder(ThemeData theme, IconData icon) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: theme.colorScheme.primary),
    );
  }
}
