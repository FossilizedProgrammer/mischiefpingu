import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/settings_persistence_service.dart';

void main() {
  test('sstp/ffvpn local ports survive real save+load', () async {
    SharedPreferences.setMockInitialValues({});
    final persistence = SettingsPersistenceService();
    final s = AppSettings()
      ..sstpHttpPort = 9999
      ..sstpSocksPort = 1111
      ..ffvpnHttpPort = 4444
      ..ffvpnSocksPort = 3333;
    await persistence.saveSettings(s);
    final loaded = await persistence.loadSettings();
    expect(loaded.sstpHttpPort, 9999);
    expect(loaded.sstpSocksPort, 1111);
    expect(loaded.ffvpnHttpPort, 4444);
    expect(loaded.ffvpnSocksPort, 3333);
  });
}
