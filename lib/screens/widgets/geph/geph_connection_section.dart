// lib/screens/widgets/geph/geph_connection_section.dart
//
// پورت‌های SOCKS/HTTP، کشور خروجی و اشتراک در شبکهٔ محلی برای گف.
//
// فیلتر لیست کشورها از روی پرچم `free` هر خروجی کار می‌کند (هم‌معنیِ
// `geph5-proxy countries --level`). لیست کامل یک‌بار گرفته می‌شود و فیلتر
// فقط نمایش را محدود می‌کند تا با تغییر فیلتر نیازی به درخواست تازه نباشد.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../providers/geph_provider.dart';
import '../../../services/geph/geph_cli_service.dart';
import '../../../widgets/settings/port_text_field.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  GephConnectionSection — پورت‌ها و کشور خروجی geph5-proxy.
/// ═══════════════════════════════════════════════════════════════
class GephConnectionSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const GephConnectionSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  /// فیلتر نمایش لیست کشورها: `all` | `free` | `plus`.
  ///
  /// در تنظیمات ذخیره می‌شود تا با باز کردن دوبارهٔ تنظیمات، همان گزینه
  /// انتخاب‌شده بماند.
  bool _matchesFilter(String level, GephCountryInfo c) {
    if (level == 'all') return true;
    return (c.free ? 'free' : 'plus') == level;
  }

  @override
  Widget build(BuildContext context) {
    final geph = context.watch<GephProvider>();

    final current =
        s.gephCountry.trim().isEmpty ? 'auto' : s.gephCountry.trim().toUpperCase();
    final level = s.gephCountryFilter;
    final visible = geph.countries.where((c) => _matchesFilter(level, c));
    final byCode = {for (final c in visible) c.code: c};
    final codes = <String>['auto', ...byCode.keys];
    if (!codes.contains(current)) codes.add(current);

    return SettingsSection(
      label: l10n.gephConnectionSection,
      children: [
        Row(
          children: [
            Expanded(
              child: PortTextField(
                labelText: l10n.gephPortSocks,
                initialValue: s.gephSocksPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.gephSocksPort = p;
                    onSave();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortTextField(
                labelText: l10n.gephPortHttp,
                initialValue: s.gephHttpPort.toString(),
                min: 0,
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p >= 0 && p < 65536) {
                    s.gephHttpPort = p;
                    onSave();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: const ValueKey('geph-country'),
                initialValue: current,
                decoration: InputDecoration(
                  labelText: l10n.gephCountry,
                  isDense: true,
                ),
                items: codes.map((code) {
                  final info = byCode[code];
                  final label = code == 'auto'
                      ? l10n.gephCountryAuto
                      : (info == null ? code : info.label);
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  s.gephCountry = (v == null || v.isEmpty) ? 'auto' : v;
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: l10n.gephCountryRefresh,
              onPressed: geph.isLoadingCountries
                  ? null
                  : () => geph.loadCountries(s),
              icon: geph.isLoadingCountries
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const ValueKey('geph-country-filter'),
          initialValue: level,
          decoration: InputDecoration(
            labelText: l10n.gephCountryFilter,
            isDense: true,
          ),
          items: [
            DropdownMenuItem(
              value: 'all',
              child: Text(l10n.gephCountryFilterAll),
            ),
            DropdownMenuItem(
              value: 'free',
              child: Text(l10n.gephCountryFilterFree),
            ),
            DropdownMenuItem(
              value: 'plus',
              child: Text(l10n.gephCountryFilterPlus),
            ),
          ],
          onChanged: (v) {
            s.gephCountryFilter = v ?? 'all';
            onSave();
          },
        ),
        if (geph.countriesError != null) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.gephCountryRefresh}: ${geph.countriesError}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
        const SizedBox(height: 4),
        SettingsSwitch(
          title: l10n.shareOnLan,
          value: s.gephShareLan,
          onChanged: (v) {
            s.gephShareLan = v;
            onSave();
          },
        ),
      ],
    );
  }
}
