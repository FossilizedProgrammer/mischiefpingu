// lib/screens/widgets/npv/npv_config_section.dart
//
// فایل کانفیگ NPV (.npvs) که هسته باید باز کند.
//
// فایل کپی‌شده داخل پوشهٔ داده می‌ماند تا بعد از جابه‌جا شدن اصل فایل در
// سیستم، اتصال نشکند. هیچ فایل پیش‌فرضی از قبل انتخاب نشده است.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../providers/app_provider.dart';
import '../../../services/npv/npv_paths.dart';
import '../../../widgets/settings_tile_base.dart';

class NpvConfigSection extends StatefulWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const NpvConfigSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<NpvConfigSection> createState() => _NpvConfigSectionState();
}

class _NpvConfigSectionState extends State<NpvConfigSection> {
  bool _busy = false;
  String? _error;

  AppLocalizations get l10n => widget.l10n;
  ThemeData get theme => widget.theme;

  Future<void> _pickFile() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: l10n.npvPickConfigFile,
      type: FileType.custom,
      allowedExtensions: const ['npvs', 'txt'],
    );

    if (!mounted) return;
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final name = await NpvPaths.importConfig(path);
      widget.s.npvConfigName = name;
      widget.onSave();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.npvConfigLoaded(name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = l10n.npvConfigReadError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clear() {
    widget.s.npvConfigName = '';
    widget.onSave();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isRunning = provider.processService.isNpvRunning;
    final name = widget.s.npvConfigName.trim();
    final hasFile = name.isNotEmpty;

    return SettingsSection(
      label: l10n.npvConfigSection,
      children: [
        Text(
          l10n.npvConfigDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              hasFile ? Icons.description : Icons.error_outline,
              size: 18,
              color: hasFile
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasFile ? name : l10n.npvNoConfigFile,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                  color: hasFile
                      ? null
                      : theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFile)
              TextButton.icon(
                onPressed: _busy || isRunning ? null : _clear,
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.npvClearConfigFile),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 6),
            FilledButton.tonalIcon(
              onPressed: _busy || isRunning ? null : _pickFile,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open, size: 18),
              label: Text(
                hasFile ? l10n.npvChangeConfigFile : l10n.npvPickConfigFile,
              ),
            ),
          ],
        ),
        if (isRunning) ...[
          const SizedBox(height: 8),
          Text(
            l10n.npvConfigLockedWhileRunning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
