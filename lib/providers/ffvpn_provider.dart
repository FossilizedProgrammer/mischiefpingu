// lib/providers/ffvpn_provider.dart
//
// وضعیت queryهای غیرتونلی ffvpn برای UI تنظیمات:
//   • لیست کشورهای خروجی (کش کش‌شده بر اساس includePremium)
//   • مصرف سهمیهٔ ماهانهٔ پهنای باند

import 'package:flutter/foundation.dart';

import '../services/ffvpn/ffvpn_service.dart';
import '../services/process_service.dart';

class FfvpnProvider extends ChangeNotifier {
  FfvpnProvider({required ProcessService processService})
      : _processService = processService;

  final ProcessService _processService;

  void _log(String message) {
    _processService.addLog(message, source: LogSource.ffvpn);
  }

  // ─── لیست کشورها ───
  List<FfvpnCountry> countries = const [];
  bool isLoadingCountries = false;
  FfvpnException? countriesError;
  bool _countriesLoadedWithPremium = false;

  bool get hasCountries => countries.isNotEmpty;

  /// اگر لیست با همین تنظیم premium قبلاً بارگذاری شده، دوباره شبکه
  /// صدا نمی‌زند؛ مگر [force] true باشد (دکمهٔ refresh).
  Future<void> loadCountries({
    required bool includePremium,
    bool force = false,
  }) async {
    if (isLoadingCountries) return;
    if (!force && hasCountries && _countriesLoadedWithPremium == includePremium) {
      return;
    }

    isLoadingCountries = true;
    countriesError = null;
    notifyListeners();

    try {
      _log(includePremium
          ? '→ Fetching exit countries (including premium-locked)…'
          : '→ Fetching free-tier exit countries…');
      final list = await FfvpnService.listCountries(
        includePremium: includePremium,
        log: _log,
      );
      countries = list;
      _countriesLoadedWithPremium = includePremium;
      _log('★ Loaded ${list.length} exit countries');
    } on FfvpnException catch (e) {
      countriesError = e;
      _log('✗ Failed to load countries: ${e.detail}');
    } catch (e) {
      countriesError = FfvpnException(FfvpnErrorKind.other, '$e');
      _log('✗ Failed to load countries: $e');
    } finally {
      isLoadingCountries = false;
      notifyListeners();
    }
  }

  // ─── سهمیهٔ ماهانه ───
  FfvpnUsage? usage;
  bool isLoadingUsage = false;
  FfvpnException? usageError;

  Future<void> refreshUsage({required String sessionToken}) async {
    final token = sessionToken.trim();
    if (token.isEmpty) {
      usageError = const FfvpnException(
        FfvpnErrorKind.badToken,
        'no session token configured',
      );
      usage = null;
      notifyListeners();
      return;
    }
    if (isLoadingUsage) return;

    isLoadingUsage = true;
    usageError = null;
    notifyListeners();

    try {
      _log('→ Checking Firefox VPN bandwidth quota…');
      final u = await FfvpnService.fetchUsage(sessionToken: token, log: _log);
      usage = u;
      _log(u.unlimited
          ? '★ Quota: unlimited'
          : '★ Quota: ${FfvpnService.formatBytes(u.usedBytes)} of '
              '${FfvpnService.formatBytes(u.limitBytes)} used');
    } on FfvpnException catch (e) {
      usage = null;
      usageError = e;
      _log('✗ Failed to check quota: ${e.detail}');
    } catch (e) {
      usage = null;
      usageError = FfvpnException(FfvpnErrorKind.other, '$e');
      _log('✗ Failed to check quota: $e');
    } finally {
      isLoadingUsage = false;
      notifyListeners();
    }
  }
}
