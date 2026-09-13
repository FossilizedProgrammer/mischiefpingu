// lib/screens/widgets/core_update_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/core_update_service.dart';
import '../../widgets/settings_tile_base.dart';
import 'core_update/core_update_section.dart';
import 'core_update/core_update_proxy_resolver.dart';
import 'core_update/core_update_state.dart';

class CoreUpdateTile extends StatefulWidget {
  const CoreUpdateTile({super.key});

  @override
  State<CoreUpdateTile> createState() => _CoreUpdateTileState();
}

class _CoreUpdateTileState extends State<CoreUpdateTile> {
  String _proxyMode = 'auto';

  late final CoreUpdateEntryState _aetherState;
  late final CoreUpdateEntryState _torState;
  late final CoreUpdateEntryState _psiState;
  late final CoreUpdateEntryState _sunLionState;
  late final CoreUpdateEntryState _sstpState;

  CoreUpdateService get _svc {
    final provider = context.read<AppProvider>();
    return CoreUpdateService(log: provider.processService.addLog);
  }

  String? _resolveProxy() =>
      CoreUpdateProxyResolver(_proxyMode).resolve(context);

  @override
  void initState() {
    super.initState();
    _aetherState = CoreUpdateEntryState(
      coreId: 'Aether',
      serviceFactory: () => _svc,
      proxyResolver: () => _resolveProxy() ?? '',
    )..addListener(_onStateChanged);
    _torState = CoreUpdateEntryState(
      coreId: 'Tor',
      serviceFactory: () => _svc,
      proxyResolver: () => _resolveProxy() ?? '',
    )..addListener(_onStateChanged);
    _psiState = CoreUpdateEntryState(
      coreId: 'Psiphon',
      serviceFactory: () => _svc,
      proxyResolver: () => _resolveProxy() ?? '',
    )..addListener(_onStateChanged);
    _sunLionState = CoreUpdateEntryState(
      coreId: 'SunAndLion',
      serviceFactory: () => _svc,
      proxyResolver: () => _resolveProxy() ?? '',
    )..addListener(_onStateChanged);
    _sstpState = CoreUpdateEntryState(
      coreId: 'SSTP',
      serviceFactory: () => _svc,
      proxyResolver: () => _resolveProxy() ?? '',
    )..addListener(_onStateChanged);

    Future.microtask(_refreshAll);
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _aetherState.dispose();
    _torState.dispose();
    _psiState.dispose();
    _sunLionState.dispose();
    _sstpState.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    final provider = context.read<AppProvider>();
    await _aetherState.refreshInstalled();
    await _torState.refreshInstalled();
    await _psiState.refreshInstalled(
      psiphonRev: provider.settings.psiphonBuildRev,
    );
    await _sunLionState.refreshInstalled();
    await _sstpState.refreshInstalled();
  }

  // ═══════════════════════════════════════════
  //  Aether
  // ═══════════════════════════════════════════
  Future<void> _checkAether() => _aetherState.check(
        runCheck: (proxy) => _svc.checkForUpdate('aether', proxy: proxy),
      );

  Future<void> _updateAether() => _aetherState.update(
        runUpdate: (proxy, onProgress) => _svc.updateCore(
          'aether',
          proxy: proxy,
          onProgress: onProgress,
        ),
        afterUpdate: _aetherState.refreshInstalled,
      );

  // ═══════════════════════════════════════════
  //  Tor
  // ═══════════════════════════════════════════
  Future<void> _checkTor() => _torState.check(
        runCheck: (proxy) => _svc.checkForUpdate('tor', proxy: proxy),
      );

  Future<void> _updateTor() => _torState.update(
        runUpdate: (proxy, onProgress) => _svc.updateCore(
          'tor',
          proxy: proxy,
          onProgress: onProgress,
        ),
        afterUpdate: _torState.refreshInstalled,
      );

  // ═══════════════════════════════════════════
  //  Psiphon (official)
  // ═══════════════════════════════════════════
  Future<void> _checkPsi() async {
    final provider = context.read<AppProvider>();
    await _psiState.check(
      runCheck: (proxy) => _svc.checkForUpdate(
        'psiphon',
        proxy: proxy,
        psiphonRev: provider.settings.psiphonBuildRev,
        psiphonBinSha: provider.settings.psiphonBinarySha,
      ),
    );
  }

