part of 'settings_model.dart';

/// ═══════════════════════════════════════════════════════════════
///  Presetهای اتصال Psiphon
///
///  ⚠️ Preset 2 (Aether upstream) حذف شد.
///  حالا فقط ۳ حالت داریم: Fronting, Conduit, Direct
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
        upstreamType = 3;
        break;
      case 3:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 4;
        break;
    }
  }

  /// آیا این preset نیاز به هشدار دارد؟
  bool get presetNeedsWarning => false;
}
