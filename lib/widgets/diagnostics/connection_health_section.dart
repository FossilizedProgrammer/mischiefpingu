library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/health/tunnel_health_models.dart';
import '../settings_tile_base.dart';
import 'connection_health/tunnel_health_row.dart';
import 'connection_health/tunnel_health_tester.dart';
import 'connection_health/tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConnectionHealthSection — بخش جامع سلامت همه تونل‌ها.
///
///  ⚠️ تغییرات این نسخه:
///    • از isAetherTunnelReady استفاده می‌کند (نه isAetherRunning)
///    • auto-probe با backoff در همین widget مدیریت می‌شود
///    • تا وقتی tunnel واقعاً آماده نشده، probe نمی‌زند
/// ═══════════════════════════════════════════════════════════════
class ConnectionHealthSection extends StatefulWidget {
  const ConnectionHealthSection({super.key});

  @override
  State<ConnectionHealthSection> createState() =>
      _ConnectionHealthSectionState();
}

class _ConnectionHealthSectionState extends State<ConnectionHealthSection> {
  final TunnelHealthTester _tester = const TunnelHealthTester();

  final Map<TunnelKind, TunnelProbeResult> _lastProbeResults = {};
  final Set<TunnelKind> _probingKinds = {};

  /// Timerهای auto-probe در انتظار.
  final Map<TunnelKind, Timer> _autoProbeTimers = {};

  /// تونل‌هایی که auto-probe موفق داشته‌اند (جلوگیری از تکرار).
  final Set<TunnelKind> _autoProbed = {};

  /// وضعیت قبلی هر تونل برای تشخیص transition.
  final Map<TunnelKind, bool> _previousRunning = {};