  Future<void> _updatePsi() async {
    final provider = context.read<AppProvider>();
    await _psiState.update(
      runUpdate: (proxy, onProgress) => _svc.updateCore(
        'psiphon',
        proxy: proxy,
        psiphonRev: provider.settings.psiphonBuildRev,
        psiphonBinSha: provider.settings.psiphonBinarySha,
        onProgress: onProgress,
      ),
      afterUpdate: () async {
        try {
          final info = await _svc.checkForUpdate(
            'psiphon',
            proxy: _resolveProxy(),
            psiphonRev: provider.settings.psiphonBuildRev,
            psiphonBinSha: provider.settings.psiphonBinarySha,
          );
          if (info.latestCommit.isNotEmpty) {
            provider.settings.psiphonBinarySha = info.latestCommit;
            await provider.saveSettings();
          }
        } catch (_) {}
        await _psiState.refreshInstalled(
          psiphonRev: provider.settings.psiphonBuildRev,
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  //  SunAndLion
  // ═══════════════════════════════════════════
  Future<void> _checkSunLion() => _sunLionState.check(
        runCheck: (proxy) =>
            _svc.checkForUpdate('sunandlion', proxy: proxy),
      );

  Future<void> _updateSunLion() => _sunLionState.update(
        runUpdate: (proxy, onProgress) => _svc.updateCore(
          'sunandlion',
          proxy: proxy,
          onProgress: onProgress,
        ),
        afterUpdate: _sunLionState.refreshInstalled,
      );

  // ═══════════════════════════════════════════
  //  SSTP Proxy
  // ═══════════════════════════════════════════
  Future<void> _checkSstp() => _sstpState.check(
        runCheck: (proxy) => _svc.checkForUpdate('sstp', proxy: proxy),
      );

  Future<void> _updateSstp() => _sstpState.update(
        runUpdate: (proxy, onProgress) => _svc.updateCore(
          'sstp',
          proxy: proxy,
          onProgress: onProgress,
        ),
        afterUpdate: _sstpState.refreshInstalled,
      );

  // ═══════════════════════════════════════════
  //  UI
  // ═══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SettingsTile(
      title: 'Core Updates',
      icon: Icons.system_update_outlined,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        SettingsDropdown<String>(
          labelText: 'Download via',
          value: _proxyMode,
          items: coreUpdateProxyItems,
          onChanged: (v) => setState(() => _proxyMode = v ?? 'auto'),
        ),
        const SizedBox(height: 4),
        Text(
          'Checks and downloads ride the selected proxy when direct access is filtered.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        CoreUpdateSection(
          name: 'Aether',
          installed: _aetherState.installed,
          latest: _aetherState.latest,
          busy: _aetherState.checking || _aetherState.updating,
          checking: _aetherState.checking,
          updating: _aetherState.updating,
          progress: _aetherState.progress,
          onCheck: _checkAether,
          onUpdate: _updateAether,
          downloadUrl: _aetherState.downloadUrl,
          checkMessage: _aetherState.checkMessage,
        ),
        const Divider(height: 24),
        CoreUpdateSection(
          name: 'Tor',
          installed: _torState.installed,
          latest: _torState.latest,
          busy: _torState.checking || _torState.updating,
          checking: _torState.checking,
          updating: _torState.updating,
          progress: _torState.progress,
          onCheck: _checkTor,
          onUpdate: _updateTor,
          downloadUrl: _torState.downloadUrl,
          checkMessage: _torState.checkMessage,
        ),
        const Divider(height: 24),
        CoreUpdateSection(
          name: 'Psiphon (official)',
          installed: _psiState.installed,
          latest: _psiState.latest,
          busy: _psiState.checking || _psiState.updating,
          checking: _psiState.checking,
          updating: _psiState.updating,
          progress: _psiState.progress,
          onCheck: _checkPsi,
          onUpdate: _updatePsi,
          updateLabel: _psiState.missing ? 'Download' : null,
          note: 'Official binary from Psiphon-Labs.',
          downloadUrl: _psiState.downloadUrl,
          checkMessage: _psiState.checkMessage,
        ),
        const Divider(height: 24),
        CoreUpdateSection(
          name: 'SunAndLion Psiphon Core',
          installed: _sunLionState.installed,
          latest: _sunLionState.latest,
          busy: _sunLionState.checking || _sunLionState.updating,
          checking: _sunLionState.checking,
          updating: _sunLionState.updating,
          progress: _sunLionState.progress,
          onCheck: _checkSunLion,
          onUpdate: _updateSunLion,
          updateLabel: _sunLionState.missing ? 'Download' : null,
          note: 'Unofficial Psiphon fork by ssmirr — '
              'required for fronting mode.',
          downloadUrl: _sunLionState.downloadUrl,
          checkMessage: _sunLionState.checkMessage,
        ),
        const Divider(height: 24),
        CoreUpdateSection(
          name: 'SSTP Proxy',
          installed: _sstpState.installed,
          latest: _sstpState.latest,
          busy: _sstpState.checking || _sstpState.updating,
          checking: _sstpState.checking,
          updating: _sstpState.updating,
          progress: _sstpState.progress,
          onCheck: _checkSstp,
          onUpdate: _updateSstp,
          updateLabel: _sstpState.missing ? 'Download' : null,
          note: 'SSTP client from FossilizedProgrammer/sstp-proxy.',
          downloadUrl: _sstpState.downloadUrl,
          checkMessage: _sstpState.checkMessage,
        ),
      ],
    );
  }
}
