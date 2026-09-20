part of 'settings_model.dart';

/// ═══════════════════════════════════════════════════════════════
///  Presetهای اتصال Psiphon
///
///  چهار حالت:
///    1 · Fronting (CDN) — SunAndLion + fronting
///    2 · Aether traffic as upstream — آپ‌استریم اتر
///    3 · Conduit (WebRTC Inproxy)
///    4 · Direct connection
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
        // ⬅ Aether traffic as upstream
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 2;
        break;
      case 3:
        // Conduit (WebRTC Inproxy)
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 3;
        break;
      case 4:
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
