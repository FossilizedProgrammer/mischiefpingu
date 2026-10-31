// test/models/aether_profile_test.dart
//
// حالت پیش‌فرض باید همان تلاش اول کلاینت اندرویدی باشد:
//   libaether.so --bind … --scan balanced --masque --h2
// بدون fragment و بدون noize؛ فallback به HTTP-3 و حالت‌های تودرتو بعداً.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/aether/aether_args_builder.dart';

void main() {
  test('the default Aether attempt matches the Android reference client', () {
    final s = AppSettings();
    expect(s.aetherProfile, 'adaptive');

    final profile = aetherProfileById('adaptive')!;
    expect(profile.scanMode, 'balanced');
    expect(profile.noize, 'off');

    final first = profile.candidates.first;
    expect(first.protocol, 'masque');
    expect(first.masque, 'HTTP-2');
    expect(first.fragmentH2, isFalse);
    expect(profile.candidates[1].masque, 'HTTP-3');

    s.applyAetherProfile('adaptive');
    final args = AetherArgsBuilder(s).build(
      protocol: first.protocol,
      masqueOption: first.masque,
      port: 1819,
    );

    expect(args, contains('--masque'));
    expect(args, contains('--h2'));
    expect(args, isNot(contains('--fragment')));
    expect(args, isNot(contains('--noize')));
    expect(args[args.indexOf('--scan') + 1], 'balanced');
  });

  test('manual mode defaults to HTTP-2 as well', () {
    expect(AppSettings().masqueOption, 'HTTP-2');
  });
}
