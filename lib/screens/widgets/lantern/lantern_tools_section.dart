// lib/screens/widgets/lantern/lantern_tools_section.dart
//
// ابزارهای CLI لنترن داخل برنامه:
//   • servers → بروزرسانی/بررسی و نمایش لیست سرورها به‌صورت کومبوباکس
//   • auth    → login / signup / logout
//
// خروجی فرمان‌ها در پنل لاگ (منبع Lantern) می‌آید.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/lantern_provider.dart';
import '../../../widgets/settings_tile_base.dart';

class LanternToolsSection extends StatefulWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const LanternToolsSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<LanternToolsSection> createState() => _LanternToolsSectionState();
}

class _LanternToolsSectionState extends State<LanternToolsSection> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  String? _selectedServerAddr;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  AppSettings get s => widget.s;
  AppLocalizations get l10n => widget.l10n;
  ThemeData get theme => widget.theme;

  Future<void> _run(
    LanternProvider lantern,
    List<String> args, {
    required String label,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    await lantern.runCommand(s, args, label: label, timeout: timeout);
    if (mounted) setState(() {});
  }

  Widget _reachIcon(bool? reachable) {
    if (reachable == true) {
      return Tooltip(
        message: l10n.lanternServerReachable,
        child: Icon(Icons.check_circle, size: 16, color: Colors.green),
      );
    }
    if (reachable == false) {
      return Tooltip(
        message: l10n.lanternServerUnreachable,
        child: Icon(Icons.cancel, size: 16, color: Colors.red),
      );
    }
    return Tooltip(
      message: l10n.lanternServerNotChecked,
      child: Icon(Icons.help_outline, size: 16, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final lantern = context.watch<LanternProvider>();
    final busy = lantern.isRunningCommand || lantern.isLoadingServers;

    final addrs = lantern.servers.map((e) => e.address).toSet();
    if (_selectedServerAddr != null && !addrs.contains(_selectedServerAddr)) {
      _selectedServerAddr = null;
    }

    return SettingsSection(
      label: l10n.lanternToolsSection,
      children: [
        // ─── سرورها ───
        Text(
          l10n.lanternToolsServers,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            TextButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      await lantern.loadServers(s, refresh: true);
                      if (mounted) setState(() {});
                    },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.lanternToolsRefreshServers),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      await lantern.loadServers(s, refresh: true, check: true);
                      if (mounted) setState(() {});
                    },
              icon: const Icon(Icons.network_check, size: 18),
              label: Text(l10n.lanternToolsCheckServers),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        if (lantern.isLoadingServers) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            minHeight: 2,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        if (lantern.serversError != null) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.lanternToolsServers}: ${lantern.serversError}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
        if (lantern.hasServers) ...[
          const SizedBox(height: 10),
          InputDecorator(
            decoration: InputDecoration(
              labelText:
                  '${l10n.lanternToolsServers} (${lantern.servers.length})',
              isDense: true,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedServerAddr,
                isExpanded: true,
                hint: Text(l10n.lanternToolsServers),
                items: lantern.servers.map((srv) {
                  final loc = [
                    srv.countryCode,
                    srv.country,
                    srv.city,
                  ].where((e) => e.isNotEmpty).join(' · ');
                  return DropdownMenuItem(
                    value: srv.address,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.isEmpty ? srv.name : '${srv.name} — $loc',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _reachIcon(srv.reachable),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedServerAddr = v),
              ),
            ),
          ),
        ],
        const Divider(height: 28),

        // ─── احراز هویت ───
        Text(
          l10n.lanternToolsAuth,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: l10n.lanternEmailLabel,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.lanternPasswordLabel,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: busy
                  ? null
                  : () => _run(
                        lantern,
                        lantern.cliFor(s).authArgs(
                              'login',
                              email: _emailCtrl.text,
                              password: _passwordCtrl.text,
                            ),
                        label: 'auth login',
                      ),
              icon: const Icon(Icons.login, size: 18),
              label: Text(l10n.lanternLoginBtn),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: busy
                  ? null
                  : () => _run(
                        lantern,
                        lantern.cliFor(s).authArgs(
                              'signup',
                              email: _emailCtrl.text,
                              password: _passwordCtrl.text,
                            ),
                        label: 'auth signup',
                      ),
              icon: const Icon(Icons.person_add, size: 18),
              label: Text(l10n.lanternSignupBtn),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: busy
                  ? null
                  : () => _run(
                        lantern,
                        lantern.cliFor(s).authArgs('logout'),
                        label: 'auth logout',
                      ),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l10n.lanternLogoutBtn),
            ),
          ],
        ),
        if (busy) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.lanternRunning}: ${lantern.runningLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        if (provider.isLanternBusy) ...[
          const SizedBox(height: 8),
          Text(
            provider.lanternStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
