// lib/screens/widgets/main_app_bar.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
      title: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.appTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                l10n.appSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 12),
          child: const PainfulLogo(size: 80),
        ),
      ]),
      toolbarHeight: 70,
    );
  }
}
