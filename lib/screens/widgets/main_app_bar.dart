import 'package:flutter/material.dart';
import '../../widgets/painful_logo.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mischief Pingu',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Unofficial Psiphon client ,Aether client, Tor client, SSTP client',
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
