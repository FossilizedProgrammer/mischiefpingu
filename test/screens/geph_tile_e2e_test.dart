// test/screens/geph_tile_e2e_test.dart
//
// زنجیرهٔ کامل برای کارت تنظیمات گف: تایل واقعی → provider واقعی →
// SharedPreferences (مثل lantern_tile_e2e_test).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/geph_provider.dart';
import 'package:mischiefpingu/screens/widgets/geph_settings_tile.dart';
import 'package:mischiefpingu/services/geph/geph_cli_service.dart';
import 'package:mischiefpingu/services/process_service.dart';

Future<AppProvider> pumpTile(
  WidgetTester tester,
  Widget tile, {
  AppProvider? app,
  GephProvider? geph,
  void Function(GephProvider geph)? onReady,
}) async {
  final provider = app ?? AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        if (geph != null)
          ChangeNotifierProvider<GephProvider>.value(value: geph)
        else
          ChangeNotifierProvider<GephProvider>(
            create: (_) =>
                GephProvider(processService: provider.processService),
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
  // کشِ داخلی کشورها (اگر روی دیسک باشد) همین‌جا settle می‌شود؛ بعد از آن
  // می‌توان لیست آزمایشی را seed کرد تا نتیجه قطعی بماند.
  if (onReady != null) {
    final geph = Provider.of<GephProvider>(tester.element(find.byType(Scaffold)),
        listen: false);
    onReady(geph);
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

/// دکمه‌ای را با متنِ برچسبش پیدا و لمس می‌کند (پس از visible کردن).
///
/// لمس روی Text داخل دکمه به onPressed خودِ دکمه می‌رسد.
Future<void> tapButton(WidgetTester tester, String label) async {
  final b = find.text(label);
  await tester.ensureVisible(b);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(b);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('geph HTTP port edit persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const GephSettingsTile());
    expect(provider.settings.gephHttpPort, 9910);
    expect(provider.settings.gephSocksPort, 9909);

    await expand(tester, 'Geph Settings');

    final httpField = find.widgetWithText(TextFormField, '9910');
    expect(httpField, findsOneWidget);
    await tester.enterText(httpField, '9093');
    await tester.pump();

    expect(provider.settings.gephHttpPort, 9093);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.gephHttpPort, 9093);
    provider.dispose();
  });

  testWidgets('geph upstream choice persists through real provider',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const GephSettingsTile());

    await expand(tester, 'Geph Settings');

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

    expect(provider.settings.gephUpstreamType, 4);

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.gephUpstreamType, 4);
    provider.dispose();
  });

  testWidgets('geph country is written back through the dropdown',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(
      tester,
      const GephSettingsTile(),
      onReady: (geph) => geph.countries = const [
        GephCountryInfo(
          code: 'NL',
          name: 'Netherlands',
          exits: 3,
          free: true,
          cities: 'Amsterdam(3)',
        ),
      ],
    );

    await expand(tester, 'Geph Settings');

    final country = find.byKey(const ValueKey('geph-country'));
    expect(country, findsOneWidget);
    await tester.ensureVisible(country);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(country);
    await tester.pumpAndSettle();

    final item = find.text('NL — Netherlands (free, 3)').last;
    expect(item, findsOneWidget);
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(provider.settings.gephCountry, 'NL');

    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.gephCountry, 'NL');
    provider.dispose();
  });

  testWidgets('the country filter hides non-matching exits', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(
      tester,
      const GephSettingsTile(),
      onReady: (geph) => geph.countries = const [
        GephCountryInfo(
          code: 'NL',
          name: 'Netherlands',
          exits: 3,
          free: true,
          cities: 'Amsterdam(3)',
        ),
        GephCountryInfo(
          code: 'DE',
          name: 'Germany',
          exits: 2,
          free: false,
          cities: 'Berlin(2)',
        ),
      ],
    );

    await expand(tester, 'Geph Settings');

    // بدون فیلتر، هر دو کشور در لیست هستند.
    final country = find.byKey(const ValueKey('geph-country'));
    await tester.ensureVisible(country);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(country);
    await tester.pumpAndSettle();
    expect(find.text('NL — Netherlands (free, 3)'), findsWidgets);
    expect(find.text('DE — Germany (plus, 2)'), findsWidgets);

    // با انتخاب کشورِ رایگان، منو بسته می‌شود.
    await tester.tap(find.text('NL — Netherlands (free, 3)').last);
    await tester.pumpAndSettle();

    // فیلتر «فقط رایگان» → کشور پرمیوم از لیست حذف می‌شود.
    final filter = find.byKey(const ValueKey('geph-country-filter'));
    await tester.ensureVisible(filter);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(filter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Free only').last);
    await tester.pumpAndSettle();

    await tester.tap(country);
    await tester.pumpAndSettle();
    expect(find.text('NL — Netherlands (free, 3)'), findsWidgets);
    expect(find.text('DE — Germany (plus, 2)'), findsNothing);

    // انتخاب فیلتر باید مثل بقیهٔ تنظیمات گف ذخیره شود.
    expect(provider.settings.gephCountryFilter, 'free');
    await tester.pump(const Duration(milliseconds: 300));
    final reloaded = await provider.persistence.loadSettings();
    expect(reloaded.gephCountryFilter, 'free');
    provider.dispose();
  });

  testWidgets('the saved country filter is restored when settings reopen',
      (tester) async {
    // مثل دفعهٔ قبل که کاربر «فقط رایگان» را انتخاب کرده بود.
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'gephCountryFilter': 'free'}),
    });

    final provider = AppProvider();
    provider.settings = await provider.persistence.loadSettings();
    await pumpTile(tester, const GephSettingsTile(), app: provider);
    expect(provider.settings.gephCountryFilter, 'free');

    await expand(tester, 'Geph Settings');

    final filter = find.byKey(const ValueKey('geph-country-filter'));
    expect(filter, findsOneWidget);
    await tester.ensureVisible(filter);
    await tester.pump(const Duration(milliseconds: 200));

    // گزینهٔ ذخیره‌شده از قبل انتخاب است (بدون لمس دوباره).
    final dropdown = tester.widget<DropdownButtonFormField<String>>(filter);
    expect(dropdown.initialValue, 'free');
    expect(find.text('Free only'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('account inputs are hidden until “I have an account”',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const GephSettingsTile());

    await expand(tester, 'Geph Settings');

    // پیش‌فرض: هیچ ورودی حسابی دیده نمی‌شود.
    expect(find.byKey(const ValueKey('geph-account-source')), findsNothing);
    expect(find.byKey(const ValueKey('geph-account-file')), findsNothing);
    expect(find.byKey(const ValueKey('geph-login-code')), findsNothing);

    await tapButton(tester, 'I have an account');

    // منبع پیش‌فرض «فایل» است → فیلد مسیر فایل ظاهر می‌شود.
    expect(find.byKey(const ValueKey('geph-account-source')), findsOneWidget);
    expect(find.byKey(const ValueKey('geph-account-file')), findsOneWidget);
    expect(find.byKey(const ValueKey('geph-login-code')), findsNothing);

    // تغییر منبع به «کد لاگین» فیلد کد را نشان می‌دهد.
    final source = find.byKey(const ValueKey('geph-account-source'));
    await tester.ensureVisible(source);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(source);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login code').last);
    await tester.pumpAndSettle();

    expect(provider.settings.gephAccountSource,
        AppSettings.gephAccountSourceCode);
    expect(find.byKey(const ValueKey('geph-login-code')), findsOneWidget);
    expect(find.byKey(const ValueKey('geph-account-file')), findsNothing);
    provider.dispose();
  });

  testWidgets('create account stores the returned code and reports the path',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    final geph = _CapturingGeph(processService: provider.processService);
    await pumpTile(tester, const GephSettingsTile(), app: provider, geph: geph);

    await expand(tester, 'Geph Settings');

    await tapButton(tester, 'Create account');

    expect(geph.lastArgs, contains('signup'));
    // کدِ تازه در تنظیمات ذخیره و مسیر فایل به کاربر نشان داده می‌شود.
    expect(provider.settings.gephAccountCode, _CapturingGeph.createdCode);
    expect(
      find.text('Login code saved to ${_CapturingGeph.accountFile}'),
      findsOneWidget,
    );
    provider.dispose();
  });
}

