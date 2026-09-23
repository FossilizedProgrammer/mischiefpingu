// lib/screens/widgets/diagnostics_report_tile.dart

library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/diagnostics/diagnostics_report_builder.dart';
import '../../services/process/log_source.dart';
import '../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  DiagnosticsReportTile — دکمه تولید گزارش تشخیصی.
///
///  کاربر می‌تونه:
///    • گزارش رو تولید کنه (preview)
///    • کپی کنه در clipboard
///    • ذخیره کنه در فایل
///
///  ⚠️ همه اطلاعات حساس قبل از نمایش redact میشن.
/// ═══════════════════════════════════════════════════════════════
class DiagnosticsReportTile extends StatefulWidget {
  const DiagnosticsReportTile({super.key});

  @override
  State<DiagnosticsReportTile> createState() => _DiagnosticsReportTileState();
}

class _DiagnosticsReportTileState extends State<DiagnosticsReportTile> {
  bool _generating = false;
  String? _lastReport;

  Future<void> _generate(AppProvider app) async {
    if (_generating) return;

    setState(() {
      _generating = true;
    });

    try {
      final builder = DiagnosticsReportBuilder(
        processService: app.processService,
        settings: app.settings,
        gatewayHistoryStore: app.gatewayHistoryStore,
      );

      final report = await builder.build();

      if (!mounted) return;
      setState(() {
        _lastReport = report;
        _generating = false;
      });

      app.processService.addLog(
        '→ Diagnostics report generated (${report.length} chars)',
        source: LogSource.app,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
      });
      app.processService.addLog(
        '✗ Failed to generate diagnostics report: $e',
        source: LogSource.app,
      );
    }
  }

  Future<void> _copy(AppProvider app) async {
    final report = _lastReport;
    if (report == null) return;

    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.diagnosticsReportCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  🆕 ذخیره گزارش در فایل.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _save(AppProvider app) async {
    final report = _lastReport;
    if (report == null) return;

    final l10n = AppLocalizations.of(context);

    // ─── انتخاب مسیر ───
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);

    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.diagnosticsReportSave,
        fileName: 'mischiefpingu-diagnostics-$timestamp.txt',
        type: FileType.custom,
        allowedExtensions: ['txt', 'log'],
      );

      if (savePath == null || savePath.isEmpty) {
        return;
      }

      // ─── اطمینان از پسوند ───
      final finalPath = savePath.endsWith('.txt') || savePath.endsWith('.log')
          ? savePath
          : '$savePath.txt';

      await File(finalPath).writeAsString(report, flush: true);

      app.processService.addLog(
        '★ Diagnostics report saved: $finalPath',
        source: LogSource.app,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.diagnosticsReportSaved(p.basename(finalPath))),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      app.processService.addLog(
        '✗ Failed to save diagnostics report: $e',
        source: LogSource.app,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.appUpdateFailed}: $e'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showPreview(BuildContext context, AppProvider app) {
    final report = _lastReport;
    if (report == null) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.diagnosticsReportPreview),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.diagnosticsReportRedacted,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: SelectableText(
                      report,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.diagnosticsReportClose),
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.diagnosticsReportCopied),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(l10n.diagnosticsReportCopy),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SettingsTile(
      title: l10n.diagnosticsReport,
      icon: Icons.bug_report_outlined,
      iconBackgroundColor: theme.colorScheme.tertiary,
      initiallyExpanded: false,
      children: [
        Text(
          'Generate a diagnostic report with recent logs, settings, '
          'and gateway history. All sensitive data (IPs, keys, passwords) '
          'will be automatically redacted.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _generating ? null : () => _generate(app),
                icon: _generating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.description_outlined, size: 18),
                label: Text(
                  _generating
                      ? l10n.diagnosticsReportGenerating
                      : l10n.diagnosticsReportGenerate,
                ),
              ),
            ),
          ],
        ),
        if (_lastReport != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPreview(context, app),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l10n.diagnosticsReportPreview),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copy(app),
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(l10n.diagnosticsReportCopy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ═══════════════════════════════════════════════════════
          //  🆕 دکمه Save
          // ═══════════════════════════════════════════════════════
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _save(app),
              icon: const Icon(Icons.save_alt, size: 16),
              label: Text(l10n.diagnosticsReportSave),
            ),
          ),
        ],
      ],
    );
  }
}
