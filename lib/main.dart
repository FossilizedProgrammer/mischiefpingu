import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'providers/app_provider.dart';
import 'providers/cdn_scanner_provider.dart';
import 'providers/internet_quality_provider.dart';
import 'providers/sstp_fetcher_provider.dart';
import 'screens/main_screen.dart';
import 'services/database/database_initializer.dart';
import 'theme/theme_builder.dart';
import 'providers/bridge_scanner_provider.dart';

export 'theme/app_theme_info.dart' show AppThemeInfo, appThemes, getThemeInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // ─── دیتابیس ───
  DatabaseInitializer.ensureInitialized();

  await windowManager.setSize(const Size(780, 462));
  await windowManager.setMinimumSize(const Size(680, 420));

  const windowOptions = WindowOptions(
    size: Size(780, 462),
    minimumSize: Size(680, 420),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'MischiefPingu',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.center();

    final currentPosition = await windowManager.getPosition();
    final targetPosition = Offset(currentPosition.dx, 0);
    await windowManager.setPosition(targetPosition);
    await windowManager.focus();

    await windowManager.setPreventClose(true);
  });

  final localeProvider = LocaleProvider();
  await localeProvider.load();

  final appProvider = AppProvider();
  final qualityProvider = InternetQualityProvider(
    processService: appProvider.processService,
  );
  appProvider.attachQualityProvider(qualityProvider);

  // ─── بستن دیتابیس هنگام خروج ───
  // (شutdownAll خودش این را صدا می‌زند، ولی برای اطمینان اینجا هم هست)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // no-op — برای keep-alive import
    if (!DatabaseInitializer.isInitialized) {
      DatabaseInitializer.ensureInitialized();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: qualityProvider),
        ChangeNotifierProvider(create: (_) => CdnScannerProvider()),
        ChangeNotifierProvider(create: (_) => BridgeScannerProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              SstpFetcherProvider(processService: appProvider.processService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final themeId = provider.settings.themeId;
    final locale = localeProvider.locale;

    return MaterialApp(
      title: 'MischiefPingu',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: buildAppTheme(themeId, Brightness.light),
      darkTheme: buildAppTheme(themeId, Brightness.dark),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const MainScreen(),
    );
  }
}
