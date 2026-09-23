import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/wireguard/wireguard_config_parser.dart';
import '../../../services/wireguard/wireguard_uri_codec.dart';

class WireGuardConfigSection extends StatefulWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final String initialConfig;
  final ValueChanged<String> onConfigChanged;

  const WireGuardConfigSection({
    super.key,
    required this.theme,
    required this.l10n,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<WireGuardConfigSection> createState() => _WireGuardConfigSectionState();
}

class _WireGuardConfigSectionState extends State<WireGuardConfigSection> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isStandard = true;

  // ═══════════════════════════════════════════════════════════
  //  🆕 debounce — جلوگیری از نوشتن مکرر روی SharedPreferences
  // ═══════════════════════════════════════════════════════════
  Timer? _debounce;

  /// آخرین کانفیگ پارس‌شده (برای نمایش endpoint).
  WireGuardConfig? _parsed;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialConfig);
    _detectFormat(widget.initialConfig);
    _parsed = WireGuardConfigParser.parse(widget.initialConfig);
  }

  // ═══════════════════════════════════════════════════════════
  //  🆕 sync با parent وقتی initialConfig عوض شد
  //
  //  مثلاً وقتی user از dialog کانفیگ رو import می‌کنه،
  //  یا از دکمهٔ reset استفاده می‌کنه.
  // ═══════════════════════════════════════════════════════════
  @override
  void didUpdateWidget(covariant WireGuardConfigSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final parentChanged = oldWidget.initialConfig != widget.initialConfig;
    if (!parentChanged) return;

    // اگر کاربر در حال تایپ است، مداخله نکن
    if (_controller.text == widget.initialConfig) return;

    _debounce?.cancel();

    _controller.text = widget.initialConfig;
    _detectFormat(widget.initialConfig);

    final parsed = WireGuardConfigParser.parse(widget.initialConfig);
    setState(() {
      _parsed = parsed;
      if (widget.initialConfig.trim().isEmpty) {
        _errorText = null;
      } else if (parsed == null || !parsed.isValid) {
        _errorText = widget.l10n.wireguardConfigInvalid;
      } else {
        _errorText = null;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _detectFormat(String raw) {
    _isStandard = !raw.trim().toLowerCase().startsWith('wireguard://');
  }

  void _onChanged(String value) {
    _detectFormat(value);

    final parsed = WireGuardConfigParser.parse(value);
    setState(() {
      _parsed = parsed;
      if (value.trim().isEmpty) {
        _errorText = null;
      } else if (parsed == null || !parsed.isValid) {
        _errorText = widget.l10n.wireguardConfigInvalid;
      } else {
        _errorText = null;
      }
    });

    // ═══════════════════════════════════════════════════════════
    //  🆕 debounce 500ms — فقط بعد از توقف تایپ ذخیره کن
    // ═══════════════════════════════════════════════════════════
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onConfigChanged(value);
      }
    });
  }

  /// تبدیل استاندارد ↔ URI.
  void _convertFormat() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final parsed = WireGuardConfigParser.parse(raw);
    if (parsed == null || !parsed.isValid) return;

    final converted = _isStandard
        ? WireGuardUriCodec.encode(parsed)
        : WireGuardConfigParser.serialize(parsed);

    setState(() {
      _controller.text = converted;
      _detectFormat(converted);
      _errorText = null;
      _parsed = parsed;
    });

    // ═══════════════════════════════════════════════════════════
    //  🆕 تبدیل فوری ذخیره بشه (نه با debounce)
    // ═══════════════════════════════════════════════════════════
    widget.onConfigChanged(converted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = widget.l10n;
    final parsed = _parsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.wireguardConfig,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _isStandard
                    ? l10n.wireguardFormatStandard
                    : l10n.wireguardFormatUri,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.wireguardConfigHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 8,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
          ),
          decoration: InputDecoration(
            hintText: _isStandard
                ? '[Interface]\nPrivateKey = ...\nAddress = ...\n\n'
                    '[Peer]\nPublicKey = ...\nEndpoint = ...'
                : 'wireguard://privatekey@endpoint:port/?'
                    'publickey=...&address=...',
            errorText: _errorText,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          onChanged: _onChanged,
        ),
        if (parsed != null && parsed.isValid) ...[
          const SizedBox(height: 12),
          _ParsedConfigPreview(parsed: parsed, theme: theme, l10n: l10n),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _controller.text.trim().isEmpty ? null : _convertFormat,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text(
              _isStandard
                  ? l10n.wireguardConvertToUri
                  : l10n.wireguardConvertToStandard,
            ),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
///  پیش‌نمایش read-only کانفیگ پارس‌شده.
/// ═══════════════════════════════════════════════════════════════
class _ParsedConfigPreview extends StatelessWidget {
  final WireGuardConfig parsed;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _ParsedConfigPreview({
    required this.parsed,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Endpoint', parsed.endpoint),
          const SizedBox(height: 4),
          _row('PublicKey', _shorten(parsed.publicKey)),
          const SizedBox(height: 4),
          _row('Address', parsed.address),
          const SizedBox(height: 4),
          _row('AllowedIPs', parsed.allowedIps),
          if (parsed.dns.isNotEmpty) ...[
            const SizedBox(height: 4),
            _row('DNS', parsed.dns),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  String _shorten(String s) {
    if (s.length <= 20) return s;
    return '${s.substring(0, 10)}…${s.substring(s.length - 6)}';
  }
}
