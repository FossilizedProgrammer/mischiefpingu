// lib/providers/sstp_fetcher/sstp_fetcher_auto_refresh.dart
part of '../sstp_fetcher_provider.dart';

extension SstpFetcherAutoRefresh on SstpFetcherProvider {
  void setAutoRefresh(bool value) {
    autoRefresh = value;
    autoTimer?.cancel();
    autoTimer = null;
    if (value) {
      autoTimer = Timer.periodic(const Duration(minutes: 15), (_) {
        fetchNow(autoCheckAfter: true);
      });
      processService.addLog(
        '→ vpngate auto-refresh enabled (every 15 min)',
        source: 'Vpngate',
      );
    } else {
      processService.addLog(
        '→ vpngate auto-refresh disabled',
        source: 'Vpngate',
      );
    }
    touch();
  }
}
