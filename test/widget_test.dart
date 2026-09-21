import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mischiefpingu/l10n/locale_provider.dart';
import 'package:mischiefpingu/main.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/providers/cdn_scanner_provider.dart';
import 'package:mischiefpingu/providers/internet_quality_provider.dart';
import 'package:mischiefpingu/providers/sstp_fetcher_provider.dart';
import 'package:mischiefpingu/services/database/database_initializer.dart';

/// ═══════════════════════════════════════════════════════════════
///  Smoke test ساده برای اطمینان از اینکه MyApp بدون crash بالا میاد.
///
///  ⚠️ نکته:
///    • DatabaseInitializer برای sqflite_ffi لازمه
///    • از MultiProvider استفاده می‌کنیم دقیقاً مثل main.dart
///    • از pumpAndSettle استفاده نمی‌کنیم چون AppProvider
///      ممکنه async initialization داشته باشه
/// ═══════════════════════════════════════════════════════════════
void main() {
  setUpAll(() {
    // sqflite_ffi برای تست‌های دسکتاپ لازمه
    DatabaseInitializer.ensureInitialized();
  });

  testWidgets('App smoke test — MyApp boots without crashing', (tester) async {
    final localeProvider = LocaleProvider();
    final appProvider = AppProvider();
    final qualityProvider = InternetQualityProvider(
      processService: appProvider.processService,
    );
    appProvider.attachQualityProvider(qualityProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: localeProvider),
          ChangeNotifierProvider.value(value: appProvider),
          ChangeNotifierProvider.value(value: qualityProvider),
          ChangeNotifierProvider(create: (_) => CdnScannerProvider()),
          ChangeNotifierProvider(
            create: (_) =>
                SstpFetcherProvider(processService: appProvider.processService),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // ─── فقط چک می‌کنیم MaterialApp ساخته شد ───
    expect(find.byType(MaterialApp), findsOneWidget);

    // ─── cleanup ───
    await tester.pumpWidget(const SizedBox.shrink());
    appProvider.dispose();
    qualityProvider.dispose();
  });
}
