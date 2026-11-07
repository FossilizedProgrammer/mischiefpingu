// تست وضعیت دکمهٔ Aether: ملاک، آماده بودن واقعی هسته است نه متن status.
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/widgets/connection/connection_state_resolver.dart';

void main() {
  bool connected({
    bool isRunning = true,
    bool tunnelReady = false,
    bool isBusy = false,
    String status = 'Aether: Ready',
  }) =>
      ConnectionStateResolver.aetherConnected(
        isRunning: isRunning,
        tunnelReady: tunnelReady,
        isBusy: isBusy,
        status: status,
      );

  test('core ready + unverified status still counts as connected', () {
    expect(
      connected(
        tunnelReady: true,
        status: 'Aether: Running (unverified)',
      ),
      isTrue,
    );
  });

  test(
      'running without ready signal and without healthy status is not connected',
      () {
    expect(connected(), isFalse);
  });

  test('ready signal during auto-test is not shown as connected yet', () {
    expect(connected(tunnelReady: true, isBusy: true), isFalse);
  });

  test('stopped process is never reported as connected', () {
    expect(
      connected(
        isRunning: false,
        tunnelReady: true,
        status: 'Aether: Healthy',
      ),
      isFalse,
    );
  });

  test('healthy status still covers a fast-path connect', () {
    expect(connected(status: 'Aether: Healthy (fast-path)'), isTrue);
  });
}
