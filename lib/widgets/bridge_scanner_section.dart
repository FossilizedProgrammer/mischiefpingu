import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/bridge_scanner_provider.dart';
import 'settings_tile_base.dart';

class BridgeScannerSection extends StatefulWidget {
  const BridgeScannerSection({super.key});

  @override
  State<BridgeScannerSection> createState() => _BridgeScannerSectionState();
}

class _BridgeScannerSectionState extends State<BridgeScannerSection> {
  final TextEditingController _inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BridgeScannerProvider>().initSavedBridges();
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<BridgeScannerProvider>();
    final app = context.read<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_inputCtrl.text != scan.rawInput && !scan.isRunning) {
      _inputCtrl.text = scan.rawInput;
    }

    final workingCount = scan.working.length;
    final savedCount = scan.savedBridges.length;

    return SettingsTile(
      title: l10n.bridgeScanner,
      icon: Icons.radar,
      iconBackgroundColor: theme.colorScheme.tertiary,
      initiallyExpanded: false,
      trailingText: workingCount > 0 ? '$workingCount working' : null,
      children: [
        Text(
          l10n.bridgeScannerDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // ─── دکمه‌های Fetch ───
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FetchChip(
                label: 'obfs4',
                transport: 'obfs4',
                scan: scan,
                theme: theme,
                l10n: l10n),
            _FetchChip(
                label: 'webtunnel',
                transport: 'webtunnel',
                scan: scan,
                theme: theme,
                l10n: l10n),
            _FetchChip(
                label: 'snowflake',
                transport: 'snowflake',
                scan: scan,
                theme: theme,
                l10n: l10n),
            _FetchChip(
                label: 'meek',
                transport: 'meek-azure',
                scan: scan,
                theme: theme,
                l10n: l10n),
            _FetchChip(
                label: 'conjure',
                transport: 'conjure',
                scan: scan,
                theme: theme,
                l10n: l10n),
          ],
        ),
        const SizedBox(height: 12),

        // ─── ورودی خطوط بریج ───
        TextField(
          controller: _inputCtrl,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.bridgeLines,
            hintText: l10n.bridgeLinesHint,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          enabled: !scan.isRunning,
          onChanged: (v) => scan.rawInput = v,
        ),
        const SizedBox(height: 12),

        // ─── ردیف Threads ───
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 110,
              child: TextFormField(
                initialValue: scan.concurrency.toString(),
                decoration: InputDecoration(
                  labelText: l10n.bridgeThreads,
                  isDense: true,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !scan.isRunning,
                onChanged: (v) {
                  scan.concurrency = int.tryParse(v) ?? 10;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ─── وضعیت ───
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

        // ─── دکمه‌های Start / Stop ───
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: scan.isRunning
                    ? null
                    : () {
                        scan.rawInput = _inputCtrl.text;
                        scan.start();
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.bridgeStartScan),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: scan.isRunning ? () => scan.stop() : null,
                icon: const Icon(Icons.stop),
                label: Text(l10n.bridgeStopScan),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════════
        //  نوار مدیریت بریج‌های ذخیره‌شده
        // ═══════════════════════════════════════════════════════════
        const SizedBox(height: 12),
        _SavedBridgesBar(
          scan: scan,
          app: app,
          theme: theme,
          l10n: l10n,
          savedCount: savedCount,
          workingCount: workingCount,
        ),

        // ─── نتایج ───
        if (scan.results.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.bridgeResults,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: workingCount == 0
                    ? null
                    : () => _applyWorkingBridges(
                        context, app, scan, l10n, workingCount),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.bridgeApplyWorking(workingCount)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: scan.sortedResults.length,
              itemBuilder: (ctx, i) {
                final r = scan.sortedResults[i];
                final color = r.isReachable
                    ? (r.latencyMs < 500
                        ? Colors.green
                        : (r.latencyMs < 1500 ? Colors.orange : Colors.red))
                    : Colors.red;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      r.isReachable ? Icons.check : Icons.close,
                      color: color,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    r.bridge.transport.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    r.bridge.address ??
                        r.bridge.params['front'] ??
                        'No address',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: r.isReachable
                      ? Text(
                          '${r.latencyMs}ms',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        )
                      : const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  🆕 Apply Working — با رفع باگ:
  ///    • transport رو به 'bridge' تغییر میده
  ///    • اگر Tor در حال اجراست، restart می‌کنه
  ///    • پیام SnackBar متناسب با وضعیت
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _applyWorkingBridges(
    BuildContext context,
    AppProvider app,
    BridgeScannerProvider scan,
    AppLocalizations l10n,
    int workingCount,
  ) async {
    final workingLines = scan.working.map((r) => r.bridge.raw).join('\n');

    // ⚠️ FIX 1: transport رو حتماً به 'bridge' تغییر بده
    // اگر direct/manual باشه، bridges نادیده گرفته میشن
    app.settings.torBridges = workingLines;
    app.settings.torTransport = 'bridge';
    await app.saveSettings();

    final ps = app.processService;
    final wasRunning = ps.isTorRunning;

    if (!context.mounted) return;

    // ⚠️ FIX 2: اگر Tor running هست، restart کن تا config جدید apply بشه
    if (wasRunning) {
      // stop
      await app.connectTor(); // این toggle می‌کنه → stop
      await Future.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;
      // start
      await app.connectTor();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bridgeApplyWorkingRestarting(workingCount)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bridgeApplyWorkingTorNotRunning(workingCount)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

/// ═══════════════════════════════════════════════════════════════
///  نوار مدیریت بریج‌های ذخیره‌شده
/// ═══════════════════════════════════════════════════════════════
class _SavedBridgesBar extends StatelessWidget {
  final BridgeScannerProvider scan;
  final AppProvider app;
  final ThemeData theme;
  final AppLocalizations l10n;
  final int savedCount;
  final int workingCount;

  const _SavedBridgesBar({
    required this.scan,
    required this.app,
    required this.theme,
    required this.l10n,
    required this.savedCount,
    required this.workingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  savedCount == 0
                      ? l10n.bridgeNoSaved
                      : l10n.bridgeSavedCount(savedCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                avatar: const Icon(Icons.save_outlined, size: 14),
                label: Text(l10n.bridgeSaveWorking),
                onPressed: workingCount == 0
                    ? null
                    : () async {
                        final count = await scan.saveWorkingBridges();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bridgeSaveSuccess(count)),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.download_outlined, size: 14),
                label: Text(l10n.bridgeLoadSaved),
                onPressed: savedCount == 0
                    ? null
                    : () async {
                        final count = await scan.loadSavedBridges();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bridgeLoadedSuccess(count)),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.replay, size: 14),
                label: Text(l10n.bridgeRescanSaved),
                onPressed: savedCount == 0 || scan.isRunning
                    ? null
                    : () async {
                        final count = await scan.rescanSavedBridges();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bridgeRescanStarted(count)),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.delete_outline, size: 14),
                label: Text(l10n.bridgeClearSaved),
                onPressed: savedCount == 0
                    ? null
                    : () async {
                        await scan.clearSavedBridges();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bridgeClearedSaved),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// چیپ Fetch برای هر transport.
class _FetchChip extends StatelessWidget {
  final String label;
  final String transport;
  final BridgeScannerProvider scan;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _FetchChip({
    required this.label,
    required this.transport,
    required this.scan,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(l10n.bridgeFetch(label)),
      selected: false,
      onSelected: scan.isRunning
          ? null
          : (v) {
              if (v) scan.fetchFromCollector(transport);
            },
    );
  }
}
