import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cdn_scanner_provider.dart';
import 'settings_tile_base.dart';
import 'cdn_scanner/cdn_scanner_controller.dart';
import 'cdn_scanner/cdn_scanner_inputs.dart';
import 'cdn_scanner/cdn_scanner_results.dart';
import 'cdn_scanner/cdn_custom_ips_manager.dart';

class CdnScannerSection extends StatefulWidget {
  const CdnScannerSection({super.key});

  @override
  State<CdnScannerSection> createState() => _CdnScannerSectionState();
}

class _CdnScannerSectionState extends State<CdnScannerSection> {
  final _inputCtrl = TextEditingController();
  final _sniCtrl = TextEditingController();
  late final CdnScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CdnScannerController(
      inputCtrl: _inputCtrl,
      sniCtrl: _sniCtrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputCtrl.dispose();
    _sniCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<CdnScannerProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // sync controllerها با state provider
    _controller.sync(scan);

    return SettingsTile(
      title: l10n.cdnScanner,
      icon: Icons.search,
      trailingText: scan.good.isNotEmpty ? '${scan.good.length} usable' : null,
      iconBackgroundColor: theme.colorScheme.secondary,
      children: [
        CdnScannerInputs(
          scan: scan,
          inputCtrl: _inputCtrl,
          sniCtrl: _sniCtrl,
          theme: theme,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            scan.status,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (scan.isRunning || scan.total > 0) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: scan.total == 0 ? null : scan.scanned / scan.total,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: scan.isRunning
                    ? null
                    : () {
                        scan.customInput = _inputCtrl.text;
                        scan.snis = _sniCtrl.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        scan.start();
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.startScan),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: scan.isRunning ? () => scan.stop() : null,
                icon: const Icon(Icons.stop),
                label: Text(l10n.stopScan),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CdnCustomIpsManager(scan: scan, inputCtrl: _inputCtrl, theme: theme),
        CdnScannerResults(scan: scan, theme: theme),
      ],
    );
  }
}
