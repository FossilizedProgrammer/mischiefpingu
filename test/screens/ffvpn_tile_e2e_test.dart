// test/screens/ffvpn_tile_e2e_test.dart
//
// زنجیرهٔ کامل برای کارت تنظیمات Firefox VPN: تایل واقعی → provider واقعی →
// SharedPreferences (مثل geph_tile_e2e_test).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/ffvpn_provider.dart';
import 'package:mischiefpingu/screens/widgets/ffvpn_settings_tile.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_service.dart';
import 'package:mischiefpingu/services/ffvpn/ffvpn_browser_login.dart';
import 'dart:async';

class TestBrowserLogin extends FfvpnBrowserLogin {
  final result = Completer<FfvpnBrowserSession?>();
  bool opened = false;

  @override
  Future<FfvpnBrowserSession?> signIn({
    required String email,
    required String title,
    required void Function() onConfirming,
  }) async {
    opened = true;
    onConfirming();
    return result.future;
  }

  @override
  void cancel() {
    if (!result.isCompleted) result.complete(null);
  }
}

class TestFfvpnProvider extends FfvpnProvider {
  TestFfvpnProvider(AppProvider app, FfvpnBrowserLogin browser)
      : super(processService: app.processService, browserLogin: browser);

  @override
  Future<void> refreshUsage({required String sessionToken}) async {}
}

