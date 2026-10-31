// lib/screens/widgets/npv/npv_servers_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../providers/app_provider.dart';
import '../../../services/npv/npv_paths.dart';
import '../../../services/npv/npv_server_list.dart';
import '../../../services/process_service.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  NpvServersSection — فهرست کانفیگ‌های داخل فایل .npvs.
///
///  • «Show servers» فقط رمزگشایی می‌کند (فوری، بدون verdict)
///  • «Check servers» ترافیک واقعی از هر کانفیگ رد می‌کند:
///    زنده‌ها بالا و سریع‌ترین به قبل، مرده‌ها پایین با دلیل خطا
///  • با یک ضربه روی ردیف، همان کانفیگ پین می‌شود: `connect -s N` فقط
///    همان را می‌سنجد و سرویس می‌کند؛ «Auto (fastest)» برمی‌گرداند
///
///  ترتیب را خودِ باینری می‌سازد (خروجی `npv list -json`)، پس
///  اینجا دوباره sort نمی‌کنیم.
/// ═══════════════════════════════════════════════════════════════
class NpvServersSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const NpvServersSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  bool get _isPinned => s.npvPinnedIndex.isNotEmpty;

  bool _isPinnedTo(NpvServerEntry entry) =>
      _isPinned && s.npvPinnedIndex == '${entry.index}';

  void _togglePin(NpvServerEntry entry) {
    final wasPinned = _isPinnedTo(entry);
    s.npvPinnedIndex = wasPinned ? '' : '${entry.index}';
    s.npvPinnedRemark = wasPinned ? '' : entry.remark;
    onSave();
  }

  void _clearPin() {
    s.npvPinnedIndex = '';
    s.npvPinnedRemark = '';
    onSave();
  }

  /// برچسب انتخاب دستی؛ remark فقط اگر هنگام پین معلوم بوده نمایش داده
  /// می‌شود (بعد از ری‌استارت ممکن است فهرست هنوز گرفته نشده باشد).
  String get _pinnedLabel => s.npvPinnedRemark.isEmpty
      ? '#${s.npvPinnedIndex}'
      : '#${s.npvPinnedIndex} · ${s.npvPinnedRemark}';

  bool _pinIsStale(NpvServerList list) =>
      !list.servers.any((e) => '${e.index}' == s.npvPinnedIndex);

  /// هسته‌های قدیمی `-s` را در connect نادیده می‌گیرند و سریع‌ترین را
  /// سرویس می‌کنند؛ اگر کانفیگِ سرویس‌شده انتخاب کاربر نبود، می‌گوییم.
  bool _pinWasIgnored(ProcessService ps) =>
      s.npvPinnedRemark.isNotEmpty &&
      ps.npvSelectedConfig.isNotEmpty &&
      ps.npvSelectedConfig != s.npvPinnedRemark;

  Widget _warning(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Future<void> _scan(ProcessService ps, {required bool check}) async {
    final binary = await NpvPaths.resolveBinary();
    if (binary == null) return;
    final config = await NpvPaths.resolveConfigPath(s.npvConfigName);
    if (config == null) {
      // بی‌فایل یعنی فهرستی هم نیست؛ پیام به‌جای لیست خالی نشان داده می‌شود.
      ps.npvScanError = l10n.npvServersNoFile;
      ps.touch();
      return;
    }
    ps.npvScanError = null;
    await ps.scanNpvServers(
      binaryPath: binary,
      configPath: config,
      check: check,
      probeTimeoutSeconds: s.npvProbeTimeout,
      probeJobs: s.npvProbeJobs,
      probeUrl: s.npvProbeUrl,
    );
  }

  Widget _row(ProcessService ps, NpvServerEntry entry, bool checked) {
    final inUse = checked &&
        entry.remark.isNotEmpty &&
        entry.remark == ps.npvSelectedConfig;

    final Widget verdict;
    if (!checked) {
      verdict = Icon(
        Icons.help_outline,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      );
    } else if (entry.ok) {
      verdict = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${entry.medianMs} ms',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.green.shade600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
        ],
      );
    } else {
      verdict = Tooltip(
        message: entry.error.isEmpty ? l10n.npvServersDead : entry.error,
        child: Icon(Icons.cancel, size: 16, color: Colors.red.shade400),
      );
    }

    final sub = [
      entry.proto,
      entry.transport,
    ].where((e) => e.isNotEmpty).join(' · ');

    return Tooltip(
      message: _isPinnedTo(entry)
          ? l10n.npvServersUnpinHint
          : l10n.npvServersPinHint,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: () => _togglePin(entry),
        leading: (checked && entry.ok)
            ? SizedBox(
                width: 26,
                child: Text(
                  '#${ps.npvServerList?.rankOf(entry) ?? 0}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              )
            : _isPinnedTo(entry)
                ? Icon(
                    Icons.push_pin,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  )
                : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${entry.index}. ${entry.remark}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: checked && !entry.ok
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
            if (_isPinnedTo(entry))
              _badge(l10n.npvServersPinnedChip, theme.colorScheme.tertiary),
            if (inUse) _badge(l10n.npvServersInUse, theme.colorScheme.primary),
          ],
        ),
        subtitle: Text(
          (checked && !entry.ok && entry.error.isNotEmpty)
              ? '$sub — ${_shortError(entry.error)}'
              : sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: verdict,
      ),
    );
  }

  /// برچسب کوچک کنار نام کانفیگ («pinned»، «in use»).
  Widget _badge(String label, Color color) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// خطاهای Go طولانی‌اند؛ اولِ پیام کافی است (جزئیات در tooltip).
  static String _shortError(String error) {
    final line = error.split('\n').first.trim();
    return line.length <= 90 ? line : '${line.substring(0, 90)}…';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final ps = provider.processService;
    final list = ps.npvServerList;
    final scanning = ps.isNpvScanning;
    final checked = ps.npvScanChecked;

    return SettingsSection(
      label: l10n.npvServersSection,
      children: [
        Text(
          l10n.npvServersDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.npvServersPinHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: scanning ? null : () => _scan(ps, check: false),
              icon: const Icon(Icons.list_alt, size: 18),
              label: Text(l10n.npvServersListBtn),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            FilledButton.tonalIcon(
              onPressed: scanning ? null : () => _scan(ps, check: true),
              icon: const Icon(Icons.network_check, size: 18),
              label: Text(l10n.npvServersCheckBtn),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (scanning) ...[
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: ps.cancelNpvScan,
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.npvServersCancelBtn),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        if (_isPinned) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.push_pin,
                size: 15,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.npvServersPinnedTo(_pinnedLabel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _clearPin,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(l10n.npvServersAutoBtn),
              ),
            ],
          ),
          // پین باقی‌مانده از فایل دیگری، یا هسته‌ای آنقدر قدیمی که
          // «سریع‌ترین» را به جای انتخاب کاربر سرویس می‌کند.
          if (list != null && !scanning && _pinIsStale(list))
            _warning(l10n.npvServersStalePin(s.npvPinnedIndex)),
          if (ps.isNpvRunning && _pinWasIgnored(ps))
            _warning(l10n.npvServersPinIgnored),
        ],
        if (scanning) ...[
          const SizedBox(height: 4),
          const LinearProgressIndicator(
            minHeight: 2,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.npvServersScanning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        if (ps.npvScanError != null && !scanning) ...[
          const SizedBox(height: 6),
          Text(
            ps.npvScanError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (list != null && !scanning && list.hasServers) ...[
          const SizedBox(height: 8),
          Text(
            checked
                ? l10n.npvServersSummary(list.answered, list.total)
                : l10n.npvServersCount(list.total),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (list.creatorMessage.isNotEmpty)
            Text(
              '${l10n.npvServersCreator}: ${list.creatorMessage}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: list.servers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _row(ps, list.servers[i], checked),
            ),
          ),
        ],
        if (list != null && !scanning && !list.hasServers)
          Text(
            l10n.npvServersNone,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
