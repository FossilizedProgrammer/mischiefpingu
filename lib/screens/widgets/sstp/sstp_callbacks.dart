// lib/screens/widgets/sstp/sstp_callbacks.dart
import '../../models/settings_model.dart';

class SstpCallbacks {
  final AppSettings settings;
  final VoidCallback save;
  final VoidCallback touch;

  const SstpCallbacks({
    required this.settings,
    required this.save,
    required this.touch,
  });

  void onServerChanged(String v) {
    settings.sstpServer = v.trim();
    save();
  }

  void onPortChanged(String v) {
    final p = int.tryParse(v.trim());
    if (p != null && p > 0 && p < 65536) {
      settings.sstpPort = p;
      save();
    }
  }
  // ...
}
