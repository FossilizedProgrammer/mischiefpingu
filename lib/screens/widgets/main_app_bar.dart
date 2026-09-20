import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_version_service.dart';
import '../../widgets/painful_logo.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── ردیف اول: عنوان + بج نسخه ───
                Row(
                  children: [
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    _VersionBadge(theme: theme),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: const PainfulLogo(size: 80),
          ),
        ],
      ),
      toolbarHeight: 70,
    );
  }
}

/// بج کوچک نمایش نسخه — از pubspec.yaml خوانده می‌شود.
class _VersionBadge extends StatelessWidget {
  final ThemeData theme;

  const _VersionBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppVersionService.getVersion(),
      builder: (context, snapshot) {
        final v = snapshot.data ?? '';
        if (v.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'v$v',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
