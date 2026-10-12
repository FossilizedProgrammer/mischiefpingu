// test/services/ffvpn_service_test.dart
//
// تست پارسرهای خروجی ffvpn — نمونه‌ها از خروجی واقعی باینری
// (پیشوند زمان Go log مانند "12:11:35 " دارند) برداشته شده‌اند.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/services/ffvpn/ffvpn_service.dart';

void main() {
  group('parseCountriesOutput', () {
    test('parses real full list with locked countries and US dedupe', () {
      const output = '''
12:11:35 Available exit countries (select with --country CODE):
12:11:35   ZA   South Africa           1 server, 1 city
12:11:35   PE   Peru                   1 server, 1 city (locked)
12:11:35   BR   Brazil                 1 server, 1 city (locked)
12:11:35   GB   United Kingdom         1 server, 1 city (locked)
12:11:35   CA   Canada                 1 server, 1 city (locked)
12:11:35   US   United States          4 servers, 2 cities
12:11:35   US   CatchAll Anycast       1 server, 1 city
''';
      final countries = FfvpnService.parseCountriesOutput(output);

      // US باید dedupe شده باشد (United States + CatchAll Anycast).
      expect(countries.length, 6);
      expect(countries.where((c) => c.code == 'US').length, 1);
      final us = countries.firstWhere((c) => c.code == 'US');
      expect(us.name, 'United States'); // نام anycast جایگزین نشود
      expect(us.servers, 5);
      expect(us.cities, 3);
      expect(us.locked, isFalse);

      final pe = countries.firstWhere((c) => c.code == 'PE');
      expect(pe.locked, isTrue);

      // مرتب‌سازی بر اساس نام
      final names = countries.map((c) => c.name).toList();
      expect(names, equals(names.toList()..sort()));
    });

    test('free-only output has no locked countries', () {
      const output = '''
12:11:37 Free-tier exit countries, premium-locked ones hidden (select with --country CODE):
12:11:37   ZA   South Africa           1 server, 1 city
12:11:37   AR   Argentina              1 server, 1 city
12:11:37   US   United States          1 server, 1 city
12:11:37   US   CatchAll Anycast       1 server, 1 city
''';
      final countries = FfvpnService.parseCountriesOutput(output);
      expect(countries, everyElement((c) => (c as FfvpnCountry).locked == false));
      expect(countries.length, 3);
    });

    test('recommended pseudo-row is skipped', () {
      const output = '''
12:11:35 Available exit countries (select with --country CODE):
12:11:35   REC  Recommended            1 server, 1 city
12:11:35   US   United States          2 servers, 1 city
''';
      final countries = FfvpnService.parseCountriesOutput(output);
      expect(countries.length, 1);
      expect(countries.first.code, 'US');
    });

    test('empty output yields empty list', () {
      expect(FfvpnService.parseCountriesOutput(''), isEmpty);
      expect(
        FfvpnService.parseCountriesOutput('12:11:35 some unrelated line'),
        isEmpty,
      );
    });
  });

  group('parseUsageOutput', () {
    test('parses human-readable quota line with reset date', () {
      const output = '''
12:11:40 FxA session OK (uid 6b2f21a9...)
12:11:40 Bandwidth: 1.8 GiB of 10.0 GiB used (18%), 8.2 GiB left resets 2026-11-01
''';
      final usage = FfvpnService.parseUsageOutput(output)!;
      expect(usage, isNotNull);
      expect(usage.unlimited, isFalse);
      expect(usage.usedBytes, closeTo(1.8 * 1024 * 1024 * 1024, 1024));
      expect(usage.limitBytes, closeTo(10.0 * 1024 * 1024 * 1024, 1024));
      expect(usage.remainingBytes, closeTo(8.2 * 1024 * 1024 * 1024, 1024));
      expect(usage.usedFraction, closeTo(0.18, 0.01));
      expect(usage.reset, DateTime.parse('2026-11-01'));
    });

    test('parses unlimited quota', () {
      const output = '12:11:40 Bandwidth: unlimited';
      final usage = FfvpnService.parseUsageOutput(output)!;
      expect(usage.unlimited, isTrue);
      expect(usage.usedFraction, isNull);
    });

    test('parses raw remaining/limit fallback', () {
      const output =
          '12:11:40 Bandwidth: remaining=8803881472 limit=10737418240';
      final usage = FfvpnService.parseUsageOutput(output)!;
      expect(usage.limitBytes, 10737418240);
      expect(usage.remainingBytes, 8803881472);
      expect(usage.usedBytes, 10737418240 - 8803881472);
    });

    test('returns null on unrelated output', () {
      expect(
        FfvpnService.parseUsageOutput('12:11:40 FxA session OK (uid abc)'),
        isNull,
      );
    });
  });

  group('classifyError', () {
    test('bad token', () {
      const out =
          'ffvpn: session token rejected by auth server: fxa: HTTP 401 errno 110: Invalid authentication token';
      expect(
        FfvpnService.classifyError(out),
        FfvpnErrorKind.badToken,
      );
    });

    test('not entitled (403)', () {
      const out = 'ffvpn: activating proxy service: guardian: account has no VPN entitlement (HTTP 403)';
      expect(FfvpnService.classifyError(out), FfvpnErrorKind.notEntitled);
    });

    test('region (451)', () {
      const out = 'ffvpn: fetching proxy pass: guardian: service not available in this region (HTTP 451)';
      expect(FfvpnService.classifyError(out), FfvpnErrorKind.region);
    });

    test('quota (429)', () {
      const out = 'ffvpn: fetching proxy pass: guardian: bandwidth quota exceeded (HTTP 429)';
      expect(FfvpnService.classifyError(out), FfvpnErrorKind.quota);
    });

    test('network', () {
      expect(
        FfvpnService.classifyError(
          'ffvpn: servers: HTTP 0 fetching server list: dial tcp: lookup failed',
        ),
        FfvpnErrorKind.network,
      );
    });
  });

  group('formatBytes', () {
    test('human units', () {
      expect(FfvpnService.formatBytes(500), '500 B');
      expect(FfvpnService.formatBytes(2048), '2.0 KiB');
      expect(FfvpnService.formatBytes(5 * 1024 * 1024), '5.0 MiB');
      expect(FfvpnService.formatBytes(3 * 1024 * 1024 * 1024), '3.0 GiB');
    });
  });
}
