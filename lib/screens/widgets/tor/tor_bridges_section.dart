import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/bridge_scanner_provider.dart';
import '../../../services/tor_bridges.dart';

class TorBridgesSection extends StatefulWidget {
  final ThemeData theme;
  final String torTransport;
  final String torBridges;
  final ValueChanged<String> onBridgesChanged;
  final ValueChanged<String?> onTransportChanged;
  const TorBridgesSection({
    super.key,
    required this.theme,
    required this.torTransport,
    required this.torBridges,
    required this.onBridgesChanged,
    required this.onTransportChanged,
  });

  @override
  State<TorBridgesSection> createState() => _TorBridgesSectionState();
}

class _TorBridgesSectionState extends State<TorBridgesSection> {
  late final TextEditingController _bridgesController;

  @override
  void initState() {
    super.initState();
    _bridgesController = TextEditingController(text: widget.torBridges);
  }

  @override
  void dispose() {
    _bridgesController.dispose();
    super.dispose();
  }

  void _applyPreset(String bridges) {
    widget.onTransportChanged('bridge');
    widget.onBridgesChanged(bridges);
    setState(() {
      _bridgesController.text = bridges;
    });
    context.read<AppProvider>().touch();
  }

  void _clearBridges() {
    widget.onBridgesChanged('');
    setState(() {
      _bridgesController.clear();
    });
    context.read<AppProvider>().touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  🆕 بارگذاری بریج‌های ذخیره‌شده از BridgeScannerProvider
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _loadFromBridgeScanner(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scanner = context.read<BridgeScannerProvider>();

    // اطمینان از اینکه saved bridges لود شده
    await scanner.initSavedBridges();
    if (!context.mounted) return;

    final saved = scanner.savedBridges;
    if (saved.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bridgeNoSavedInScanner),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final bridgesText = saved.join('\n');
    widget.onTransportChanged('bridge');
    widget.onBridgesChanged(bridgesText);
    setState(() {
      _bridgesController.text = bridgesText;
    });
    context.read<AppProvider>().touch();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.bridgeLoadedSuccess(saved.length)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);
    final scanner = context.watch<BridgeScannerProvider>();
    final savedCount = scanner.savedBridges.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // ═══════════════════════════════════════════════════════════
        //  🆕 دکمه بارگذاری از Bridge Scanner
        // ═══════════════════════════════════════════════════════════
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bridgeLoadFromScanner,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          savedCount == 0
                              ? l10n.bridgeNoSavedInScanner
                              : l10n.bridgeSavedCount(savedCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: savedCount == 0
                        ? null
                        : () => _loadFromBridgeScanner(context),
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: Text(l10n.bridgeLoadSaved),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ─── Presetها ───
        Text(
          l10n.bridgePresets,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _applyPreset(TorBridges.meekCdn77),
              child: const Text('Meek'),
            ),
            OutlinedButton(
              onPressed: () => _applyPreset(TorBridges.snowflakeCdn77),
              child: const Text('Snowflake'),
            ),
            OutlinedButton(
              onPressed: () => _applyPreset(TorBridges.obfs4Iat.join('\n')),
              child: const Text('obfs4 (anti-timing)'),
            ),
            OutlinedButton(
              onPressed: () => _applyPreset(TorBridges.obfs4Public.join('\n')),
              child: const Text('obfs4 (public)'),
            ),
            TextButton(onPressed: _clearBridges, child: Text(l10n.clear)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bridgesController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l10n.bridges,
            hintText: l10n.bridgesHint,
            alignLabelWithHint: true,
          ),
          onChanged: (v) {
            final provider = context.read<AppProvider>();
            provider.settings.torBridges = v;
            provider.saveSettings();
            widget.onBridgesChanged(v);
          },
        ),
      ],
    );
  }
}
