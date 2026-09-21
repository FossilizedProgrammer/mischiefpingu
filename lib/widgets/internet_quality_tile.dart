import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/internet_quality_provider.dart';
import 'diagnostics/internet_quality_card.dart';
import 'settings_tile_base.dart';

class InternetQualityTile extends StatefulWidget {
  const InternetQualityTile({super.key});

  @override
  State<InternetQualityTile> createState() => _InternetQualityTileState();
}

class _InternetQualityTileState extends State<InternetQualityTile> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<InternetQualityProvider>();
      provider.autoStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InternetQualityProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SettingsTile(
      title: l10n.internetQuality,
      icon: Icons.speed,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        InternetQualityCard(
          result: provider.result,
          isLoading: provider.isLoading,
          onTest: () async {
            await provider.testNow();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.result == null
                      ? l10n.internetQualityNoResult
                      : '${l10n.internetQualitySnackbar} '
                            '${provider.result!.probableCause}',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          level: provider.level,
          onLevelChanged: provider.setLevel,
        ),
      ],
    );
  }
}
