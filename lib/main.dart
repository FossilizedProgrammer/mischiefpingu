import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/app_provider.dart';
import 'providers/cdn_scanner_provider.dart';
import 'providers/sstp_fetcher_provider.dart';
import 'screens/main_screen.dart';

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

    // ⚠️ حیاتی: جلوگیری از بسته شدن خودکار تا وقتی shutdown کامل بشه.
    // بدون این خط، onWindowClose در MainScreen هیچ‌وقت اجرا نمی‌شه.
    await windowManager.setPreventClose(true);
  });

  runApp(
    MultiProvider(
      providers: [
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

// ═══════════════════════════════════════════════════
//  Theme definitions (public — قابل استفاده در همه‌جا)
// ═══════════════════════════════════════════════════
class AppThemeInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color seedColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  const AppThemeInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.seedColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });
}

const List<AppThemeInfo> appThemes = [
  AppThemeInfo(
    id: 'indigo',
    name: 'Indigo',
    icon: Icons.diamond_outlined,
    seedColor: Color(0xFF6366F1),
    secondaryColor: Color(0xFF8B5CF6),
    tertiaryColor: Color(0xFF06B6D4),
  ),
  AppThemeInfo(
    id: 'rose',
    name: 'Rose',
    icon: Icons.favorite_outline,
    seedColor: Color(0xFFE11D48),
    secondaryColor: Color(0xFFF472B6),
    tertiaryColor: Color(0xFFFB923C),
  ),
  AppThemeInfo(
    id: 'emerald',
    name: 'Emerald',
    icon: Icons.eco_outlined,
    seedColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF34D399),
    tertiaryColor: Color(0xFFA3E635),
  ),
  AppThemeInfo(
    id: 'amber',
    name: 'Amber',
    icon: Icons.wb_sunny_outlined,
    seedColor: Color(0xFFF59E0B),
    secondaryColor: Color(0xFFEF4444),
    tertiaryColor: Color(0xFF84CC16),
  ),
  AppThemeInfo(
    id: 'ocean',
    name: 'Ocean',
    icon: Icons.water_drop_outlined,
    seedColor: Color(0xFF0EA5E9),
    secondaryColor: Color(0xFF6366F1),
    tertiaryColor: Color(0xFF14B8A6),
  ),
  AppThemeInfo(
    id: 'slate',
    name: 'Slate',
    icon: Icons.contrast,
    seedColor: Color(0xFF64748B),
    secondaryColor: Color(0xFF94A3B8),
    tertiaryColor: Color(0xFFCBD5E1),
  ),
];

AppThemeInfo getThemeInfo(String id) {
  try {
    return appThemes.firstWhere((t) => t.id == id);
  } catch (_) {
    return appThemes.firstWhere((t) => t.id == 'ocean');
  }
}

ThemeData _buildTheme(String themeId, Brightness brightness) {
  final info = getThemeInfo(themeId);
  final isDark = brightness == Brightness.dark;
  final primaryColor = info.seedColor;
  final secondaryColor = info.secondaryColor;
  final accentColor = info.tertiaryColor;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: isDark ? const Color(0xFF0F172A) : Colors.white,
      onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
    ),
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark
          ? const Color(0xFF0F172A).withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.8),
      foregroundColor:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return isDark ? Colors.grey.shade600 : Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withValues(alpha: 0.5);
        }
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      }),
    ),
    dividerTheme: DividerThemeData(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.08),
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      selectedColor: primaryColor.withValues(alpha: isDark ? 0.3 : 0.25),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════
//  App root
// ═══════════════════════════════════════════════════
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final themeId = provider.settings.themeId;
    return MaterialApp(
      title: 'MischiefPingu',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(themeId, Brightness.light),
      darkTheme: _buildTheme(themeId, Brightness.dark),
      home: const MainScreen(),
    );
  }
}
