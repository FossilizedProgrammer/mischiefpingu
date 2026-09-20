library;

import 'package:flutter/material.dart';

import '../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthHelpers — توابع کمکی برای رنگ و فرمت.
/// ═══════════════════════════════════════════════════════════════
class HealthHelpers {
  HealthHelpers._();

  static Color latencyColor(int ms) {
    if (ms < 300) return Colors.green;
    if (ms < 800) return Colors.amber;
    return Colors.red;
  }

  static Color jitterColor(int ms) {
    if (ms < 50) return Colors.green;
    if (ms < 150) return Colors.amber;
    return Colors.red;
  }

  static Color lossColor(double pct) {
    if (pct < 1) return Colors.green;
    if (pct < 10) return Colors.amber;
    return Colors.red;
  }

  static Color trendColor(HealthTrend t) {
    switch (t) {
      case HealthTrend.improving:
        return Colors.green;
      case HealthTrend.stable:
        return Colors.blue;
      case HealthTrend.degrading:
        return Colors.orange;
    }
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }

  static String formatBytes(int bytes) {
    if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)}MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)}KB';
    }
    return '${bytes}B';
  }
}
