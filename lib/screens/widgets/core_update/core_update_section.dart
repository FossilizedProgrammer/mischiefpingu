import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'core_update_message_boxes.dart';

class CoreUpdateSection extends StatelessWidget {
  final String name;
  final String installed;
  final String latest;
  final bool busy;
  final bool checking;
  final bool updating;
  final int progress;
  final VoidCallback onCheck;
  final VoidCallback onUpdate;
  final String? updateLabel;
  final String? note;
  final String? downloadUrl;
  final String? checkMessage;

  const CoreUpdateSection({
    super.key,
    required this.name,
    required this.installed,
    required this.latest,
    required this.busy,
    required this.checking,
    required this.updating,
    required this.progress,
    required this.onCheck,
    required this.onUpdate,
    this.updateLabel,
    this.note,
    this.downloadUrl,
    this.checkMessage,
  });

  static bool isMissingVersion(String v) {
    final t = v.trim().toLowerCase();
    return t.isEmpty || t == 'unknown' || t == 'not installed';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final missing = isMissingVersion(installed);

    final checkMsg = checkMessage;
    final url = downloadUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    missing
                        ? l10n.notInstalled
                        : '${l10n.installed}: $installed   •   ${l10n.latest}: $latest',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: missing
                          ? Colors.orange
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: busy ? null : onCheck,
              child: Text(checking ? l10n.checking : l10n.check),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: busy ? null : onUpdate,
              child: Text(
                updating
                    ? '${l10n.working} $progress%'
                    : (updateLabel ?? (missing ? l10n.download : l10n.update)),
              ),
            ),
          ],
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(
            note!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (checkMsg != null && checkMsg.isNotEmpty) ...[
          const SizedBox(height: 8),
          CoreUpdateMessageBox(message: checkMsg),
        ],
        if (url != null && url.isNotEmpty) ...[
          const SizedBox(height: 8),
          CoreUpdateUrlBox(url: url),
        ],
        if (updating) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress > 0 ? progress / 100 : null,
          ),
        ],
      ],
    );
  }
}
