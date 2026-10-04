import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/cdn_ip_checker.dart';
import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/cdn_scanner_provider.dart';
import 'package:mischiefpingu/widgets/cdn_scanner_section.dart';

const _kSaved = ['7.7.7.7', '4.4.4.4'];

Future<({CdnScannerProvider scan, AppProvider app})> pumpSection(
  WidgetTester tester, {
  List<String> customIps = const [],
  String? savedPreset,
  CdnIpChecker? checker,
}) async {
  tester.view.physicalSize = const Size(1400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    CdnScannerProvider.prefsCustomIps: customIps,
    if (savedPreset != null)
      CdnScannerProvider.prefsSelectedPreset: savedPreset,
  });
  final scan = CdnScannerProvider(checker: checker);
  // CdnScannerResults برای دکمه‌های «اعمال نتایج» به AppProvider نیاز دارد.
  // AppProvider تایمرهای دوره‌ای می‌سازد، پس باید قبل از پایان تست
  // آزاد شود وگرنه تست با خطای pending timer شکست می‌خورد.
  final app = AppProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: scan),
        ChangeNotifierProvider.value(value: app),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: CdnScannerSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('CDN IP Scanner'));
  await tester.pumpAndSettle();
  return (scan: scan, app: app);
}

String fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

/// چکر جعلی: به‌جای شبکه واقعی، نتیجه‌ی ثابت برمی‌گرداند و
/// آی‌پی‌هایی را که واقعاً برای اسکن انتخاب شده‌اند ثبت می‌کند.
class FakeChecker extends CdnIpChecker {
  final List<String> scanned = [];
  int _n = 0;

  @override
  Future<CdnCheckResult> checkFull(String ip, List<String> snis) async {
    scanned.add(ip);
    return CdnCheckResult(
      ip: ip,
      ok: true,
      latencyMs: 10,
      reliability: 5,
      sni: snis.isNotEmpty ? snis.first : '',
      message: 'fake',
      score: (++_n).toDouble(),
    );
  }
}

/// بعد از فشردن «شروع اسکن» صبر می‌کنیم تا اسکن تمام شود و سپس
/// AppProvider آزاد می‌شود تا تایمرهای دوره‌ای باقی نمانند.
Future<void> finishScan(
  WidgetTester tester,
  CdnScannerProvider scan,
  AppProvider app,
) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  app.dispose();
}

void main() {
  // Regression: انتخاب «کاستوم» باید آی‌پی‌های کاستوم را اسکن کند،
  // نه آی‌پی‌های آکامای.

  testWidgets('REG1: tap Custom then IMMEDIATELY Scan -> custom IPs', (
    tester,
  ) async {
    final checker = FakeChecker();
    final h = await pumpSection(
      tester,
      customIps: _kSaved,
      savedPreset: 'akamai',
      checker: checker,
    );
    await tester.tap(find.text('Custom (my IPs)'));
    // بدون pumpAndSettle: شبیه‌سازی فشردن فوری دکمه اسکن
    await tester.tap(find.text('Start Scan'));
    await finishScan(tester, h.scan, h.app);

    expect(h.scan.selectedPresetId, 'custom');
    expect(checker.scanned, ['7.7.7.7', '4.4.4.4']);
  });

  testWidgets('REG2: Custom chip then Scan after settle -> custom IPs', (
    tester,
  ) async {
    final checker = FakeChecker();
    final h = await pumpSection(
      tester,
      customIps: _kSaved,
      savedPreset: 'akamai',
      checker: checker,
    );
    await tester.tap(find.text('Custom (my IPs)'));
    await tester.pumpAndSettle();
    expect(fieldText(tester), '7.7.7.7\n4.4.4.4');

    await tester.tap(find.text('Start Scan'));
    await finishScan(tester, h.scan, h.app);
    expect(checker.scanned, ['7.7.7.7', '4.4.4.4']);
  });

  testWidgets('REG3: akamai -> custom -> akamai -> custom round trip', (
    tester,
  ) async {
    final checker = FakeChecker();
    final h = await pumpSection(
      tester,
      customIps: _kSaved,
      savedPreset: 'akamai',
      checker: checker,
    );
    for (final chip in ['Custom (my IPs)', 'Akamai', 'Custom (my IPs)']) {
      await tester.tap(find.text(chip));
      await tester.pumpAndSettle();
    }
    expect(h.scan.selectedPresetId, 'custom');
    expect(fieldText(tester), '7.7.7.7\n4.4.4.4');

    await tester.tap(find.text('Start Scan'));
    await finishScan(tester, h.scan, h.app);
    expect(checker.scanned, ['7.7.7.7', '4.4.4.4']);
  });

  testWidgets('REG4: non-custom preset still scans its own ranges', (
    tester,
  ) async {
    final checker = FakeChecker();
    final h = await pumpSection(
      tester,
      savedPreset: 'akamai',
      checker: checker,
    );
    expect(h.scan.selectedPresetId, 'akamai');
    h.scan.concurrency = 20;
    await tester.tap(find.text('Start Scan'));
    await tester.pump();
    h.scan.stop();
    h.app.dispose();

    expect(checker.scanned, isNotEmpty);
    // رنج‌های آکامای هیچ‌کدام نباید جزو آی‌پی‌های کاستوم باشند
    expect(checker.scanned, isNot(contains('7.7.7.7')));
  });

  testWidgets('REG5: restart on custom preset scans saved custom IPs', (
    tester,
  ) async {
    final checker = FakeChecker();
    final h = await pumpSection(
      tester,
      customIps: _kSaved,
      savedPreset: 'custom',
      checker: checker,
    );
    await tester.tap(find.text('Start Scan'));
    await finishScan(tester, h.scan, h.app);
    expect(checker.scanned, ['7.7.7.7', '4.4.4.4']);
  });
}