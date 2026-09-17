// lib/screens/widgets/tor/tor_exit_country_section.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TorExitCountrySection extends StatelessWidget {
  final String torExitCountry;
  final ValueChanged<String?> onExitCountryChanged;
  final List<String> torExitCountries;

  const TorExitCountrySection({
    super.key,
    required this.torExitCountry,
    required this.onExitCountryChanged,
    required this.torExitCountries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey(
          'tor-exit:${torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase()}'),
      initialValue: torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase(),
      decoration: InputDecoration(
        labelText: l10n.exitCountry,
        isDense: true,
      ),
      items: torExitCountries
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.isEmpty ? l10n.exitCountryAny : c),
              ))
          .toList(),
      onChanged: onExitCountryChanged,
    );
  }
}
