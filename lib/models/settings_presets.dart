part of 'settings_model.dart';

/// ═══════════════════════════════════════════════════════════════
///  Presetهای اتصال Psiphon
///
///  سه حالت:
///    1 · Fronting (CDN) — SunAndLion + fronting
///    2 · Conduit (WebRTC Inproxy)
///    3 · Direct connection
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
        // Conduit (WebRTC Inproxy)
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 3;
        break;
      case 3:
        // Direct connection
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 4;
        break;
    }
  }

  /// آیا این preset نیاز به هشدار دارد؟
  bool get presetNeedsWarning => false;
}
