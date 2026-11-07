library;

import 'package:flutter/material.dart';

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
