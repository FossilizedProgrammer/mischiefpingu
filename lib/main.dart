import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'providers/cdn_scanner_provider.dart';
import 'providers/sstp_fetcher_provider.dart';
import 'screens/main_screen.dart';
import 'theme/theme_builder.dart';

export 'theme/app_theme_info.dart' show AppThemeInfo, appThemes, getThemeInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CdnScannerProvider()),
        ChangeNotifierProvider(
          create: (ctx) => SstpFetcherProvider(
            processService: ctx.read<AppProvider>().processService,
          ),
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainScreen(),
    );
  }
}
