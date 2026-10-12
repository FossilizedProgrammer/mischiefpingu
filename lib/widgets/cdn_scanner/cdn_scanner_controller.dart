import 'package:flutter/material.dart';
import '../../providers/cdn_scanner_provider.dart';
import '../../cdn_presets.dart';

/// ═══════════════════════════════════════════════════════════════
/// CdnScannerController — مدیریت sync بین TextFieldها و provider
///
/// ⚠️ FIX جدید: در حالت custom، منبع حقیقت `scan.customIps` است.
/// TextField صرفاً برای نمایش/ویرایش دستی است و نباید به عنوان
/// منبع اسکن استفاده شود. اسکن مستقیماً از `customIps` می‌خواند.
///
/// 🐛 باگ قبلی: وقتی preset به custom تغییر می‌کرد، TextField
/// هنوز رنج‌های Akamai (~20000 آی‌پی) را نشان می‌داد و در sync
/// بعدی، این متن کهنه به customInput برمی‌گشت و اسکن به‌جای
/// 40 آی‌پی کاستوم، 20000 آی‌پی Akamai را اسکن می‌کرد.
/// ═══════════════════════════════════════════════════════════════
class CdnScannerController {
  final TextEditingController inputCtrl;
  final TextEditingController sniCtrl;

  /// آی‌دی آخرین preset که sync شده — برای تشخیص تغییر preset.
  String? _lastSyncedPresetId;

  /// آخرین متنی که از customIps در TextField ریخته شده.
  /// ⚠️ فقط وقتی customIps واقعاً عوض شده باشد (ذخیره/حذف از لیست)
  /// فیلد بازنویسی می‌شود — نه در هر sync — وگرنه تایپ کاربر پاک می‌شود.
  String? _lastCustomIpsText;

  CdnScannerController({required this.inputCtrl, required this.sniCtrl});

  void sync(CdnScannerProvider scan) {
    // ───────────────────────────────────────────────────────────
    // حالت ۱: preset تغییر کرده → TextField را به‌روز کن (یک‌طرفه)
    // ───────────────────────────────────────────────────────────
    if (_lastSyncedPresetId != scan.selectedPresetId) {
      _lastSyncedPresetId = scan.selectedPresetId;
      if (scan.selectedPresetId == 'custom') {
        // ✅ در حالت custom، TextField را با customIps پر کن
        final newText = scan.customIps.join('\n');
        _lastCustomIpsText = newText;
        scan.customInput = newText;
        if (inputCtrl.text != newText) {
          inputCtrl.text = newText;
        }
      } else {
        // حالت preset دیگر (akamai, cloudflare, ...)
        final preset = CdnPresets.byId(scan.selectedPresetId ?? 'akamai');
        if (preset != null) {
          final newText = preset.ranges.join('\n');
          scan.customInput = newText;
          if (inputCtrl.text != newText) {
            inputCtrl.text = newText;
          }
        }
        _lastCustomIpsText = null;
      }

      // SNI را هم به‌روز کن
      final sniText = scan.snis.join('\n');
      if (sniCtrl.text != sniText) {
        sniCtrl.text = sniText;
      }

      // ⛔ بعد از تغییر preset، برعکس sync نکن (جلوگیری از باگ)
      return;
    }

    // ───────────────────────────────────────────────────────────
    // حالت ۲: preset تغییر نکرده → sync عادی
    // ───────────────────────────────────────────────────────────
    if (scan.selectedPresetId == 'custom') {
      // ✅ FIX ریشه‌ای: منبع حقیقت customIps است، ولی فقط وقتی
      // customIps عوض شده باشد (ذخیره/حذف/پاک‌سازی) فیلد را refresh کن.
      //
      // 🐛 باگ قبلی: فیلد در هر sync با customIps بازنویسی می‌شد؛
      // یعنی به‌محض اینکه کاربر چیزی تایپ می‌کرد و یک rebuild
      // دیگر رخ می‌داد، تایپ او با لیست قدیمی جایگزین می‌شد
      // و دکمه ذخیره، لیستِ قدیمی را ذخیره می‌کرد (یا خالی).
      final ipsText = scan.customIps.join('\n');
      if (ipsText != _lastCustomIpsText) {
        // لیست کاستوم از بیرون عوض شده → فیلد را به‌روز کن
        _lastCustomIpsText = ipsText;
        scan.customInput = ipsText;
        if (inputCtrl.text != ipsText) {
          inputCtrl.text = ipsText;
        }
      } else {
        // لیست عوض نشده → فیلد دست‌نخورده بماند؛ فقط customInput
        // را با متن فعلی فیلد همگام کن (تایپ کاربر هرگز پاک نمی‌شود).
        scan.customInput = inputCtrl.text;
      }
    } else {
      // حالت preset دیگر
      if (inputCtrl.text != scan.customInput && !scan.isRunning) {
        inputCtrl.text = scan.customInput;
      }
    }

    // SNI sync
    final sniText = scan.snis.join('\n');
    if (sniCtrl.text != sniText) {
      sniCtrl.text = sniText;
    }
  }

  /// ⚠️ این متد دیگر کاری انجام نمی‌دهد چون controller خودش
  /// هیچ منبعی برای dispose کردن ندارد (فقط مرجع به
  /// TextEditingControllerها نگه می‌دارد که در widget dispose
  /// می‌شوند). اما برای سازگاری با کد موجود نگه داشته شده است.
  void dispose() {
    // no-op
  }
}
