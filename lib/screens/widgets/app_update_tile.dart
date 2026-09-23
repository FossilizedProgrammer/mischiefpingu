import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'app_update/app_update_state.dart';
import 'app_update/app_update_info_row.dart';

class AppUpdateTile extends StatefulWidget {
  const AppUpdateTile({super.key});

  @override
  State<AppUpdateTile> createState() => _AppUpdateTileState();
}

class _AppUpdateTileState extends State<AppUpdateTile> {
  late final AppUpdateStateManager _state;

  @override
  void initState() {
    super.initState();
    _state = AppUpdateStateManager(
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state.ensureInitialized(context);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context);
    final app = context.read<AppProvider>();
    await _state.download(
      context: context,
      l10n: l10n,
      app: app,
      onSnackBar: (msg, action) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: action,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final info = _state.info;

    return SettingsTile(
      title: l10n.appUpdate,
      icon: Icons.system_update_alt,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      trailingText:
          info != null && info.hasUpdate ? l10n.appUpdateAvailable : null,
      children: [
        if (info != null) ...[
          AppUpdateInfoRow(
            label: l10n.appUpdateCurrentVersion,
            value: info.currentVersion,
            theme: theme,
          ),
          const SizedBox(height: 6),
          AppUpdateInfoRow(
            label: l10n.appUpdateLatestVersion,
            value: info.latestVersion,
            theme: theme,
            highlight: info.hasUpdate,
          ),
          const SizedBox(height: 12),
        ],
        if (_state.message.isNotEmpty) ...[
          Text(
            _state.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_state.downloading) ...[
          LinearProgressIndicator(value: _state.progress / 100),
          const SizedBox(height: 8),
          Text('${_state.progress}%', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            OutlinedButton.icon(
              onPressed:
                  _state.checking || _state.downloading || !_state.serviceReady
                      ? null
                      : () => _state.check(context: context),
              icon: _state.checking
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                _state.checking ? l10n.appUpdateChecking : l10n.appUpdateCheck,
              ),
            ),
            const SizedBox(width: 8),
            if (info != null && info.hasUpdate)
              Expanded(
                child: FilledButton.icon(
                  onPressed: _state.downloading
                      ? () => _state.requestCancel()
                      : _download,
                  icon: Icon(
                    _state.downloading ? Icons.stop : Icons.download,
                    size: 18,
                  ),
                  label: Text(
                    _state.downloading ? l10n.stop : l10n.appUpdateDownload,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _state.downloading
                        ? Colors.red
                        : theme.colorScheme.primary,
                  ),
                ),
              )
            else if (info != null)
              Expanded(
                child: Text(
                  l10n.appUpdateUpToDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
