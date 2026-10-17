// test/screens/window_close_handler_test.dart
//
// تست مسیر بستن پنجره: تصمیم «آیا قبل از خروج تونلی هست که بسته شود؟»
// باید *همهٔ* تونل‌ها را ببیند — نه فقط Psiphon/Tor/SSTP/WireGuard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/screens/mixins/window_close_handler.dart';

/// ویجتی که فقط mixin بستن پنجره را دارد.
class _CloseProbe extends StatefulWidget {
  const _CloseProbe();

  @override
  State<_CloseProbe> createState() => _CloseProbeState();
}

class _CloseProbeState extends State<_CloseProbe> with WindowCloseHandler {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Future<AppProvider> pumpProbe(WidgetTester tester) async {
  final provider = AppProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(body: _CloseProbe()),
      ),
    ),
  );
  await tester.pump();
  return provider;
}

/// بستن پنجره را صدا می‌زند و به زنجیرهٔ async آن فرصت اجرا می‌دهد.
Future<void> closeWindow(WidgetTester tester) async {
  tester
      .state<_CloseProbeState>(find.byType(_CloseProbe))
      .onWindowClose();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('closing with only Geph running stops it first', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpProbe(tester);
    provider.processService.isGephRunning = true;

    await closeWindow(tester);

    expect(provider.processService.isGephRunning, isFalse);
    expect(provider.hasActiveTunnel, isFalse);
    expect(provider.processService.fullLog.any(
      (l) => l.contains('★ All tunnels disconnected. Safe to exit.'),
    ), isTrue);
    provider.dispose();
  });

  testWidgets('closing with only Lantern running stops it first',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpProbe(tester);
    provider.processService.isLanternRunning = true;

    await closeWindow(tester);

    expect(provider.processService.isLanternRunning, isFalse);
    provider.dispose();
  });

  testWidgets('closing with only Firefox VPN running stops it first',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpProbe(tester);
    provider.processService.isFfvpnRunning = true;

    await closeWindow(tester);

    expect(provider.processService.isFfvpnRunning, isFalse);
    provider.dispose();
  });

  testWidgets('closing with a start in flight waits and stops it',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpProbe(tester);
    // مثل اینکه همین حالا دکمهٔ اتصال زده شده و برنامه در حال start است.
    provider.isGephBusy = true;

    await closeWindow(tester);

    expect(provider.userStoppedGeph, isTrue);
    expect(provider.processService.isGephRunning, isFalse);
    provider.dispose();
  });
}
