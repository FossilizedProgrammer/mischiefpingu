library;

import 'package:flutter/material.dart';

import '../../providers/cdn_scanner_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  CdnScannerController — مدیریت sync بین controllerهای Text
///  و state provider.
/// ═══════════════════════════════════════════════════════════════
class CdnScannerController {
  final TextEditingController inputCtrl;
  final TextEditingController sniCtrl;

  /// آی‌دی آخرین preset که sync شده — برای تشخیص تغییر.
  String? _lastSyncedPresetId;
  bool _initialized = false;

  CdnScannerController({required this.inputCtrl, required this.sniCtrl});

  /// sync controllerها با state provider. idempotent است.
  void sync(CdnScannerProvider scan) {
    if (!scan.isLoaded) return;

    final presetChanged = _lastSyncedPresetId != scan.selectedPresetId;
    final firstTime = !_initialized;

    if (firstTime || presetChanged) {
      _lastSyncedPresetId = scan.selectedPresetId;
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scan.selectedPresetId == 'custom') {
          inputCtrl.text = scan.customIps.join('\n');
        } else {
          inputCtrl.text = scan.customInput;
        }
        sniCtrl.text = scan.snis.join('\n');
      });
    }
  }

  void dispose() {
    // controllerها توسط widget dispose می‌شن
  }
}
