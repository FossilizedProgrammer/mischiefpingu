import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  PortTextField — فیلد استاندارد ورودی پورت.
///
///  • فقط رقم می‌پذیرد؛ ارقام فارسی/عربی به ASCII تبدیل می‌شوند
///    (وگرنه int.tryParse نادیده گرفته می‌شد).
///  • مقدار خارج از بازه یا خالی، زیر فیلد با پیام localized
///    نشان داده می‌شود — نه اینکه بی‌صدا نادیده گرفته شود.
/// ═══════════════════════════════════════════════════════════════
class PortTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int min;
  final int max;
  final String? hintText;

  const PortTextField({
    super.key,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.min = 1,
    this.max = 65535,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      inputFormatters: [PortDigitsFormatter()],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final p = int.tryParse((v ?? '').trim());
        if (p == null || p < min || p > max) {
          return l10n.portRangeError(min, max);
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

/// فقط رقم‌ها را نگه می‌دارد؛ ارقام فارسی (۰-۹) و عربی (٠-٩)
/// به معادل ASCII تبدیل می‌شوند، بقیه کاراکترها حذف می‌شوند.
class PortDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buf = StringBuffer();
    for (final unit in newValue.text.runes) {
      if (unit >= 0x30 && unit <= 0x39) {
        buf.writeCharCode(unit); // 0-9
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        buf.writeCharCode(0x30 + unit - 0x06F0); // ۰-۹
      } else if (unit >= 0x0660 && unit <= 0x0669) {
        buf.writeCharCode(0x30 + unit - 0x0660); // ٠-٩
      }
    }
    final text = buf.toString();
    if (text == newValue.text) return newValue;

    final selection = newValue.selection;
    final collapsed = selection.isValid && !selection.isCollapsed
        ? TextSelection(
            baseOffset: min(selection.baseOffset, text.length),
            extentOffset: min(selection.extentOffset, text.length),
          )
        : TextSelection.collapsed(
            offset: min(
              selection.isValid ? selection.baseOffset : 0,
              text.length,
            ),
          );
    return newValue.copyWith(text: text, selection: collapsed);
  }
}
