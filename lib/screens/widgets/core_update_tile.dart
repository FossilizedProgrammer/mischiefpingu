// lib/screens/widgets/core_update_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/core_update_service.dart';
import '../../widgets/settings_tile_base.dart';
import 'core_update/core_update_content.dart';
import 'core_update/core_update_controller.dart';
import 'core_update/core_update_proxy_resolver.dart';

class CoreUpdateTile extends StatefulWidget {
  const CoreUpdateTile({super.key});

  @override
  State<CoreUpdateTile> createState() => _CoreUpdateTileState();
}

class _CoreUpdateTileState extends State<CoreUpdateTile> {
  String _proxyMode = 'auto';
  CoreUpdateController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = CoreUpdateController(
      serviceFactory: () {
        final provider = context.read<AppProvider>();
        return CoreUpdateService(log: provider.processService.addLog);
      },
      proxyResolver: () =>
          CoreUpdateProxyResolver(_proxyMode).resolve(context) ?? '',
      providerResolver: () => context.read<AppProvider>(),
    );
    _controller!.addListener(_onControllerChanged);
    Future.microtask(() => _controller?.refreshAll());
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SettingsTile(
      title: l10n.coreUpdates,
      icon: Icons.system_update_outlined,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        if (_controller != null)
          CoreUpdateContent(
            controller: _controller!,
            proxyMode: _proxyMode,
            onProxyModeChanged: (v) => setState(() => _proxyMode = v),
          ),
      ],
    );
  }
}
