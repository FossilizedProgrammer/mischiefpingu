library;

import 'package:flutter/material.dart';

import 'app_theme_info.dart';

ThemeData buildAppTheme(String themeId, Brightness brightness) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    scrollbarTheme: _appScrollbarTheme(isDark),
  );
}

/// اسکرول‌بار ستون همیشه نمایان؛ بدون آن دسکتاپ فقط هنگام اسکرول نشان می‌دهد.
ScrollbarThemeData _appScrollbarTheme(bool isDark) {
  final base = isDark ? Colors.white : const Color(0xFF0F172A);
  return ScrollbarThemeData(
    thumbVisibility: WidgetStatePropertyAll<bool>(true),
    trackVisibility: WidgetStatePropertyAll<bool>(true),
    interactive: true,
    thickness: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered) ? 12.0 : 10.0,
    ),
    radius: const Radius.circular(6),
    crossAxisMargin: 4,
    mainAxisMargin: 8,
    minThumbLength: 40,
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.dragged)) {
        return base.withValues(alpha: isDark ? 0.75 : 0.6);
      }
      if (states.contains(WidgetState.hovered)) {
        return base.withValues(alpha: isDark ? 0.55 : 0.42);
      }
      return base.withValues(alpha: isDark ? 0.38 : 0.28);
    }),
    trackColor: WidgetStatePropertyAll<Color>(
      base.withValues(alpha: isDark ? 0.1 : 0.07),
    ),
    trackBorderColor: WidgetStatePropertyAll<Color>(
      base.withValues(alpha: isDark ? 0.16 : 0.12),
    ),
  );
}
