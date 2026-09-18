import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/settings_tile_base.dart';
import 'app_localizations.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SettingsTile(
      title: l10n.language,
      icon: Icons.language,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      trailingText: _langLabel(localeProvider.locale.languageCode),
      children: [
        RadioGroup<String>(
          groupValue: localeProvider.locale.languageCode,
          onChanged: (v) {
            if (v == null) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              localeProvider.setLocale(v);
            });
          },
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'en',
                title: Text(l10n.languageEnglish),
              ),
              RadioListTile<String>(
                value: 'fa',
                title: Text(l10n.languageFarsi),
              ),
              RadioListTile<String>(
                value: 'ru',
                title: Text(l10n.languageRussian),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _langLabel(String code) {
    switch (code) {
      case 'fa':
        return 'فارسی';
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }
}
