import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/models/settings_model.dart';

void main() {
  test('tunnel local ports survive json round-trip', () {
    final s = AppSettings()
      ..sstpSocksPort = 1111
      ..sstpHttpPort = 2222
      ..ffvpnSocksPort = 3333
      ..ffvpnHttpPort = 4444
      ..fluxcorePort = 5555
      ..fluxcoreHttpPort = 6666;
    final back = AppSettings.fromJson(
        Map<String, dynamic>.from(s.toJson() as Map));
    expect(back.sstpSocksPort, 1111);
    expect(back.sstpHttpPort, 2222);
    expect(back.ffvpnSocksPort, 3333);
    expect(back.ffvpnHttpPort, 4444);
    expect(back.fluxcorePort, 5555);
    expect(back.fluxcoreHttpPort, 6666);
  });
}
