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

  String? _lastSyncedPreset;
  bool _controllersSynced = false;

  CdnScannerController({required this.inputCtrl, required this.sniCtrl});

  /// sync controllerها با state provider. idempotent است.
  void sync(CdnScannerProvider scan) {
    if (!scan.isLoaded) return;

    final presetChanged = _lastSyncedPreset != scan.selectedPresetId;
    final firstTime = !_controllersSynced;

    if (firstTime || presetChanged) {
      _lastSyncedPreset = scan.selectedPresetId;
      _controllersSynced = true;

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
