import 'package:flutter/material.dart';
import '../../../providers/sstp_fetcher_provider.dart';

class SstpFetcherStatus extends StatelessWidget {
  final SstpFetcherProvider fetcher;
  final ThemeData theme;

  const SstpFetcherStatus({
    super.key,
    required this.fetcher,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fetcher.status,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (fetcher.lastMessage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              fetcher.lastMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
