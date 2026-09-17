// lib/providers/cdn_scanner/cdn_scanner_presets.dart
part of '../cdn_scanner_provider.dart';

extension CdnScannerPresets on CdnScannerProvider {
  void applyPreset(String presetId) {
    final preset = CdnPresets.byId(presetId);
    if (preset == null) return;

    selectedPresetId = presetId;

    if (presetId == 'custom') {
      customInput = customIps.join('\n');
      if (snis.isEmpty) {
        snis = List.from(CdnPresets.akamaiSnis);
      }
    } else {
      snis = List.from(preset.snis);
      customInput = preset.ranges.join('\n');
    }

    persistSelectedPreset();
    touch();
  }

  Future<void> saveCustomIps(List<String> ips) async {
    customIpsInternal =
        ips.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    await persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = customIps.join('\n');
    }
    touch();
  }

  Future<void> addCustomIps(List<String> ips) async {
    final merged = <String>{...customIps, ...ips};
    customIpsInternal = merged.toList();
    await persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = customIps.join('\n');
    }
    touch();
  }

  Future<void> removeCustomIp(String ip) async {
    final list = List<String>.from(customIps)..remove(ip);
    customIpsInternal = list;
    await persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = customIps.join('\n');
    }
    touch();
  }

  Future<void> clearCustomIps() async {
    customIpsInternal = [];
    await persistCustomIps();
    if (selectedPresetId == 'custom') {
      customInput = '';
    }
    touch();
  }
}
