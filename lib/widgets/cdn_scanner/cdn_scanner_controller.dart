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

  /// آخرین محتوایی که از customIps در TextField ریخته شده.
  /// برای تشخیص اینکه آیا کاربر دستی تغییر داده یا خیر.
  String? _lastCustomSnapshot;

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
        _lastCustomSnapshot = newText;
        if (inputCtrl.text != newText) {
          inputCtrl.text = newText;
        }
      } else {
        // حالت preset دیگر (akamai, cloudflare, ...)
        final preset = CdnPresets.byId(scan.selectedPresetId ?? 'akamai');
        if (preset != null) {
          final newText = preset.ranges.join('\n');
          if (inputCtrl.text != newText) {
            inputCtrl.text = newText;
          }
        }
        _lastCustomSnapshot = null;
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
      // ✅ FIX ریشه‌ای: در حالت custom، هرگز customInput را
      // از TextField به‌روزرسانی نکن. منبع حقیقت customIps است.
      //
      // اما اگر کاربر دستی TextField را تغییر داد، آن را در
      // _lastCustomSnapshot ذخیره کن تا از چرخه‌ی برگشتی جلوگیری شود.
      if (inputCtrl.text != _lastCustomSnapshot) {
        // کاربر دستی TextField را تغییر داده — این را فقط
        // در customInput نگه دار، ولی اسکن از customIps می‌خواند.
        _lastCustomSnapshot = inputCtrl.text;
        scan.customInput = inputCtrl.text;
      } else {
        // کاربر تغییر نداده → TextField را با customIps همگام کن
        final newText = scan.customIps.join('\n');
        if (inputCtrl.text != newText) {
          inputCtrl.text = newText;
        }
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
