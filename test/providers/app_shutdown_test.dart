// test/providers/app_shutdown_test.dart
//
// تست خاموش‌کردن تونل‌ها هنگام بسته‌شدن برنامه:
//   • هر ۷ تونل (از جمله Geph / Firefox VPN / Lantern) واقعاً بسته می‌شوند
//   • ترتیب: تونل‌های «لایهٔ بالا» قبل از آپ‌استریم‌هایشان
//   • تونل‌های خاموش دست نمی‌خورند و خطای یکی بقیه را متوقف نمی‌کند
//
// تونل‌ها با پرچم‌های running/busy «روشن» علامت می‌زنند (بدون پروسهٔ واقعی)؛
// تابع‌های stop وقتی پروسه‌ای وجود ندارد فقط state را پاک می‌کنند.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/providers/app_provider.dart';

const _dependentNames = ['Geph', 'Lantern', 'Firefox VPN'];
const _upstreamNames = ['Tor', 'Psiphon', 'SSTP', 'WireGuard'];
const _allNames = [..._dependentNames, ..._upstreamNames];

/// نام تونل‌هایی که خط «→ Stopping …» برایشان ثبت شده، به ترتیب لاگ.
List<String> _stoppedOrder(AppProvider p) {
  final order = <String>[];
  for (final line in p.processService.fullLog) {
    if (!line.contains('→ Stopping ')) continue;
    for (final name in _allNames) {
      if (line.contains('→ Stopping $name…')) {
        order.add(name);
        break;
      }
    }
  }
  return order;
}

bool _logged(AppProvider p, String needle) =>
    p.processService.fullLog.any((l) => l.contains(needle));

void markAllRunning(AppProvider p) {
  final ps = p.processService;
  ps.isPsiphonRunning = true;
  ps.isTorRunning = true;
  ps.isSstpRunning = true;
  ps.isWireGuardRunning = true;
  ps.isFfvpnRunning = true;
  ps.isLanternRunning = true;
  ps.isGephRunning = true;
}

