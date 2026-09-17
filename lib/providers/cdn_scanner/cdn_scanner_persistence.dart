// lib/providers/cdn_scanner/cdn_scanner_persistence.dart
part of '../cdn_scanner_provider.dart';

extension CdnScannerPersistence on CdnScannerProvider {
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ استفاده از نام کامل کلاس برای static const
      customIpsInternal =
          prefs.getStringList(CdnScannerProvider.prefsCustomIps) ?? [];
      final savedSnis = prefs.getStringList(CdnScannerProvider.prefsCustomSnis);
      final savedPreset =
          prefs.getString(CdnScannerProvider.prefsSelectedPreset);

      if (savedPreset != null) {
        selectedPresetId = savedPreset;
        if (savedPreset == 'custom') {
          customInput = customIps.join('\n');
          if (savedSnis != null && savedSnis.isNotEmpty) {
            snis = List.from(savedSnis);
          } else {
            snis = List.from(CdnPresets.akamaiSnis);
          }
        } else {
          final preset = CdnPresets.byId(savedPreset);
          if (preset != null) {
            snis = List.from(preset.snis);
            customInput = preset.ranges.join('\n');
          } else {
            applyPreset('akamai');
          }
        }
      } else {
        applyPreset('akamai');
      }
    } catch (_) {
    } finally {
      isLoaded = true;
      touch();
    }
  }

  Future<void> persistCustomIps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        CdnScannerProvider.prefsCustomIps,
        customIps,
      );
    } catch (_) {}
  }

  Future<void> persistSelectedPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (selectedPresetId != null) {
        await prefs.setString(
          CdnScannerProvider.prefsSelectedPreset,
          selectedPresetId!,
        );
      }
      if (selectedPresetId == 'custom') {
        await prefs.setStringList(
          CdnScannerProvider.prefsCustomSnis,
          snis,
        );
      }
    } catch (_) {}
  }
}
