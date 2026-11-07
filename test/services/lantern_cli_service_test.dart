// test/services/lantern_cli_service_test.dart
//
// تست سرویس CLI لنترن: ساخت argv از تنظیمات، parse کردن خروجی
// `servers --json`، پاک‌سازی کدهای ANSI و ماسک کردن اطلاعات حساس.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/lantern/lantern_cli_service.dart';
import 'package:mischiefpingu/services/lantern/lantern_upstream_builder.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  late AppSettings settings;
  late LanternCliService cli;

  setUp(() {
    settings = AppSettings();
    cli = LanternCliService(
      settings: settings,
      processService: ProcessService(),
    );
  });

  group('startArgs', () {
    test('binds the SOCKS/HTTP ports', () {
      settings
        ..lanternSocksPort = 18071
        ..lanternHttpPort = 18070;

      final args = cli.startArgs();

      expect(args, contains('start'));
      expect(
        args,
        containsAllInOrder(['--socks-proxy-addr', '127.0.0.1:18071']),
      );
      expect(
        args,
        containsAllInOrder(['--http-proxy-addr', '127.0.0.1:18070']),
      );
      // همیشه --raw تا خروجی بدون ANSI بماند.
      expect(args, contains('--raw'));
    });

    test('omits --http-proxy-addr when the HTTP port is 0', () {
      settings.lanternHttpPort = 0;
      final args = cli.startArgs();
      expect(args, isNot(contains('--http-proxy-addr')));
    });

    test('passes --upstream-proxy when an upstream URL is given', () {
      final args = cli.startArgs(upstreamUrl: 'socks5://127.0.0.1:1080');
      expect(
        args,
        containsAllInOrder(['--upstream-proxy', 'socks5://127.0.0.1:1080']),
      );
    });
  });

  group('globalArgs', () {
    test('always includes --raw and optional upstream only', () {
      final args = cli.globalArgs();
      expect(args, contains('--raw'));
      expect(args, isNot(contains('--upstream-proxy')));
    });

    test('never passes removed settings flags', () {
      final args = cli.globalArgs();
      expect(args, isNot(contains('--data-path')));
      expect(args, isNot(contains('--debug')));
      expect(args, isNot(contains('--insecure')));
      expect(args, isNot(contains('--with-proxyless')));
      expect(args, isNot(contains('--auth-url')));
      expect(args, isNot(contains('--server')));
      expect(args, isNot(contains('--sticky-config')));
      expect(args, isNot(contains('--readable-config')));
      expect(args, isNot(contains('--fronted-config')));
      expect(args, isNot(contains('--enable-dnstt')));
      expect(args, isNot(contains('--doh-resolver')));
      expect(args, isNot(contains('--dot-resolver')));
    });
  });

  group('side-command argv', () {
    test('serversArgs carries refresh/check/json flags', () {
      final args = cli.serversArgs(refresh: true, check: true);
      expect(args, contains('servers'));
      expect(args, contains('--refresh'));
      expect(args, contains('--check'));
      expect(args, contains('--json'));
    });

    test('updateArgs is a plain update with globals', () {
      final args = cli.updateArgs();
      expect(args, contains('update'));
      expect(args, isNot(contains('--via')));
      expect(args, isNot(contains('--check')));
      expect(args, isNot(contains('--rescan')));
    });

    test('side commands use no upstream when connection is direct', () {
      settings.lanternUpstreamType = LanternUpstreamBuilder.direct;
      expect(cli.serversArgs(), isNot(contains('--upstream-proxy')));
      expect(cli.updateArgs(), isNot(contains('--upstream-proxy')));
      expect(cli.authArgs('logout'), isNot(contains('--upstream-proxy')));
    });

    test('side commands use the manual upstream when configured', () {
      settings
        ..lanternUpstreamType = LanternUpstreamBuilder.manual
        ..lanternProxyType = 'socks5'
        ..lanternProxyIp = '10.0.0.2'
        ..lanternProxyPort = 2080;
      for (final args in [
        cli.serversArgs(),
        cli.updateArgs(),
        cli.authArgs('logout'),
      ]) {
        expect(
          args,
          containsAllInOrder(['--upstream-proxy', 'socks5://10.0.0.2:2080']),
        );
      }
    });

    test('authArgs builds login/signup/logout', () {
      final login = cli.authArgs('login', email: 'a@b.c', password: 'pw');
      expect(
        login,
        containsAllInOrder([
          'auth',
          'login',
          '--email',
          'a@b.c',
          '--password',
          'pw',
        ]),
      );

      final logout = cli.authArgs('logout');
      expect(logout, containsAllInOrder(['auth', 'logout']));
      expect(logout, isNot(contains('--password')));
    });
  });

  group('parseServersJson', () {
    test('parses the servers --json payload around pterm noise', () {
      const output = '''
INFO     Fetching servers…
[
  {
    "name": "Frankfurt",
    "addr": "1.2.3.4:443",
    "protocol": "https",
    "country_code": "DE",
    "country": "Germany",
    "city": "Frankfurt",
    "trusted": true,
    "reachable": true
  },
  {
    "name": "Tokyo",
    "addr": "5.6.7.8:443",
    "protocol": "https",
    "country_code": "JP",
    "country": "Japan",
    "city": "Tokyo",
    "trusted": false
  }
]
SUCCESS  done
''';
      final list = LanternCliService.parseServersJson(output);
      expect(list, isNotNull);
      expect(list, hasLength(2));

      expect(list!.first.name, 'Frankfurt');
      expect(list.first.address, '1.2.3.4:443');
      expect(list.first.countryCode, 'DE');
      expect(list.first.reachable, isTrue);
      expect(list.first.pinLabel, contains('Frankfurt'));

      expect(list.last.name, 'Tokyo');
      expect(list.last.reachable, isNull);
    });

    test('returns null for garbage output', () {
      expect(LanternCliService.parseServersJson('no json here'), isNull);
      expect(LanternCliService.parseServersJson('{"a":1}'), isNull);
    });
  });

  group('sanitizeLine', () {
    test('strips ANSI colours and cursor sequences', () {
      expect(
        LanternCliService.sanitizeLine('\x1b[32mSUCCESS\x1b[0m  Data path OK'),
        'SUCCESS  Data path OK',
      );
      expect(
        LanternCliService.sanitizeLine('\x1b[?25l\x1b[1GWaiting for proxy\x1b[?25h'),
        'Waiting for proxy',
      );
      expect(
        LanternCliService.sanitizeLine('Local proxy is listening — SOCKS5: x'),
        'Local proxy is listening — SOCKS5: x',
      );
      expect(LanternCliService.sanitizeLine('   '), isEmpty);
    });
  });

  group('maskArgs', () {
    test('masks passwords and upstream proxy credentials', () {
      final masked = LanternCliService.maskArgs([
        'auth',
        'login',
        '--email',
        'a@b.c',
        '--password',
        'secret',
      ]);
      expect(masked, isNot(contains('secret')));
      expect(masked, contains('****'));

      final upstream = LanternCliService.maskArgs([
        '--upstream-proxy',
        'socks5://user:pass@10.0.0.1:1080',
      ]);
      expect(upstream, isNot(contains('pass@')));
      expect(upstream, contains('socks5://user:****@10.0.0.1:1080'));
    });
  });
}
