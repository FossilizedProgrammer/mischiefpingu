part of '../sstp_fetcher_provider.dart';

extension SstpFetcherFetch on SstpFetcherProvider {
  Future<void> fetchNow({bool autoCheckAfter = false}) async {
    if (isLoading) return;
    isLoading = true;
    status = 'Fetching vpngate.net…';
    lastMessage = '';
    touch();

    try {
      String? proxy;
      try {
        proxy = resolveProxy();
      } on StateError catch (e) {
        isLoading = false;
        status = 'Proxy not available';
        lastMessage = e.message;
        touch();
        return;
      }

      final result = await _scraper.fetchAndParse(proxy: proxy);
      if (!result.ok) {
        isLoading = false;
        status = 'Fetch failed';
        lastMessage = result.message;
        touch();
        return;
      }

      final merged = await _store.merge(result.servers);
      servers = merged.all;
      isLoading = false;
      status = 'Total: ${servers.length} server(s)';
      lastMessage = merged.added > 0
          ? '★ Added ${merged.added} new server(s) (${result.servers.length} fetched)'
          : 'No new servers (${result.servers.length} fetched, all duplicates)';

      processService.addLog('★ vpngate: $lastMessage', source: 'Vpngate');

      touch();

      if (autoCheckAfter && servers.isNotEmpty && !isHealthChecking) {
        await checkAllHealth();
      }
    } catch (e) {
      isLoading = false;
      status = 'Error';
      lastMessage = '$e';
      touch();
    }
  }

  Future<void> clearAll() async {
    await _store.clear();
    servers = [];
    health.clear();
    status = 'Cleared';
    touch();
  }
}
