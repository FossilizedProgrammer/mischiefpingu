// lib/screens/widgets/fluxcore_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';
import '../../services/fluxcore/fluxcore_locations.dart';
import '../../services/fluxcore/fluxcore_paths.dart';
import '../../widgets/settings/port_text_field.dart';
import '../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  FluxcoreSettingsTile — تنظیمات هستهٔ Fluxcore.
///
///  Fluxcore یک پروکسی محلی بدون TUN است: پورت SOCKS5 و پورت HTTP جدا
///  دارد. مسیر (کشور/شهر)، ترنسپورت و مسیر چندهاپ اختیاری همه به خود
///  هسته پاس داده می‌شوند.
///
///  فهرست سرورها از `fluxcore list --locations --json` می‌آید؛ هر
///  ردیف یک لوکیشن (کشور:شهر) با تعداد گیت‌وی و درصد بار است. انتخاب
///  هر ردیف همان مقدار را در مسیر اصلی، یا در حالت چندهاپ در ورودی/
///  خروجی انتخاب‌شده می‌گذارد.
/// ═══════════════════════════════════════════════════════════════
class FluxcoreSettingsTile extends StatefulWidget {
  const FluxcoreSettingsTile({super.key});

  @override
  State<FluxcoreSettingsTile> createState() => _FluxcoreSettingsTileState();
}

