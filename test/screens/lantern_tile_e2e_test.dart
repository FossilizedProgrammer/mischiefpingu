// test/screens/lantern_tile_e2e_test.dart
//
// زنجیرهٔ کامل برای کارت تنظیمات لنترن: تایل واقعی → provider واقعی →
// SharedPreferences (مثل tunnel_tiles_e2e_test).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/lantern_provider.dart';
import 'package:mischiefpingu/screens/widgets/lantern_settings_tile.dart';

Future<AppProvider> pumpTile(WidgetTester tester, Widget tile) async {
  final provider = AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        ChangeNotifierProvider<LanternProvider>(
          create: (_) =>
              LanternProvider(processService: provider.processService),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(child: tile),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return provider;
}

Future<void> expand(WidgetTester tester, String header) async {
  final h = find.text(header);
  await tester.ensureVisible(h);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(h);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lantern HTTP port edit persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const LanternSettingsTile());
    expect(provider.settings.lanternHttpPort, 18070);
    expect(provider.settings.lanternSocksPort, 18071);

    await expand(tester, 'Lantern Settings');

    final httpField = find.widgetWithText(TextFormField, '18070');
    expect(httpField, findsOneWidget);
    await tester.enterText(httpField, '9092');
    await tester.pump();

    expect(provider.settings.lanternHttpPort, 9092);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.lanternHttpPort, 9092);
    provider.dispose();
  });

  testWidgets('lantern upstream choice persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const LanternSettingsTile());

    await expand(tester, 'Lantern Settings');

    // dropdown آپ‌استریم را Tor (value 4) می‌کنیم.
    final dropdown = find.byType(DropdownButtonFormField<int>);
    expect(dropdown, findsOneWidget);
    await tester.ensureVisible(dropdown);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final torItem = find.text('Tor').last;
    expect(torItem, findsOneWidget);
    await tester.tap(torItem);
    await tester.pumpAndSettle();

    expect(provider.settings.lanternUpstreamType, 4);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.lanternUpstreamType, 4);
    provider.dispose();
  });
}
