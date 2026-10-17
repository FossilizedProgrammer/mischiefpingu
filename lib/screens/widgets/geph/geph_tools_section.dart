// lib/screens/widgets/geph/geph_tools_section.dart
//
// بخش «حساب گف»:
//   • وضعیت: کد حساب آماده است یا نه
//   • «ساخت حساب» → signup + ذخیرهٔ کد در پوشهٔ داده + نمایش مسیر فایل
//   • «حساب دارم»  → نمایش موقتِ منبع کد و فیلد کد لاگین/فایل کد حساب
//
// بخشِ ورودی کد به‌صورت پیش‌فرض پنهان است تا کد محرمانه در دید نباشد و فقط
// وقتی کاربر واقعاً کدی از قبل دارد باز شود.
//
// خروجی فرمان‌ها در پنل لاگ (منبع Geph) می‌آید؛ کد لاگین در لاگ ماسک می‌شود.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/geph_provider.dart';
import '../../../services/geph/geph_cli_service.dart';
import '../../../widgets/settings_tile_base.dart';

class GephToolsSection extends StatefulWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const GephToolsSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<GephToolsSection> createState() => _GephToolsSectionState();
}

class _GephToolsSectionState extends State<GephToolsSection> {
  bool _hasAccount = false;
  bool _checkingAccount = true;

  /// نمایش موقتِ منبع کد و فیلد کد/فایل (دکمهٔ «حساب دارم»).
  bool _showAccountInput = false;

  /// مسیر پیش‌فرض فایل کد حساب (داخل پوشهٔ داده) — یک‌بار خوانده می‌شود.
  String _defaultPath = '';

  /// مسیری که کد تازه‌ساخته‌شده در آن ذخیره شده (پیام موفقیت signup).
  String? _savedTo;

  @override
  void initState() {
    super.initState();
    _loadDefaultPath();
    _refreshAccount();
  }

  Future<void> _loadDefaultPath() async {
    final path = await GephCliService.accountFilePath();
    if (!mounted) return;
    setState(() => _defaultPath = path);
  }

  Future<void> _refreshAccount() async {
    final has = widget.s.gephAccountSource == AppSettings.gephAccountSourceCode
        ? widget.s.gephAccountCode.trim().isNotEmpty
        : await GephCliService.hasAccountAtFile(
            await GephCliService.resolveAccountFile(widget.s),
          );
    if (!mounted) return;
    setState(() {
      _hasAccount = has;
      _checkingAccount = false;
    });
  }

  AppSettings get s => widget.s;
  AppLocalizations get l10n => widget.l10n;
  ThemeData get theme => widget.theme;

  bool get _isCodeSource =>
      s.gephAccountSource == AppSettings.gephAccountSourceCode;

  /// مسیر مؤثر فایل کد حساب (برای نمایش).
  String get _effectivePath {
    final custom = s.gephAccountFile.trim();
    return custom.isNotEmpty ? custom : _defaultPath;
  }

  /// ساخت حساب: کد را از فایل می‌خواند، در تنظیمات نگه می‌دارد و مسیر
  /// فایل را نشان می‌دهد؛ بعد بخش ورودی کد بسته می‌شود.
  Future<void> _signup(GephProvider geph) async {
    final result = await geph.runCommand(
      s,
      geph.cliFor(s).signupArgs(),
      label: 'signup',
    );
    if (!mounted) return;

    if (result?.ok ?? false) {
      final cli = geph.cliFor(s);
      final code = await cli.readAccountCode();
      if (code != null) {
        s.gephAccountCode = code;
        widget.onSave();
        _savedTo = await cli.resolvedAccountFile();
        _showAccountInput = false;
      }
    }

    await _refreshAccount();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final geph = context.watch<GephProvider>();
    final busy = geph.isRunningCommand || geph.isLoadingCountries;

    return SettingsSection(
      label: l10n.gephAccountSection,
      children: [
        Text(
          _checkingAccount
              ? '…'
              : (_hasAccount
                  ? l10n.gephAccountReady
                  : l10n.gephAccountMissing),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _hasAccount
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: busy ? null : () => _signup(geph),
              icon: const Icon(Icons.person_add, size: 18),
              label: Text(l10n.gephSignupBtn),
            ),
            OutlinedButton.icon(
              key: const ValueKey('geph-have-account'),
              onPressed: () => setState(() {
                _showAccountInput = !_showAccountInput;
                if (_showAccountInput) _savedTo = null;
              }),
              icon: Icon(
                _showAccountInput ? Icons.expand_less : Icons.vpn_key,
                size: 18,
              ),
              label: Text(l10n.gephIHaveAccount),
            ),
          ],
        ),
        if (_showAccountInput) ...[
          const Divider(height: 26),
          DropdownButtonFormField<String>(
            key: const ValueKey('geph-account-source'),
            initialValue: s.gephAccountSource,
            decoration: InputDecoration(
              labelText: l10n.gephAccountSource,
              isDense: true,
            ),
            items: [
              DropdownMenuItem(
                value: AppSettings.gephAccountSourceFile,
                child: Text(l10n.gephAccountSourceFile),
              ),
              DropdownMenuItem(
                value: AppSettings.gephAccountSourceCode,
                child: Text(l10n.gephAccountSourceCode),
              ),
            ],
            onChanged: (v) {
              s.gephAccountSource = v ?? AppSettings.gephAccountSourceFile;
              widget.onSave();
              setState(() {});
              _refreshAccount();
            },
          ),
          const SizedBox(height: 10),
          if (_isCodeSource)
            TextFormField(
              key: const ValueKey('geph-login-code'),
              initialValue: s.gephAccountCode,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.gephLoginCodeLabel,
                helperText: l10n.gephLoginCodeHint,
                helperMaxLines: 2,
                isDense: true,
              ),
              onChanged: (v) {
                s.gephAccountCode = v;
                widget.onSave();
                _refreshAccount();
              },
            )
          else
            TextFormField(
              key: const ValueKey('geph-account-file'),
              initialValue: s.gephAccountFile,
              decoration: InputDecoration(
                labelText: l10n.gephAccountFilePath,
                hintText: _defaultPath,
                helperText: l10n.gephAccountFileHint,
                helperMaxLines: 2,
                isDense: true,
              ),
              onChanged: (v) {
                s.gephAccountFile = v.trim();
                widget.onSave();
              },
              onFieldSubmitted: (_) => _refreshAccount(),
            ),
          const SizedBox(height: 6),
          Text(
            l10n.gephAccountPath(_effectivePath),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (_savedTo != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.gephAccountSavedTo(_savedTo!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        if (busy) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.gephRunning}: ${geph.runningLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        if (provider.isGephBusy) ...[
          const SizedBox(height: 8),
          Text(
            provider.gephStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