class _FluxcoreSettingsTileState extends State<FluxcoreSettingsTile> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _exitController = TextEditingController();
  bool _controllersInitialized = false;
  List<FluxcoreLocation>? _servers;
  bool _loading = false;
  String? _error;

  /// انتخاب از فهرست به کدام مسیر اعمال شود: country / entry / exit.
  String _target = 'country';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final s = context.read<AppProvider>().settings;
      _countryController.text = s.fluxcoreCountry;
      _entryController.text = s.fluxcoreEntry;
      _exitController.text = s.fluxcoreExit;
      _target = s.fluxcoreMultihop ? 'exit' : 'country';
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  String _selectedSelector(AppSettings s) {
    switch (_target) {
      case 'entry':
        return s.fluxcoreEntry;
      case 'exit':
        return s.fluxcoreExit;
      default:
        return s.fluxcoreCountry;
    }
  }

  void _applySelection(AppProvider provider, FluxcoreLocation server) {
    final s = provider.settings;
    switch (_target) {
      case 'entry':
        _entryController.text = server.id;
        s.fluxcoreEntry = server.id;
        break;
      case 'exit':
        _exitController.text = server.id;
        s.fluxcoreExit = server.id;
        break;
      default:
        _countryController.text = server.id;
        s.fluxcoreCountry = server.id;
    }
    provider.saveSettings();
    provider.touch();
    setState(() {});
  }

  Future<void> _loadServers() async {
    if (_loading) return;

    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final binary = await FluxcorePaths.resolveBinary();
      if (binary == null) {
        throw FluxcoreLocationException(l10n.fluxcoreServersError);
      }
      final configHome = await FluxcorePaths.configHome();
      final servers = await FluxcoreLocations.fetch(
        binaryPath: binary,
        configHome: configHome,
      );
      if (!mounted) return;
      setState(() {
        _servers = servers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is FluxcoreLocationException
            ? e.message
            : l10n.fluxcoreServersError;
        _loading = false;
      });
    }
  }

  Color _loadColor(int loadPct) {
    if (loadPct >= 70) return Colors.red.shade600;
    if (loadPct >= 35) return Colors.orange.shade700;
    return Colors.green.shade600;
  }

  Widget _loadBadge(int loadPct) {
    final color = _loadColor(loadPct);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$loadPct%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _serverRow(
    AppProvider provider,
    FluxcoreLocation server,
    String selectedSelector,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final selected = selectedSelector.toLowerCase() == server.id.toLowerCase();

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      selected: selected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => _applySelection(provider, server),
      leading: Text(server.flag, style: const TextStyle(fontSize: 20)),
      title: Text(
        server.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.fluxcoreServerNodes(server.nodes),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            Tooltip(
              message: l10n.fluxcoreServersSelected,
              child: Icon(
                Icons.check_circle,
                size: 17,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
          ],
          _loadBadge(server.loadPct),
        ],
      ),
    );
  }

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
      title: l10n.fluxcoreSettings,
      icon: Icons.cloud_queue_rounded,
      iconBackgroundColor: theme.colorScheme.secondary,
      initiallyExpanded: false,
      trailingWidget: Text(
        provider.fluxcoreStatus,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        SettingsSection(
          label: l10n.fluxcoreConnectionSection,
          children: [
            Row(
              children: [
                Expanded(
                  child: PortTextField(
                    labelText: l10n.fluxcoreSocksPort,
                    initialValue: s.fluxcorePort.toString(),
                    onChanged: (v) {
                      final p = int.tryParse(v.trim());
                      if (p != null && p > 0 && p < 65536) {
                        s.fluxcorePort = p;
                        save();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PortTextField(
                    labelText: l10n.fluxcoreHttpPort,
                    initialValue: s.fluxcoreHttpPort.toString(),
                    onChanged: (v) {
                      final p = int.tryParse(v.trim());
                      if (p != null && p > 0 && p < 65536) {
                        s.fluxcoreHttpPort = p;
                        save();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              l10n.fluxcoreProxySocks(s.fluxcorePort),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            SelectableText(
              l10n.fluxcoreProxyHttp(s.fluxcoreHttpPort),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Divider(height: 28),
        SettingsSection(
          label: l10n.fluxcoreRoutingSection,
          children: [
            if (!s.fluxcoreMultihop) ...[
              SettingsTextField(
                labelText: l10n.fluxcoreCountry,
                hintText: l10n.fluxcoreCountryHint,
                controller: _countryController,
                onChanged: (v) {
                  s.fluxcoreCountry = v.trim();
                  save();
                },
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _loading ? null : _loadServers,
                  icon: const Icon(Icons.dns_outlined, size: 18),
                  label: Text(
                    _servers == null
                        ? l10n.fluxcoreBrowseServers
                        : l10n.fluxcoreRefreshServers,
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.fluxcoreServersLoading,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.fluxcoreServersHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.fluxcoreServersError,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_error!.isNotEmpty && _error != l10n.fluxcoreServersError)
                Text(
                  _error!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
            if (_servers != null && !_loading) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.fluxcoreServersCount(_servers!.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.fluxcoreServersSorted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (s.fluxcoreMultihop) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.fluxcoreChooseTarget,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'entry',
                      label: Text(l10n.fluxcoreTargetEntry),
                      icon: const Icon(Icons.login, size: 16),
                    ),
                    ButtonSegment(
                      value: 'exit',
                      label: Text(l10n.fluxcoreTargetExit),
                      icon: const Icon(Icons.logout, size: 16),
                    ),
                  ],
                  selected: {_target == 'entry' ? 'entry' : 'exit'},
                  onSelectionChanged: (set) {
                    setState(() => _target = set.first);
                  },
                  showSelectedIcon: false,
                ),
              ],
              const SizedBox(height: 2),
              if (_servers!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.fluxcoreServersEmpty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _servers!.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 44,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                      itemBuilder: (_, i) => _serverRow(
                        provider,
                        _servers![i],
                        _selectedSelector(s),
                        l10n,
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            SettingsDropdown<String>(
              labelText: l10n.fluxcoreTransport,
              value: s.fluxcoreTransport,
              items: [
                DropdownMenuItem(
                  value: 'auto',
                  child: Text(l10n.fluxcoreTransportAuto),
                ),
                DropdownMenuItem(
                  value: 'speed',
                  child: Text(l10n.fluxcoreTransportSpeed),
                ),
                DropdownMenuItem(
                  value: 'stealth',
                  child: Text(l10n.fluxcoreTransportStealth),
                ),
              ],
              onChanged: (v) {
                s.fluxcoreTransport = v ?? 'auto';
                save();
              },
            ),
            const SizedBox(height: 4),
            SettingsSwitch(
              title: l10n.fluxcoreMultihop,
              value: s.fluxcoreMultihop,
              onChanged: (v) {
                s.fluxcoreMultihop = v;
                if (v && _target == 'country') _target = 'exit';
                if (!v) _target = 'country';
                save();
              },
            ),
            if (s.fluxcoreMultihop) ...[
              Text(
                l10n.fluxcoreMultihopHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SettingsTextField(
                      labelText: l10n.fluxcoreEntry,
                      controller: _entryController,
                      onChanged: (v) {
                        s.fluxcoreEntry = v.trim();
                        save();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SettingsTextField(
                      labelText: l10n.fluxcoreExit,
                      controller: _exitController,
                      onChanged: (v) {
                        s.fluxcoreExit = v.trim();
                        save();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const Divider(height: 28),
        SettingsSection(
          label: l10n.fluxcoreBehaviorSection,
          children: [
            SettingsSwitch(
              title: l10n.fluxcoreKillSwitch,
              subtitle: l10n.fluxcoreKillSwitchDesc,
              value: s.fluxcoreKillSwitch,
              onChanged: (v) {
                s.fluxcoreKillSwitch = v;
                save();
              },
            ),
            SettingsSwitch(
              title: l10n.fluxcoreAutoReconnect,
              value: s.fluxcoreAutoReconnect,
              onChanged: (v) {
                s.fluxcoreAutoReconnect = v;
                save();
              },
            ),
          ],
        ),
        if (provider.isFluxcoreBusy ||
            provider.processService.isFluxcoreRunning) ...[
          const SizedBox(height: 10),
          Text(
            provider.fluxcoreStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
