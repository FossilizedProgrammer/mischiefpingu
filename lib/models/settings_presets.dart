part of 'settings_model.dart';

/// ═══════════════════════════════════════════════════════════════
///  Presetهای اتصال Psiphon
///  (تفکیک شده از settings_model.dart)
/// ═══════════════════════════════════════════════════════════════
extension AppSettingsPresets on AppSettings {
  void applyPreset(int number) {
    switch (number) {
      case 1:
        isFronted = true;
        useSunAndLion = true;
        upstreamType = 0;
        autoFindIpAndSni = true;
        saveFoundIpsAndSni = true;
        break;
      case 2:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 2;
        break;
      case 3:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 3;
        break;
      case 4:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 4;
        break;
    }
  }
}