Future<AppProvider> pumpTile(
  WidgetTester tester,
  Widget tile, {
  AppProvider? app,
  FfvpnProvider? ffvpn,
  void Function(FfvpnProvider ffvpn)? onReady,
}) async {
  final provider = app ?? AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        if (ffvpn != null)
          ChangeNotifierProvider<FfvpnProvider>.value(value: ffvpn)
        else
          ChangeNotifierProvider<FfvpnProvider>(
            create: (_) =>
                FfvpnProvider(processService: provider.processService),
          ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: SingleChildScrollView(child: tile)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (onReady != null) {
    final f = Provider.of<FfvpnProvider>(
      tester.element(find.byType(Scaffold)),
      listen: false,
    );
    onReady(f);
    await tester.pump(const Duration(milliseconds: 100));
  }
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

/// فیلتر را از منو باز می‌کند و گزینهٔ [label] را انتخاب می‌کند.
Future<void> pickFilter(WidgetTester tester, String label) async {
  final filter = find.byKey(const ValueKey('ffvpn-country-filter'));
  await tester.ensureVisible(filter);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(filter);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// کشورهای آزمایشی: یکی رایگان و یکی قفل‌شدهٔ پرمیوم.
List<FfvpnCountry> _countries() => const [
      FfvpnCountry(
        code: 'NL',
        name: 'Netherlands',
        locked: false,
        servers: 5,
        cities: 2,
      ),
      FfvpnCountry(
        code: 'DE',
        name: 'Germany',
        locked: true,
        servers: 3,
        cities: 1,
      ),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offers browser login without an app password field',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const FirefoxVpnSettingsTile());
    await expand(tester, 'Firefox VPN Settings');

    expect(find.text('Mozilla browser sign-in / sign-up'), findsOneWidget);
    expect(find.text('Firefox Account email (optional)'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
    provider.dispose();
  });

  testWidgets('browser login accepts blank email and saves the confirmed token',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppProvider();
    final browser = TestBrowserLogin();
    final ffvpn = TestFfvpnProvider(app, browser);
    await pumpTile(tester, const FirefoxVpnSettingsTile(),
        app: app, ffvpn: ffvpn);
    await expand(tester, 'Firefox VPN Settings');
    final button = find.text('Open Mozilla sign-in');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(browser.opened, true);
    expect(find.text('Cancel'), findsOneWidget);
    expect(app.settings.ffvpnSessionToken, isEmpty);

    final token = 'a' * 64;
    browser.result.complete(FfvpnBrowserSession(token, 'user@example.com'));
    await tester.pumpAndSettle();
    expect(app.settings.ffvpnSessionToken, token);
    expect(find.text('Signed in — session token saved.'), findsOneWidget);
    expect(find.text(token), findsOneWidget);
    final saved = await app.persistence.loadSettings();
    expect(saved.ffvpnSessionToken, token);
    app.dispose();
    ffvpn.dispose();
  });

  testWidgets('cancelling browser login preserves the existing manual token',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'ffvpnSessionToken': 'b' * 64}),
    });
    final app = AppProvider();
    app.settings.ffvpnSessionToken = 'b' * 64;
    final browser = TestBrowserLogin();
    final ffvpn = TestFfvpnProvider(app, browser);
    await pumpTile(tester, const FirefoxVpnSettingsTile(),
        app: app, ffvpn: ffvpn);
    await expand(tester, 'Firefox VPN Settings');
    final button = find.text('Open Mozilla sign-in');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(app.settings.ffvpnSessionToken, 'b' * 64);
    expect(find.text('Open Mozilla sign-in'), findsOneWidget);
    expect(ffvpn.signInError, isNull);
    app.dispose();
    ffvpn.dispose();
  });

  testWidgets('collapsing settings cancels an active browser login',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'ffvpnSessionToken': 'b' * 64}),
    });
    final app = AppProvider();
    final browser = TestBrowserLogin();
    final ffvpn = TestFfvpnProvider(app, browser);
    await pumpTile(tester, const FirefoxVpnSettingsTile(),
        app: app, ffvpn: ffvpn);
    await expand(tester, 'Firefox VPN Settings');
    final button = find.text('Open Mozilla sign-in');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(ffvpn.isSigningIn, true);

    await expand(tester, 'Firefox VPN Settings');
    await tester.pumpAndSettle();
    expect(await browser.result.future, isNull);
    expect(ffvpn.isSigningIn, false);
    expect(app.settings.ffvpnSessionToken, 'b' * 64);
    app.dispose();
    ffvpn.dispose();
  });

  testWidgets('the country filter choice persists through the real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const FirefoxVpnSettingsTile());
    expect(provider.settings.ffvpnCountryFilter, 'free');

    await expand(tester, 'Firefox VPN Settings');
    await pickFilter(tester, 'Premium only');

    expect(provider.settings.ffvpnCountryFilter, 'plus');

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.ffvpnCountryFilter, 'plus');
    provider.dispose();
  });

  testWidgets('the saved country filter is restored when settings reopen',
      (tester) async {
    // مثل دفعهٔ قبل که کاربر «فقط پرمیوم» را انتخاب کرده بود.
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'ffvpnCountryFilter': 'plus'}),
    });

    final provider = AppProvider();
    provider.settings = await provider.persistence.loadSettings();
    await pumpTile(tester, const FirefoxVpnSettingsTile(), app: provider);
    expect(provider.settings.ffvpnCountryFilter, 'plus');

    await expand(tester, 'Firefox VPN Settings');
    expect(find.text('Premium only'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('a legacy premium switch is migrated and shows every country',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'ffvpnShowPremiumCountries': true}),
    });

    final provider = AppProvider();
    provider.settings = await provider.persistence.loadSettings();
    expect(provider.settings.ffvpnCountryFilter, 'all');

    await pumpTile(
      tester,
      const FirefoxVpnSettingsTile(),
      app: provider,
      onReady: (f) => f.countries = _countries(),
    );
    await expand(tester, 'Firefox VPN Settings');
    await tester.pump(const Duration(milliseconds: 200));

    // در حالت «همه»، کشور پرمیوم هم با برچسب premium دیده می‌شود.
    final country = find.text('Automatic (server-recommended)');
    await tester.ensureVisible(country);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(country);
    await tester.pumpAndSettle();

    expect(find.text('NL · Netherlands'), findsWidgets);
    expect(find.text('DE · Germany — premium'), findsWidgets);
    provider.dispose();
  });

  testWidgets('“free only” hides premium exits from the country list',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'ffvpnCountryFilter': 'free'}),
    });

    final provider = AppProvider();
    provider.settings = await provider.persistence.loadSettings();
    await pumpTile(
      tester,
      const FirefoxVpnSettingsTile(),
      app: provider,
      onReady: (f) => f.countries = _countries(),
    );
    await expand(tester, 'Firefox VPN Settings');
    await tester.pump(const Duration(milliseconds: 200));

    final country = find.text('Automatic (server-recommended)');
    await tester.ensureVisible(country);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(country);
    await tester.pumpAndSettle();

    expect(find.text('NL · Netherlands'), findsWidgets);
    expect(find.text('DE · Germany — premium'), findsNothing);
    provider.dispose();
  });
}
