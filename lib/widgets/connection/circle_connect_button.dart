import 'package:flutter/material.dart';
import 'compass_ticks_painter.dart';

class CircleConnectButton extends StatelessWidget {
  final String title;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final bool busy;
  final bool connected;
  final VoidCallback onTap;
  final int? progress;
  final String statusText;
  final Color statusColor;

  const CircleConnectButton({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.busy,
    required this.connected,
    required this.onTap,
    required this.statusText,
    required this.statusColor,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(106, 106),
                  painter: CompassTicksPainter(
                    color: color,
                    active: connected || busy,
                    isDark: isDark,
                  ),
                ),
                if (connected || busy)
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                if (busy && progress == null)
                  const SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white70),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                if (progress != null)
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.2,
                      value: progress! / 100.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white70),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(color, Colors.white, 0.22)!,
                        color,
                        Color.lerp(color, Colors.black, 0.15)!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: isDark ? 0.5 : 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: Colors.white, size: 26),
                          const SizedBox(height: 2),
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
            fontSize: progress != null ? 12 : 11,
          ),
        ),
      ],
    );
  }
}
