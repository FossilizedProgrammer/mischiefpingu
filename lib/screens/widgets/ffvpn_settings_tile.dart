// lib/screens/widgets/ffvpn_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/ffvpn_provider.dart';
import '../../services/ffvpn/ffvpn_service.dart';
import '../../widgets/settings/port_text_field.dart';
import '../../widgets/settings_tile_base.dart';
import 'ffvpn/ffvpn_upstream_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  FirefoxVpnSettingsTile — تنظیمات پروکسی Firefox VPN (ffvpn):
///    • راهنمای گرفتن sessionToken از signedInUser.json
///    • فیلد توکن + پورت‌های SOCKS/HTTP + SNI سفارشی
///    • آپ‌استریم SOCKS (دستی / Psiphon / Tor / SSTP / WireGuard)
///    • انتخاب کشور خروجی + کلید نمایش کشورهای premium
///    • نمایش مصرف سهمیهٔ ماهانهٔ پهنای باند
/// ═══════════════════════════════════════════════════════════════
class FirefoxVpnSettingsTile extends StatelessWidget {
  const FirefoxVpnSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return SettingsTile(
      title: l10n.ffvpnSettings,
      icon: Icons.public_rounded,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        FfvpnGuideSection(theme: theme, l10n: l10n),
        const Divider(height: 28),
        SettingsTextField(
          labelText: l10n.ffvpnTokenLabel,
          hintText: l10n.ffvpnTokenHint,
          initialValue: s.ffvpnSessionToken,
          onChanged: (v) {
            s.ffvpnSessionToken = v.trim();
            save();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PortTextField(
                labelText: l10n.ffvpnPortSocks,
                initialValue: s.ffvpnSocksPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.ffvpnSocksPort = p;
                    save();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortTextField(
                labelText: l10n.ffvpnPortHttp,
                initialValue: s.ffvpnHttpPort.toString(),
                min: 0,
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p >= 0 && p < 65536) {
                    s.ffvpnHttpPort = p;
                    save();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsTextField(
          labelText: l10n.ffvpnSniLabel,
          hintText: l10n.ffvpnSniHint,
          initialValue: s.ffvpnSni,
          onChanged: (v) {
            s.ffvpnSni = v.trim();
            save();
          },
        ),
        const Divider(height: 28),
        FfvpnUpstreamSection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        FfvpnCountrySection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        FfvpnQuotaSection(s: s, theme: theme, l10n: l10n),
      ],
    );
  }
}

/// راهنمای گرفتن sessionToken از signedInUser.json.
class FfvpnGuideSection extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;

  const FfvpnGuideSection({
    super.key,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      label: l10n.ffvpnGuideTitle,
      children: [
        _guideLine(theme, l10n.ffvpnGuideIntro),
        const SizedBox(height: 8),
        _guideLine(theme, l10n.ffvpnGuideStep1),
        const SizedBox(height: 4),
        _guideLine(theme, l10n.ffvpnGuideStep2),
        const SizedBox(height: 4),
        _guideLine(theme, l10n.ffvpnGuideStep3),
        const SizedBox(height: 10),
        SettingsContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                l10n.ffvpnPathWindows,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                l10n.ffvpnPathLinux,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _guideLine(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// انتخاب کشور خروجی + کلید نمایش کشورهای premium.
class FfvpnCountrySection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const FfvpnCountrySection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final ffvpn = context.watch<FfvpnProvider>();

    return SettingsSection(
      label: l10n.ffvpnCountrySection,
      children: [
        SettingsSwitch(
          title: l10n.ffvpnShowPremium,
          subtitle: l10n.ffvpnShowPremiumDesc,
          value: s.ffvpnShowPremiumCountries,
          onChanged: (v) {
            s.ffvpnShowPremiumCountries = v;
            onSave();
            // لیست را با تنظیم جدید دوباره بگیر (پیش‌فرض: پنهان).
            // ignore: discarded_futures
            ffvpn.loadCountries(includePremium: v, force: true);
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: ffvpn.isLoadingCountries
                  ? null
                  : () {
                      // ignore: discarded_futures
                      ffvpn.loadCountries(
                        includePremium: s.ffvpnShowPremiumCountries,
                        force: true,
                      );
                    },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.ffvpnLoadCountries),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (ffvpn.isLoadingCountries) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (ffvpn.isLoadingCountries)
          Text(
            l10n.ffvpnCountriesLoading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else if (ffvpn.countriesError != null)
          Text(
            FfvpnUiHelpers.errorText(l10n, ffvpn.countriesError!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        else if (!ffvpn.hasCountries)
          Text(
            l10n.ffvpnCountriesEmpty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          SettingsDropdown<String>(
            labelText: l10n.ffvpnCountrySection,
            value: s.ffvpnCountry.trim().toUpperCase(),
            items: _dropdownItems(ffvpn),
            onChanged: (v) {
              s.ffvpnCountry = v ?? '';
              onSave();
            },
          ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems(FfvpnProvider ffvpn) {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '',
        child: Text(l10n.ffvpnCountryAuto),
      ),
    ];
    for (final c in ffvpn.countries) {
      final label = c.locked
          ? '${c.code} · ${c.name} — ${l10n.ffvpnPremiumTag}'
          : '${c.code} · ${c.name}';
      items.add(DropdownMenuItem<String>(value: c.code, child: Text(label)));
    }
    // کشور انتخاب‌شده که در لیست فعلی نیست را هم اضافه کن.
    final saved = s.ffvpnCountry.trim().toUpperCase();
    if (saved.isNotEmpty && !ffvpn.countries.any((c) => c.code == saved)) {
      items.add(DropdownMenuItem<String>(value: saved, child: Text(saved)));
    }
    return items;
  }
}

/// نمایش مصرف سهمیهٔ ماهانهٔ پهنای باند.
class FfvpnQuotaSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;

  const FfvpnQuotaSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final ffvpn = context.watch<FfvpnProvider>();
    final hasToken = s.ffvpnSessionToken.trim().isNotEmpty;
    final usage = ffvpn.usage;

    return SettingsSection(
      label: l10n.ffvpnQuotaSection,
      children: [
        SettingsActionRow(
          children: [
            FilledButton.tonalIcon(
              onPressed: ffvpn.isLoadingUsage || !hasToken
                  ? null
                  : () {
                      // ignore: discarded_futures
                      ffvpn.refreshUsage(sessionToken: s.ffvpnSessionToken);
                    },
              icon: const Icon(Icons.data_usage, size: 18),
              label: Text(l10n.ffvpnCheckQuota),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!hasToken)
          Text(
            l10n.ffvpnQuotaNoToken,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else if (ffvpn.isLoadingUsage) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 6),
          Text(
            l10n.ffvpnQuotaLoading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ] else if (ffvpn.usageError != null)
          Text(
            FfvpnUiHelpers.errorText(l10n, ffvpn.usageError!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        else if (usage != null && usage.unlimited)
          SettingsInfoCard(
            message: l10n.ffvpnQuotaUnlimited,
            icon: Icons.all_inclusive,
          )
        else if (usage != null) ...[
          LinearProgressIndicator(
            value: usage.usedFraction,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ffvpnQuotaUsedOf(
              FfvpnService.formatBytes(usage.usedBytes),
              FfvpnService.formatBytes(usage.limitBytes),
              '${((usage.usedFraction ?? 0) * 100).round()}',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.ffvpnQuotaLeft(FfvpnService.formatBytes(usage.remainingBytes)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (usage.reset != null) ...[
            const SizedBox(height: 2),
            Text(
              l10n.ffvpnQuotaResets(_formatDate(usage.reset!)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }

  static String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}

/// نگاشت خطاهای FfvpnException به متن لوکال‌شده.
class FfvpnUiHelpers {
  FfvpnUiHelpers._();

  static String errorText(AppLocalizations l10n, FfvpnException e) {
    switch (e.kind) {
      case FfvpnErrorKind.notEntitled:
        return l10n.ffvpnErrNotEntitled;
      case FfvpnErrorKind.region:
        return l10n.ffvpnErrRegion;
      case FfvpnErrorKind.badToken:
        return l10n.ffvpnErrBadToken;
      case FfvpnErrorKind.quota:
        return l10n.ffvpnErrQuota;
      case FfvpnErrorKind.binaryMissing:
        return l10n.ffvpnErrBinaryMissing;
      case FfvpnErrorKind.network:
        return l10n.ffvpnErrNetwork;
      case FfvpnErrorKind.other:
        return '${l10n.ffvpnErrOther}: ${e.detail}';
    }
  }
}
