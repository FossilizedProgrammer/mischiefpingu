library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import 'core_update_controller.dart';
import 'core_update_section.dart';
import 'core_update_proxy_resolver.dart';

class CoreUpdateContent extends StatelessWidget {
  final CoreUpdateController controller;
  final String proxyMode;
  final ValueChanged<String> onProxyModeChanged;

  const CoreUpdateContent({
    super.key,
    required this.controller,
    required this.proxyMode,
    required this.onProxyModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: proxyMode,
          decoration: InputDecoration(
            labelText: l10n.downloadVia,
            isDense: true,
          ),
          items: buildCoreUpdateProxyItems(l10n),
          onChanged: (v) => onProxyModeChanged(v ?? 'auto'),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.downloadViaSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildSections(),
      ],
    );
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    for (var i = 0; i < CoreUpdateController.specs.length; i++) {
      final spec = CoreUpdateController.specs[i];
      final state = controller.stateOf(spec.kind);

      widgets.add(
        CoreUpdateSection(
          name: spec.displayName,
          installed: state.installed,
          latest: state.latest,
          busy: state.checking || state.updating,
          checking: state.checking,
          updating: state.updating,
          progress: state.progress,
          onCheck: () => controller.check(spec.kind),
          onUpdate: () => controller.update(spec.kind),
          note: spec.note,
          downloadUrl: state.downloadUrl,
          checkMessage: state.checkMessage,
        ),
      );

      if (i < CoreUpdateController.specs.length - 1) {
        widgets.add(const Divider(height: 24));
      }
    }
    return widgets;
  }
}
