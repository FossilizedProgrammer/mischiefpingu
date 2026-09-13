import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/app_provider.dart';

class ThemeSelectorTile extends StatelessWidget {
  const ThemeSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final currentInfo = getThemeInfo(s.themeId);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: EdgeInsets.zero,
          backgroundColor:
              theme.colorScheme.tertiaryContainer.withValues(alpha: 0.28),
          collapsedBackgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentInfo.seedColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  currentInfo.icon,
                  size: 20,
                  color: currentInfo.seedColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Appearance',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                currentInfo.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Theme',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a color scheme for the entire app.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: appThemes.map((t) {
                        final isSelected = s.themeId == t.id;
                        return ThemeChip(
                          info: t,
                          isSelected: isSelected,
                          onTap: () {
                            s.themeId = t.id;
                            save();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeChip extends StatelessWidget {
  final AppThemeInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeChip({
    super.key,
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? info.seedColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? info.seedColor
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: info.seedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              info.icon,
              size: 16,
              color: isSelected
                  ? info.seedColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              info.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? info.seedColor : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