void expectAllStopped(AppProvider p) {
  final ps = p.processService;
  expect(ps.isPsiphonRunning, isFalse);
  expect(ps.isTorRunning, isFalse);
  expect(ps.isSstpRunning, isFalse);
  expect(ps.isWireGuardRunning, isFalse);
  expect(ps.isFfvpnRunning, isFalse);
  expect(ps.isLanternRunning, isFalse);
  expect(ps.isGephRunning, isFalse);
  expect(p.hasActiveTunnel, isFalse);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('hasActiveTunnel', () {
    test('is false when nothing is running or busy', () {
      final p = AppProvider();
      expect(p.hasActiveTunnel, isFalse);
      p.dispose();
    });

    test('is true for each tunnel, running or busy', () {
      final tickets = <String, void Function(AppProvider)>{
        'psiphon running': (p) => p.processService.isPsiphonRunning = true,
        'psiphon busy': (p) => p.isPsiphonBusy = true,
        'tor running': (p) => p.processService.isTorRunning = true,
        'tor busy': (p) => p.isTorBusy = true,
        'sstp running': (p) => p.processService.isSstpRunning = true,
        'sstp busy': (p) => p.isSstpBusy = true,
        'wireguard running': (p) => p.processService.isWireGuardRunning = true,
        'wireguard busy': (p) => p.isWireGuardBusy = true,
        'ffvpn running': (p) => p.processService.isFfvpnRunning = true,
        'ffvpn busy': (p) => p.isFfvpnBusy = true,
        'lantern running': (p) => p.processService.isLanternRunning = true,
        'lantern busy': (p) => p.isLanternBusy = true,
        'geph running': (p) => p.processService.isGephRunning = true,
        'geph busy': (p) => p.isGephBusy = true,
      };

      for (final entry in tickets.entries) {
        final p = AppProvider();
        expect(p.hasActiveTunnel, isFalse, reason: entry.key);
        entry.value(p);
        expect(p.hasActiveTunnel, isTrue, reason: entry.key);
        p.dispose();
      }
    });
  });

  group('shutdownAll', () {
    test('closes every tunnel, including geph, lantern and firefox vpn',
        () async {
      final p = AppProvider();
      markAllRunning(p);

      await p.shutdownAll();

      expectAllStopped(p);
      expect(_stoppedOrder(p), unorderedEquals(_allNames));
      expect(_logged(p, '★ All tunnels disconnected. Safe to exit.'), isTrue);
      p.dispose();
    });

    test('stops the higher-layer tunnels before their upstreams', () async {
      final p = AppProvider();
      markAllRunning(p);

      await p.shutdownAll();

      final order = _stoppedOrder(p);
      final lastDependent = order.lastIndexWhere(_dependentNames.contains);
      final firstUpstream = order.indexWhere(_upstreamNames.contains);
      expect(lastDependent, isNonNegative);
      expect(firstUpstream, isNonNegative);
      expect(
        lastDependent,
        lessThan(firstUpstream),
        reason: 'ترتیب واقعی: $order',
      );
      p.dispose();
    });

    test('leaves untouched tunnels alone', () async {
      final p = AppProvider();
      p.processService.isGephRunning = true;

      await p.shutdownAll();

      expect(_stoppedOrder(p), ['Geph']);
      expect(p.processService.isTorRunning, isFalse);
      p.dispose();
    });

    test('also stops a tunnel that is only busy starting', () async {
      final p = AppProvider();
      p.isFfvpnBusy = true;

      await p.shutdownAll();

      expect(_stoppedOrder(p), ['Firefox VPN']);
      expect(p.processService.isFfvpnRunning, isFalse);
      // پرچم busy را خود startِ در جریان در finally پاک می‌کند.
      expect(p.userStoppedFfvpn, isTrue);
      p.dispose();
    });

    test('marks every tunnel as user-stopped so in-flight starts cancel',
        () async {
      final p = AppProvider();
      // مثل startهایی که همین حالا در جریانند.
      p.userStoppedPsiphon = false;
      p.userStoppedTor = false;
      p.userStoppedSstp = false;
      p.userStoppedWireGuard = false;
      p.userStoppedFfvpn = false;
      p.userStoppedLantern = false;
      p.userStoppedGeph = false;

      await p.shutdownAll();

      expect(p.userStoppedPsiphon, isTrue);
      expect(p.userStoppedTor, isTrue);
      expect(p.userStoppedSstp, isTrue);
      expect(p.userStoppedWireGuard, isTrue);
      expect(p.userStoppedFfvpn, isTrue);
      expect(p.userStoppedLantern, isTrue);
      expect(p.userStoppedGeph, isTrue);
      p.dispose();
    });

    test('a failing stop is reported and does not block the others', () async {
      final p = AppProvider();
      markAllRunning(p);
      // شکست عمدی: stopSstp در پایان کار این callback را صدا می‌زند.
      p.processService.onSstpStopped = () => throw StateError('boom');

      await p.shutdownAll();

      expect(_logged(p, '⚠ SSTP shutdown error'), isTrue);
      expect(_logged(p, 'did not stop cleanly'), isTrue);
      expect(_logged(p, 'Safe to exit'), isFalse);
      // بقیهٔ تونل‌ها با وجود خطای SSTP بسته شده‌اند.
      expect(p.processService.isGephRunning, isFalse);
      expect(p.processService.isTorRunning, isFalse);
      expect(p.processService.isFfvpnRunning, isFalse);
      expect(p.hasActiveTunnel, isFalse);
      p.dispose();
    });

    test('runs once — a second call is a no-op', () async {
      final p = AppProvider();
      markAllRunning(p);

      await p.shutdownAll();
      await p.shutdownAll();

      expect(_stoppedOrder(p).length, _allNames.length);
      p.dispose();
    });
  });
}
