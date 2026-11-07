import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/cdn_scanner_provider.dart';
import '../services/ip_range_parser.dart';
import 'settings_tile_base.dart';
import 'cdn_scanner/cdn_scanner_controller.dart';
import 'cdn_scanner/cdn_scanner_inputs.dart';
import 'cdn_scanner/cdn_scanner_results.dart';
import 'cdn_scanner/cdn_custom_ips_manager.dart';
import 'cdn_scanner/cdn_scan_mode_selector.dart';

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
    final app = context.read<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    _controller.sync(scan);

    final effectiveCount = scan.effectiveIpCount();
    final isCustom = scan.selectedPresetId == 'custom';
    final warnings = scan.effectiveWarnings();

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
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        //  🆕 انتخاب حالت اسکن
        // ═══════════════════════════════════════════════════════════
        CdnScanModeSelector(
          selected: scan.scanMode,
          onChanged: scan.isRunning ? (_) {} : scan.setScanMode,
          enabled: !scan.isRunning,
          theme: theme,
        ),
        const SizedBox(height: 12),

        // ═══════════════════════════════════════════════════════════
        //  باکس پیش‌نمایش تعداد واقعی
        // ═══════════════════════════════════════════════════════════
        if (!scan.isRunning)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _previewColor(effectiveCount, scan.scanMode)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _previewColor(effectiveCount, scan.scanMode)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _previewColor(effectiveCount, scan.scanMode),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.cdnScanPreview(
                          (isCustom ? scan.customIps.length : '?').toString(),
                          effectiveCount.toString(),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _previewColor(effectiveCount, scan.scanMode),
                        ),
                      ),
                    ),
                  ],
                ),
                if (warnings.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  for (final w in warnings.take(3))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '· $w',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (warnings.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '· ${l10n.cdnScanWarningsMore((warnings.length - 3).toString())}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),

        // ─── Status bar ───
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

        // ─── Start/Stop ───
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: scan.isRunning
                    ? null
                    : () {
                        if (scan.selectedPresetId == 'custom') {
                          if (scan.customIps.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.listIsEmpty),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          scan.customInput = scan.customIps.join('\n');
                        } else {
                          scan.customInput = _inputCtrl.text;
                        }
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

        // ─── نتایج ───
        if (scan.good.isNotEmpty && !scan.isRunning) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${scan.good.length} ${l10n.usableIps}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final ipsToAdd = scan.good.map((e) => e.ip).toList();
                      final bestSni = scan.bestSni;

                      await app.applyScannerResults(
                        ips: ipsToAdd,
                        tlsSni: bestSni,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.cdnApplyIpsSnack(
                              ipsToAdd.length.toString(),
                              ipsToAdd.first,
                              bestSni ?? '',
                            ),
                          ),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_to_mobile_outlined),
                    label: Text(
                      l10n.cdnApplyIpsToPsiphon(scan.good.length.toString()),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        CdnCustomIpsManager(scan: scan, inputCtrl: _inputCtrl, theme: theme),
        CdnScannerResults(scan: scan, theme: theme),
      ],
    );
  }

  Color _previewColor(int count, IpScanMode mode) {
    if (mode == IpScanMode.deep && count > 20000) return Colors.red;
    if (count > 10000) return Colors.orange;
    return Colors.green;
  }
}
