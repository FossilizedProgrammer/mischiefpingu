import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/services/process/process_happy_detector.dart';

void main() {
  test('fires once per disconnected → connected transition', () {
    final fired = <String>[];
    final detector = ProcessHappyDetector(onHappy: fired.add);

    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );
    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: true,
      isConnected: true,
    );
    expect(fired, ['Aether']);

    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: true,
      isConnected: false,
    );
    detector.reset('Aether');
    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );
    expect(fired, ['Aether', 'Aether']);
  });

  test('cooldown suppresses an immediate reconnect after a drop', () {
    final fired = <String>[];
    final detector = ProcessHappyDetector(onHappy: fired.add);

    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );
    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: true,
      isConnected: false,
    );
    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );

    expect(fired, ['Aether']);
  });

  test('tunnels are tracked independently', () {
    final fired = <String>[];
    final detector = ProcessHappyDetector(onHappy: fired.add);

    detector.checkTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );
    detector.checkTransition(
      tunnelName: 'Psiphon',
      wasConnected: false,
      isConnected: true,
    );

    expect(fired, ['Aether', 'Psiphon']);
  });
}