/// GephProvider جعلی: argv بدون I/O ساخته می‌شود و اجرا انجام نمی‌شود.
class _CapturingGeph extends GephProvider {
  _CapturingGeph({required super.processService}) : _ps = processService;

  static const String createdCode = 'gg_created_code_0001';
  static const String accountFile = '/data/geph/account.txt';

  final ProcessService _ps;
  List<String>? lastArgs;

  _NoIoCli? _cli;

  @override
  GephCliService cliFor(AppSettings settings) =>
      _cli ??= _NoIoCli(settings: settings, processService: _ps);

  @override
  Future<GephCommandResult?> runCommand(
    AppSettings settings,
    Future<List<String>> argsFuture, {
    required String label,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    lastArgs = await argsFuture;
    return const GephCommandResult(exitCode: 0, output: 'ok');
  }
}

/// CLI بدون دسترسی به دیسک — ساخت argv همان منطق واقعی را دارد.
class _NoIoCli extends GephCliService {
  _NoIoCli({required super.settings, required super.processService});

  @override
  Future<List<String>> signupArgs() async => ['signup'];

  @override
  Future<String> resolvedAccountFile() async => _CapturingGeph.accountFile;

  @override
  Future<String?> readAccountCode() async => _CapturingGeph.createdCode;
}
