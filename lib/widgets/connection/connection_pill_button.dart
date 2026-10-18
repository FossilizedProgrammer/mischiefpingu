import 'package:flutter/material.dart';

/// ConnectionPillButton — دکمهٔ اتصال فشرده به سبک «آرورا».
///
/// جایگزین دکمهٔ دایره‌ای بزرگ است: یک قرص (pill) کوچک و مستقل که در یک
/// ردیف کنار بقیه می‌نشیند. حالت غیرفعال مات و آرام است؛ با اتصال، پس‌زمینه
/// گرادیانی رنگی و هاله (glow) می‌گیرد. در حین اتصال، درصد پیشرفت (به‌صورت
/// نوشته و یک نوار باریک) نمایش داده می‌شود.
class ConnectionPillButton extends StatelessWidget {
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

  const ConnectionPillButton({
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
    final active = connected || busy;

    final subtitle = progress != null ? '$progress%' : statusText;
    final subtitleColor = active
        ? Colors.white.withValues(alpha: 0.92)
        : statusColor;
    final titleColor =
        active ? Colors.white : theme.colorScheme.onSurface;

    return Tooltip(
      message: '$title — $actionLabel',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(6, 9, 6, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(color, Colors.white, 0.28)!,
                        color,
                        Color.lerp(color, Colors.black, 0.18)!,
                      ],
                    )
                  : null,
              color: active
                  ? null
                  : color.withValues(alpha: isDark ? 0.12 : 0.08),
              border: Border.all(
                color: active
                    ? Colors.white.withValues(alpha: 0.28)
                    : color.withValues(alpha: 0.35),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: isDark ? 0.55 : 0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _leading(),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (busy && progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress! / 100.0,
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    if (busy && progress == null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return Icon(
      icon,
      size: 20,
      color: (busy || connected) ? Colors.white : color,
    );
  }
}
