// زنجیره کامل: تایل واقعی → provider واقعی → SharedPreferences
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/ffvpn_provider.dart';
import 'package:mischiefpingu/screens/widgets/aether_settings_tile.dart';
import 'package:mischiefpingu/screens/widgets/sstp_settings_tile.dart';
import 'package:mischiefpingu/screens/widgets/ffvpn_settings_tile.dart';

Future<AppProvider> pumpTile(WidgetTester tester, Widget tile) async {
  final provider = AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        ChangeNotifierProvider<FfvpnProvider>(
          create: (_) => FfvpnProvider(processService: provider.processService),
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

  testWidgets('a preset hides protocol/scan/obfuscation controls',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const AetherSettingsTile());
    expect(provider.settings.aetherProfile, 'adaptive');

    await expand(tester, 'Aether Settings');

    expect(find.text('Protocol'), findsNothing);
    expect(find.text('Scan mode'), findsNothing);
    expect(find.text('Obfuscation (--noize)'), findsNothing);
    expect(
      find.textContaining('follow the selected preset'),
      findsOneWidget,
    );
    // تنظیمات واقعاً مؤثر پروفایل پنهان نمی‌شوند.
    expect(find.text('IP Type'), findsOneWidget);
    provider.dispose();
  });

  testWidgets(
      'manual mode shows the controls and hides scan on a custom endpoint',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const AetherSettingsTile());
    provider.settings.applyAetherProfile('manual');
    provider.touch();
    await expand(tester, 'Aether Settings');
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Protocol'), findsOneWidget);
    expect(find.text('Scan mode'), findsOneWidget);
    expect(find.text('Obfuscation (--noize)'), findsOneWidget);

    // با endpoint سفارشی، argv اصلاً --scan نمی‌گیرد.
    provider.settings.aetherCustomEndpoint = '1.2.3.4:2408';
    provider.touch();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Scan mode'), findsNothing);
    expect(find.text('Obfuscation (--noize)'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('manual mode offers Verified scan and the core default noize',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const AetherSettingsTile());
    provider.settings.applyAetherProfile('manual');
    provider.touch();
    await expand(tester, 'Aether Settings');
    await tester.pump(const Duration(milliseconds: 200));

    // «Default (core)» یعنی --noize پاس نمی‌شود و خود هسته تصمیم می‌گیرد.
    expect(find.text('Default (core)'), findsOneWidget);

    await tester.ensureVisible(find.text('Balanced').first);
    await tester.tap(find.text('Balanced').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verified').last);
    await tester.pumpAndSettle();

    expect(provider.settings.aetherScanMode, 'verified');
    provider.dispose();
  });

  testWidgets('Aether auto-reconnect switch persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const AetherSettingsTile());
    expect(provider.settings.autoReconnectAether, isTrue);

    await expand(tester, 'Aether Settings');

    final autoSwitch = find.text('Auto-reconnect Aether');
    await tester.ensureVisible(autoSwitch);
    await tester.pump();
    await tester.tap(autoSwitch);
    await tester.pump();
    expect(provider.settings.autoReconnectAether, isFalse);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.autoReconnectAether, isFalse);
    provider.dispose();
  });
}
