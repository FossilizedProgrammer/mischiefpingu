// test/screens/npv_tile_e2e_test.dart
//
// کارت تنظیمات NPV و بخش «Servers in this file»: رندر با دادهٔ واقعی
// خروجی `npv list -json` (رتبهٔ زنده‌ها، دلیل خطای مرده‌ها، برچسب
// «in use» برای کانفیگی که هسته انتخاب کرده).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/screens/widgets/npv_settings_tile.dart';
import 'package:mischiefpingu/services/npv/npv_server_list.dart';

Future<AppProvider> pumpTile(WidgetTester tester, Widget tile) async {
  final provider = AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
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

NpvServerList checkedInventory() => const NpvServerList(
      creatorMessage: 'https://t.me/configraygan',
      checked: true,
      total: 4,
      answered: 2,
      servers: [
        NpvServerEntry(
          index: 406,
          remark: 'alpha-1',
          proto: 'ss',
          kind: 'v2ray',
          transport: 'tcp/none',
          ok: true,
          medianMs: 12,
          error: '',
        ),
        NpvServerEntry(
          index: 414,
          remark: 'alpha-2',
          proto: 'vless',
          kind: 'v2ray',
          transport: 'tcp/tls',
          ok: true,
          medianMs: 34,
          error: '',
        ),
        NpvServerEntry(
          index: 562,
          remark: 'dead-1',
          proto: 'vmess',
          kind: 'v2ray',
          transport: 'ws/tls',
          ok: false,
          medianMs: 0,
          error: 'connection reset by peer',
        ),
        NpvServerEntry(
          index: 563,
          remark: 'ssh-1',
          proto: 'ssh',
          kind: 'ssh',
          transport: '',
          ok: false,
          medianMs: 0,
          error: 'dial tcp: i/o timeout',
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NPV tile lists the servers section with both actions',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');

    expect(find.text('Servers in this file'), findsOneWidget);
    expect(find.text('Show servers'), findsOneWidget);
    expect(find.text('Check servers'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('a fresh profile has no config file and no bundled default',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');

    expect(provider.settings.npvConfigName, isEmpty);
    expect(find.text('No file chosen yet'), findsOneWidget);
    expect(find.text('Choose file'), findsOneWidget);
    expect(find.textContaining('BOMB'), findsNothing);
    // هیچ دکمه‌ای برای برگشت به کانفیگ پیش‌فرض وجود ندارد.
    expect(find.text('Default'), findsNothing);
    provider.dispose();
  });

  testWidgets('checked inventory ranks live configs and flags dead ones',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');

    provider.processService
      ..npvServerList = checkedInventory()
      ..npvScanChecked = true
      ..npvScanError = null
      ..npvSelectedConfig = 'alpha-2';
    provider.touch();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2 of 4 configs work'), findsOneWidget);
    expect(find.text('https://t.me/configraygan'), findsNothing);
    expect(find.text('Note: https://t.me/configraygan'), findsOneWidget);

    // رتبه فقط به زنده‌ها داده می‌شود؛ سریع‌ترین #1 است.
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);

    expect(find.text('406. alpha-1'), findsOneWidget);
    expect(find.text('12 ms'), findsOneWidget);
    expect(find.text('34 ms'), findsOneWidget);
    expect(find.text('in use'), findsOneWidget);

    // مرده‌ها با آیکن قرمز و دلیل خطا در subtitle.
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.byIcon(Icons.cancel), findsNWidgets(2));
    expect(find.textContaining('dead-1'), findsOneWidget);
    expect(
      find.text('ss · tcp/none'),
      findsOneWidget,
    ); // زیرعنوان ردیف اول، بدون پیشوند خطا
    provider.dispose();
  });

  testWidgets('an empty file says so instead of showing a blank list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');

    provider.processService
      ..npvServerList = const NpvServerList(
        creatorMessage: '',
        checked: false,
        total: 0,
        answered: 0,
        servers: [],
      )
      ..npvScanChecked = false;
    provider.touch();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('This file has no configs.'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('tapping a row pins that config, tapping again unpins',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');
    provider.processService
      ..npvServerList = checkedInventory()
      ..npvScanChecked = true;
    provider.touch();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Auto (fastest)'), findsNothing);

    final row = find.text('414. alpha-2');
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(provider.settings.npvPinnedIndex, '414');
    expect(provider.settings.npvPinnedRemark, 'alpha-2');
    expect(find.text('selected'), findsOneWidget);
    expect(find.text('Selected: #414 · alpha-2'), findsOneWidget);
    expect(find.text('Auto (fastest)'), findsOneWidget);

    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(provider.settings.npvPinnedIndex, '');
    expect(provider.settings.npvPinnedRemark, '');
    expect(find.text('selected'), findsNothing);
    provider.dispose();
  });

  testWidgets('“Auto (fastest)” clears a pin made in an earlier session',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');
    provider.settings
      ..npvPinnedIndex = '562'
      ..npvPinnedRemark = 'dead-1';
    provider.processService
      ..npvServerList = checkedInventory()
      ..npvScanChecked = false;
    provider.touch();
    await tester.pump(const Duration(milliseconds: 300));

    // پین بدون فهرست هم نمایش داده می‌شود (remark ذخیره شده است).
    expect(find.text('Selected: #562 · dead-1'), findsOneWidget);

    await tester.tap(find.text('Auto (fastest)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(provider.settings.npvPinnedIndex, '');
    expect(find.text('Selected: #562 · dead-1'), findsNothing);
    provider.dispose();
  });

  testWidgets(
      'a pin missing from this file and a pin the core ignored '
      'are both reported', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpTile(tester, const NpvSettingsTile());

    await expand(tester, 'NPV Tunnel Settings');
    provider.settings
      ..npvPinnedIndex = '999'
      ..npvPinnedRemark = 'elsewhere';
    provider.processService
      ..npvServerList = checkedInventory()
      ..npvScanChecked = true;
    provider.touch();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('Selected config #999 is not in this file'),
      findsOneWidget,
    );

    // حالا پین معتبر است ولی هسته کانفیگ دیگری سرویس کرده: هستهٔ قدیمی.
    provider.settings
      ..npvPinnedIndex = '414'
      ..npvPinnedRemark = 'alpha-2';
    provider.processService
      ..isNpvRunning = true
      ..npvSelectedConfig = 'alpha-1';
    provider.touch();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('is not in this file'), findsNothing);
    expect(
      find.textContaining('The NPV core used a different config'),
      findsOneWidget,
    );
    provider.dispose();
  });
}
