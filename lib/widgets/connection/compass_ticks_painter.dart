import 'dart:math' as math;

import 'package:flutter/material.dart';

/// نقاش خطوط درجه‌بندی دور دایره (شبیه قطب‌نما).
class CompassTicksPainter extends CustomPainter {
  final Color color;
  final bool active;
  final bool isDark;

  CompassTicksPainter({
    required this.color,
    required this.active,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int majorTicks = 12;
    const int minorTicks = 60;

    for (int i = 0; i < minorTicks; i++) {
      final angle = (i * 360 / minorTicks) * math.pi / 180 - math.pi / 2;
      final isMajor = i % (minorTicks ~/ majorTicks) == 0;
      final double tickLength = isMajor ? 5.0 : 2.5;
      final double strokeWidth = isMajor ? 2.0 : 1.1;
      final opacity = active
          ? (isMajor ? 0.85 : 0.45)
          : (isMajor ? 0.35 : 0.18);

      paint
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth;

      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: active ? 0.35 : 0.12);
    canvas.drawCircle(center, radius + 1, paint);
  }

  @override
  bool shouldRepaint(covariant CompassTicksPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.active != active ||
        oldDelegate.isDark != isDark;
  }
}
