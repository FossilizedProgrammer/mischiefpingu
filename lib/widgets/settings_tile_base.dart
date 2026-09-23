import 'package:flutter/material.dart';

export 'settings/settings_primitives.dart';
export 'settings/settings_fields.dart';
export 'settings/settings_feedback.dart';

/// کارت اصلی تنظیمات با ExpansionTile.
class SettingsTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final String? trailingText;
  final Widget? trailingWidget;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color? iconBackgroundColor;
  final IconData? icon;
  final Gradient? titleGradient;

  const SettingsTile({
    super.key,
    required this.title,
    required this.children,
    this.leading = const SizedBox.shrink(),
    this.trailingText,
    this.trailingWidget,
    this.initiallyExpanded = false,
    this.iconBackgroundColor,
    this.icon,
    this.titleGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBgColor = iconBackgroundColor ?? theme.colorScheme.primary;
    final iconData = icon ?? Icons.settings;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      color: theme.cardTheme.color ??
          (theme.brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          backgroundColor: iconBgColor.withValues(alpha: 0.05),
          collapsedBackgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: titleGradient ??
                      LinearGradient(
                        colors: [
                          iconBgColor.withValues(alpha: 0.15),
                          iconBgColor.withValues(alpha: 0.05),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: leading is Icon
                    ? leading
                    : Icon(iconData, size: 20, color: iconBgColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (trailingWidget != null)
                trailingWidget!
              else if (trailingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: iconBgColor,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
