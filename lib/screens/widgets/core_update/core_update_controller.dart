// lib/screens/widgets/core_update/core_update_controller.dart
//
// ═══════════════════════════════════════════════════════════════
//  CoreUpdateController — مدیریت state و منطق ۵ core updater
//  (تفکیک شده از core_update_tile.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';

import '../../../providers/app_provider.dart';
import '../../../services/core_update_service.dart';
import 'core_update_state.dart';

/// شناسه‌های coreهای پشتیبانی‌شده.
enum CoreKind { aether, tor, psiphon, sunandlion, sstp }

/// یک ردیف config برای core update.
class CoreUpdateSpec {
  final CoreKind kind;
  final String displayName;
  final String? note;
  final String? updateLabelWhenMissing;

  const CoreUpdateSpec({
    required this.kind,
    required this.displayName,
    this.note,
    this.updateLabelWhenMissing,
  });
}

/// کنترلر مشترک برای همهٔ coreها.
class CoreUpdateController extends ChangeNotifier {
  final CoreUpdateService Function() serviceFactory;
  final String Function() proxyResolver;
  final AppProvider Function() providerResolver;

  late final Map<CoreKind, CoreUpdateEntryState> _states;

  CoreUpdateController({
    required this.serviceFactory,
    required this.proxyResolver,
    required this.providerResolver,
  }) {
    _states = {
      for (final kind in CoreKind.values)
        kind: CoreUpdateEntryState(
          coreId: _coreIdFor(kind),
          serviceFactory: serviceFactory,
          proxyResolver: proxyResolver,
        )..addListener(notifyListeners),
    };
  }

  CoreUpdateEntryState stateOf(CoreKind kind) => _states[kind]!;

  @override
  void dispose() {
    for (final s in _states.values) {
      s.removeListener(notifyListeners);
      s.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════
  //  Refresh all installed versions
  // ═══════════════════════════════════════════
  Future<void> refreshAll() async {
    final provider = providerResolver();
    final rev = provider.settings.psiphonBuildRev;
    for (final entry in _states.entries) {
      if (entry.key == CoreKind.psiphon) {
        await entry.value.refreshInstalled(psiphonRev: rev);
      } else {
        await entry.value.refreshInstalled();
      }
    }
  }

  // ═══════════════════════════════════════════
  //  Check
  // ═══════════════════════════════════════════
  Future<void> check(CoreKind kind) async {
    final state = _states[kind]!;
    final svc = serviceFactory();
    final provider = providerResolver();

    await state.check(
      runCheck: (proxy) {
        switch (kind) {
          case CoreKind.psiphon:
            return svc.checkForUpdate(
              'psiphon',
              proxy: proxy,
              psiphonRev: provider.settings.psiphonBuildRev,
              psiphonBinSha: provider.settings.psiphonBinarySha,
            );
          default:
            return svc.checkForUpdate(_coreIdFor(kind), proxy: proxy);
        }
      },
    );
  }

  // ═══════════════════════════════════════════
  //  Update
  // ═══════════════════════════════════════════
  Future<void> update(CoreKind kind) async {
    final state = _states[kind]!;
    final svc = serviceFactory();
    final provider = providerResolver();

    await state.update(
      runUpdate: (proxy, onProgress) {
        switch (kind) {
          case CoreKind.psiphon:
            return svc.updateCore(
              'psiphon',
              proxy: proxy,
              psiphonRev: provider.settings.psiphonBuildRev,
              psiphonBinSha: provider.settings.psiphonBinarySha,
              onProgress: onProgress,
            );
          default:
            return svc.updateCore(
              _coreIdFor(kind),
              proxy: proxy,
              onProgress: onProgress,
            );
        }
      },
      afterUpdate: () async {
        if (kind == CoreKind.psiphon) {
          await _postUpdatePsiphon(svc, provider);
        } else {
          await state.refreshInstalled();
        }
      },
    );
  }

  Future<void> _postUpdatePsiphon(
      CoreUpdateService svc, AppProvider provider) async {
    try {
      final info = await svc.checkForUpdate(
        'psiphon',
        proxy: proxyResolver(),
        psiphonRev: provider.settings.psiphonBuildRev,
        psiphonBinSha: provider.settings.psiphonBinarySha,
      );
      if (info.latestCommit.isNotEmpty) {
        provider.settings.psiphonBinarySha = info.latestCommit;
        await provider.saveSettings();
      }
    } catch (_) {}
    await _states[CoreKind.psiphon]!
        .refreshInstalled(psiphonRev: provider.settings.psiphonBuildRev);
  }

  // ═══════════════════════════════════════════
  //  Helper
  // ═══════════════════════════════════════════
  static String _coreIdFor(CoreKind kind) {
    switch (kind) {
      case CoreKind.aether:
        return 'aether';
      case CoreKind.tor:
        return 'tor';
      case CoreKind.psiphon:
        return 'psiphon';
      case CoreKind.sunandlion:
        return 'sunandlion';
      case CoreKind.sstp:
        return 'sstp';
    }
  }

  /// specهای ثابت برای نمایش در UI.
  static const List<CoreUpdateSpec> specs = [
    CoreUpdateSpec(
      kind: CoreKind.aether,
      displayName: 'Aether',
    ),
    CoreUpdateSpec(
      kind: CoreKind.tor,
      displayName: 'Tor',
    ),
    CoreUpdateSpec(
      kind: CoreKind.psiphon,
      displayName: 'Psiphon (official)',
      note: 'Official binary from Psiphon-Labs.',
      updateLabelWhenMissing: 'Download',
    ),
    CoreUpdateSpec(
      kind: CoreKind.sunandlion,
      displayName: 'SunAndLion Psiphon Core',
      note: 'Unofficial Psiphon fork by ssmirr — required for fronting mode.',
      updateLabelWhenMissing: 'Download',
    ),
    CoreUpdateSpec(
      kind: CoreKind.sstp,
      displayName: 'SSTP Proxy',
      note: 'SSTP client from FossilizedProgrammer/sstp-proxy.',
      updateLabelWhenMissing: 'Download',
    ),
  ];
}
