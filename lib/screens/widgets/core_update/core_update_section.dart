import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// یک بخش core update (Aether/Tor/Psiphon) — header + buttons + status.
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
    final missing = isMissingVersion(installed);

    // ✅ راه‌حل: کپی کردن به متغیر محلی برای null promotion
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
                        ? 'Not installed'
                        : 'Installed: $installed   •   Latest: $latest',
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
              child: Text(checking ? 'Checking…' : 'Check'),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: busy ? null : onUpdate,
              child: Text(
                updating
                    ? 'Working $progress%'
                    : (updateLabel ?? (missing ? 'Download' : 'Update')),
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
        // ✅ استفاده از متغیر محلی به جای فیلد مستقیم
        if (checkMsg != null && checkMsg.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildMessageBox(context, checkMsg),
        ],
        if (url != null && url.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildUrlBox(context, url),
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

  Widget _buildMessageBox(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isSuccess = message.startsWith('★');
    final isFailed = message.contains('failed');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withValues(alpha: 0.1)
            : isFailed
                ? Colors.red.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withValues(alpha: 0.3)
              : isFailed
                  ? Colors.red.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isSuccess
              ? Colors.green.shade700
              : isFailed
                  ? Colors.red.shade700
                  : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUrlBox(BuildContext context, String url) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied to clipboard: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.copy, size: 16, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
