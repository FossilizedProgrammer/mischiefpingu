// زنجیره کامل: تایل واقعی → provider واقعی → SharedPreferences
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/ffvpn_provider.dart';
import 'package:mischiefpingu/screens/widgets/sstp_settings_tile.dart';
import 'package:mischiefpingu/screens/widgets/ffvpn_settings_tile.dart';

Future<AppProvider> pumpTile(WidgetTester tester, Widget tile) async {
  final provider = AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        ChangeNotifierProvider<FfvpnProvider>(
          create: (_) =>
              FfvpnProvider(processService: provider.processService),
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

  testWidgets('SSTP HTTP port edit persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const SstpSettingsTile());
    expect(provider.settings.sstpHttpPort, 8082);

    await expand(tester, 'SSTP Settings');

    final httpField = find.widgetWithText(TextFormField, '8082');
    expect(httpField, findsOneWidget);
    await tester.enterText(httpField, '9090');
    await tester.pump();

    expect(provider.settings.sstpHttpPort, 9090);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.sstpHttpPort, 9090);
    provider.dispose();
  });

  testWidgets('ffvpn HTTP port edit persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const FirefoxVpnSettingsTile());
    expect(provider.settings.ffvpnHttpPort, 8083);

    await expand(tester, 'Firefox VPN Settings');

    final httpField = find.widgetWithText(TextFormField, '8083');
    expect(httpField, findsOneWidget);
    await tester.enterText(httpField, '9091');
    await tester.pump();

    expect(provider.settings.ffvpnHttpPort, 9091);
    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.ffvpnHttpPort, 9091);
    provider.dispose();
  });
}
