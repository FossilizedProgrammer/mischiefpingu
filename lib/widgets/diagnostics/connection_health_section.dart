library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/health/tunnel_health_models.dart';
import '../settings_tile_base.dart';

import 'connection_health/auto_probe_scheduler.dart';
import 'connection_health/probe_manager.dart';
import 'connection_health/tunnel_state_resolver.dart';
import 'connection_health/tunnel_health_row.dart';
import 'connection_health/tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConnectionHealthSection — بخش جامع سلامت همه تونل‌ها.
///
///  ⚠️ تغییرات این نسخه:
///    • منطق auto-probe به AutoProbeScheduler منتقل شد
///    • منطق probe به ProbeManager منتقل شد
///    • resolve وضعیت به TunnelStateResolver منتقل شد
///    • این فایل فقط widget + state fields رو داره
/// ═══════════════════════════════════════════════════════════════
class ConnectionHealthSection extends StatefulWidget {
  const ConnectionHealthSection({super.key});

  @override
  State<ConnectionHealthSection> createState() =>
      _ConnectionHealthSectionState();
}

class _ConnectionHealthSectionState extends State<ConnectionHealthSection> {
  late final AutoProbeScheduler _scheduler;
  final ProbeManager _probeManager = const ProbeManager();

  final Map<TunnelKind, TunnelProbeResult> _lastProbeResults = {};
  final Set<TunnelKind> _probingKinds = {};

  @override
  void initState() {
    super.initState();
    _scheduler = AutoProbeScheduler(
      runProbe: _runAutoProbe,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _scheduler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final resolver = TunnelStateResolver(provider);
    final runningStates = resolver.resolveRunningStates();

    // تشخیص transition و زمان‌بندی auto-probe
    _scheduler.detectTransitions(provider, runningStates);

    final healthyCount = runningStates.values.where((v) => v).length;

    return SettingsTile(
      title: l10n.tunnelHealth,
      icon: Icons.monitor_heart_outlined,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      trailingText: '$healthyCount / ${TunnelKind.values.length}',
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _probingKinds.isEmpty
                    ? () => _probeAll(context, provider, resolver)
                    : null,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.tunnelHealthProbeAll),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        for (final kind in TunnelKind.values)
          TunnelHealthRow(
            key: ValueKey(kind),
            kind: kind,
            report: provider.healthReportFor(kind),
            isRunning: runningStates[kind] ?? false,
            isProbing: _probingKinds.contains(kind),
            lastProbeResult: _lastProbeResults[kind],
            onProbe: () => _probeOne(context, provider, resolver, kind),
          ),
      ],
    );
  }

  /// auto-probe (بدون SnackBar، بدون بررسی running state چون
  /// scheduler خودش چک می‌کنه).
  Future<bool> _runAutoProbe(TunnelKind kind) async {
    if (!mounted) return false;
    if (_probingKinds.contains(kind)) return false;

    final provider = context.read<AppProvider>();
    final resolver = TunnelStateResolver(provider);

    setState(() {
      _probingKinds.add(kind);
    });

    final port = resolver.socksPortFor(kind);
    final result = await _probeManager.run(kind: kind, socksPort: port);

    if (!mounted) return false;

    setState(() {
      _lastProbeResults[kind] = result;
      _probingKinds.remove(kind);
    });

    return result.success;
  }

  /// probe دستی (دکمه رفرش).
  Future<void> _probeOne(
    BuildContext context,
    AppProvider provider,
    TunnelStateResolver resolver,
    TunnelKind kind,
  ) async {
    if (!resolver.isTunnelRunning(kind)) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tunnelHealthNotRunning(kind.displayName)),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_probingKinds.contains(kind)) return;

    // کنسل کردن auto-probe چون user خودش خواست
    _scheduler.cancelFor(kind);

    setState(() {
      _probingKinds.add(kind);
    });

    final port = resolver.socksPortFor(kind);
    final result = await _probeManager.run(kind: kind, socksPort: port);

    if (!mounted) return;

    setState(() {
      _lastProbeResults[kind] = result;
      _probingKinds.remove(kind);
    });

    if (!result.success) {
      provider.recordTunnelError(kind);
    }
  }

  Future<void> _probeAll(
    BuildContext context,
    AppProvider provider,
    TunnelStateResolver resolver,
  ) async {
    final runningKinds = TunnelKind.values
        .where((k) => resolver.isTunnelRunning(k))
        .toList();

    if (runningKinds.isEmpty) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tunnelHealthNoTunnelRunning),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await Future.wait(
      runningKinds.map((k) => _probeOne(context, provider, resolver, k)),
    );
  }
}
