library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherProfileLabels — توابع کمکی برای ترجمهٔ پروفایل‌ها.
/// ═══════════════════════════════════════════════════════════════
class AetherProfileLabels {
  AetherProfileLabels._();

  static String label(String id, AppLocalizations l10n) {
    switch (id) {
      case 'adaptive':
        return l10n.profileAdaptive;
      case 'patchy':
        return l10n.profilePatchy;
      case 'strict':
        return l10n.profileStrict;
      case 'manual':
        return l10n.profileManual;
      default:
        return id;
    }
  }

  static String description(String id, AppLocalizations l10n) {
    switch (id) {
      case 'adaptive':
        return l10n.profileAdaptiveDesc;
      case 'patchy':
        return l10n.profilePatchyDesc;
      case 'strict':
        return l10n.profileStrictDesc;
      case 'manual':
        return l10n.profileManualDesc;
      default:
        return '';
    }
  }

  static IconData icon(String id) {
    switch (id) {
      case 'adaptive':
        return Icons.auto_awesome;
      case 'patchy':
        return Icons.network_check;
      case 'strict':
        return Icons.security;
      case 'manual':
        return Icons.tune;
      default:
        return Icons.tune;
    }
  }
}