  @override
  void dispose() {
    for (final t in _autoProbeTimers.values) {
      t.cancel();
    }
    _autoProbeTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final runningStates = _resolveRunningStates(provider);

    // تشخیص transition و زمان‌بندی auto-probe
    _detectTransitionsAndScheduleAutoProbe(provider, runningStates);

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
                    ? () => _probeAll(context, provider)
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
            onProbe: () => _probeOne(context, provider, kind),
          ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  تشخیص transition از stopped به running و شروع auto-probe.
  /// ═══════════════════════════════════════════════════════════════
  void _detectTransitionsAndScheduleAutoProbe(
    AppProvider provider,
    Map<TunnelKind, bool> runningStates,
  ) {
    for (final kind in TunnelKind.values) {
      final isRunning = runningStates[kind] ?? false;
      final wasRunning = _previousRunning[kind] ?? false;

      // ─── transition: stopped → running ───
      if (isRunning && !wasRunning) {
        debugPrint(
          '[ConnectionHealthSection] ${kind.displayName} '
          'transitioned to running — scheduling auto-probe',
        );

        _autoProbed.remove(kind);
        _scheduleAutoProbe(provider, kind, attempt: 1);
      }

      // ─── transition: running → stopped ───
      if (!isRunning && wasRunning) {
        debugPrint(
          '[ConnectionHealthSection] ${kind.displayName} '
          'transitioned to stopped',
        );

        _autoProbeTimers.remove(kind)?.cancel();
        _lastProbeResults.remove(kind);
        _autoProbed.remove(kind);
      }

      _previousRunning[kind] = isRunning;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  Schedule یک auto-probe با تاخیر و backoff نمایی.
  ///
  ///  attempt 1: 2s
  ///  attempt 2: 3s
  ///  attempt 3: 5s
  ///  attempt 4: 8s
  ///  attempt 5+: 12s
  ///  حداکثر 6 تلاش
  /// ═══════════════════════════════════════════════════════════════
  void _scheduleAutoProbe(
    AppProvider provider,
    TunnelKind kind, {
    required int attempt,
  }) {
    _autoProbeTimers.remove(kind)?.cancel();

    if (_autoProbed.contains(kind)) return;

    // اگه همین الان در حال probe است، دوباره schedule کن
    if (_probingKinds.contains(kind)) {
      _autoProbeTimers[kind] = Timer(
        const Duration(seconds: 2),
        () => _scheduleAutoProbe(provider, kind, attempt: attempt),
      );
      return;
    }

    final delay = _delayForAttempt(attempt);
    debugPrint(
      '[ConnectionHealthSection] ${kind.displayName} '
      'auto-probe attempt #$attempt in ${delay.inSeconds}s',
    );

    _autoProbeTimers[kind] = Timer(delay, () async {
      _autoProbeTimers.remove(kind);

      if (!mounted) return;

      // چک کن هنوز تونل در حال اجراست
      final currentStates = _resolveRunningStates(provider);
      if (!(currentStates[kind] ?? false)) {
        debugPrint(
          '[ConnectionHealthSection] ${kind.displayName} '
          'auto-probe cancelled (tunnel stopped)',
        );
        return;
      }

      if (_autoProbed.contains(kind)) return;

      await _autoProbe(provider, kind, attempt: attempt);
    });
  }

  Duration _delayForAttempt(int attempt) {
    switch (attempt) {
      case 1:
        return const Duration(seconds: 2);
      case 2:
        return const Duration(seconds: 3);
      case 3:
        return const Duration(seconds: 5);
      case 4:
        return const Duration(seconds: 8);
      default:
        return const Duration(seconds: 12);
    }
  }

  /// اجرای auto-probe و اگر شکست خورد، دوباره schedule کن.
  Future<void> _autoProbe(
    AppProvider provider,
    TunnelKind kind, {
    required int attempt,
  }) async {
    if (!mounted) return;
    if (_probingKinds.contains(kind)) return;

    setState(() {
      _probingKinds.add(kind);
    });

    try {
      final port = _socksPortFor(provider, kind);
      debugPrint(
        '[ConnectionHealthSection] auto-probe ${kind.displayName} '
        'attempt #$attempt on 127.0.0.1:$port',
      );

      final result = await _tester.probe(kind: kind, socksPort: port);

      if (!mounted) return;

      if (result.success) {
        debugPrint(
          '[ConnectionHealthSection] ${kind.displayName} '
          'auto-probe SUCCESS (${result.latencyMs}ms)',
        );

        setState(() {
          _lastProbeResults[kind] = result;
          _probingKinds.remove(kind);
          _autoProbed.add(kind);
        });

        _autoProbeTimers.remove(kind)?.cancel();
      } else {
        debugPrint(
          '[ConnectionHealthSection] ${kind.displayName} '
          'auto-probe FAILED (attempt #$attempt): ${result.error}',
        );

        setState(() {
          _lastProbeResults[kind] = result;
          _probingKinds.remove(kind);
        });

        if (attempt < 6) {
          _scheduleAutoProbe(provider, kind, attempt: attempt + 1);
        } else {
          debugPrint(
            '[ConnectionHealthSection] ${kind.displayName} '
            'auto-probe giving up after $attempt attempts',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ConnectionHealthSection] ${kind.displayName} '
        'auto-probe threw: $e',
      );

      if (!mounted) return;

      setState(() {
        _lastProbeResults[kind] = TunnelProbeResult.failure(error: '$e');
        _probingKinds.remove(kind);
      });

      if (attempt < 6) {
        _scheduleAutoProbe(provider, kind, attempt: attempt + 1);
      }
    }
  }

  /// probe دستی (دکمه رفرش).
  Future<void> _probeOne(
    BuildContext context,
    AppProvider provider,
    TunnelKind kind,
  ) async {
    if (!_isTunnelRunning(provider, kind)) {
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
    _autoProbeTimers.remove(kind)?.cancel();
    _autoProbed.add(kind);

    setState(() {
      _probingKinds.add(kind);
    });

    try {
      final port = _socksPortFor(provider, kind);
      debugPrint(
        '[ConnectionHealthSection] manual probe ${kind.displayName} '
        'on 127.0.0.1:$port',
      );

      final result = await _tester.probe(kind: kind, socksPort: port);

      if (!mounted) return;

      setState(() {
        _lastProbeResults[kind] = result;
        _probingKinds.remove(kind);
      });

      if (!result.success) {
        provider.recordTunnelError(kind);
      }
    } catch (e) {
      debugPrint(
        '[ConnectionHealthSection] ${kind.displayName} '
        'manual probe threw: $e',
      );
      if (!mounted) return;
      setState(() {
        _lastProbeResults[kind] = TunnelProbeResult.failure(error: '$e');
        _probingKinds.remove(kind);
      });
    }
  }

  Future<void> _probeAll(BuildContext context, AppProvider provider) async {
    final runningKinds = TunnelKind.values
        .where((k) => _isTunnelRunning(provider, k))
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
      runningKinds.map((k) => _probeOne(context, provider, k)),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  ⚠️ برای Aether از isAetherTunnelReady استفاده می‌کنیم نه
  ///  isAetherRunning. دلیل: SOCKS Aether فقط وقتی قابل استفاده
  ///  است که tunnel validate شده باشد.
  ///
  ///  بقیه تونل‌ها (Psiphon/Tor/SSTP) از isXConnected استفاده
  ///  می‌کنند که خودشان بعد از آماده شدن واقعی true می‌شوند.
  /// ═══════════════════════════════════════════════════════════════
  Map<TunnelKind, bool> _resolveRunningStates(AppProvider provider) {
    final ps = provider.processService;
    return {
      TunnelKind.psiphon: ps.isPsiphonConnected,
      TunnelKind.aether: ps.isAetherTunnelReady, // ← اینجا
      TunnelKind.tor: ps.isTorConnected,
      TunnelKind.sstp: ps.isSstpConnected,
    };
  }

  bool _isTunnelRunning(AppProvider provider, TunnelKind kind) {
    return _resolveRunningStates(provider)[kind] ?? false;
  }

  int _socksPortFor(AppProvider provider, TunnelKind kind) {
    final s = provider.settings;
    switch (kind) {
      case TunnelKind.psiphon:
        return s.socksPort;
      case TunnelKind.aether:
        return s.aetherLocalPort;
      case TunnelKind.tor:
        return s.torSocksPort;
      case TunnelKind.sstp:
        return s.sstpSocksPort;
    }
  }
}
