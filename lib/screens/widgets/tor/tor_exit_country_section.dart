// lib/screens/widgets/tor/tor_exit_country_section.dart
import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<String>(
      key: ValueKey(
          'tor-exit:${torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase()}'),
      initialValue:
          torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase(),
      decoration: const InputDecoration(
        labelText: 'Exit country',
        isDense: true,
      ),
      items: torExitCountries
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.isEmpty ? 'Any (random)' : c),
              ))
          .toList(),
      onChanged: onExitCountryChanged,
    );
  }
}
