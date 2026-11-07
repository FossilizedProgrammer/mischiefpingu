// test/services/geph_cli_service_test.dart
//
// تست سرویس CLI گف: ساخت argv از تنظیمات، parse کردن خروجی
// `countries`، پاک‌سازی کدهای ANSI و ماسک کردن کد حساب.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/geph/geph_cli_service.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  late AppSettings settings;
  late GephCliService cli;

  setUp(() {
    settings = AppSettings();
    cli = GephCliService(
      settings: settings,
      processService: ProcessService(),
    );
  });

  group('runArgs', () {
    test('binds the SOCKS/HTTP ports, country and cache', () async {
      settings
        ..gephSocksPort = 9909
        ..gephHttpPort = 9910
        ..gephCountry = 'nl';

      final args = await cli.runArgs();

      expect(args, contains('run'));
      expect(args, containsAllInOrder(['--country', 'nl']));
      expect(args, containsAllInOrder(['--socks', '9909']));
      expect(args, containsAllInOrder(['--http', '9910']));
      expect(args, containsAllInOrder(['--cache', await GephCliService.cachePath()]));
      expect(args.first, '--account-file');
      expect(args[1], await GephCliService.accountFilePath());
    });

    test('http port 0 disables the HTTP listener', () async {
      settings.gephHttpPort = 0;
      final args = await cli.runArgs();
      expect(args, containsAllInOrder(['--http', 'none']));
    });

    test('an empty country falls back to auto', () async {
      settings.gephCountry = '';
      final args = await cli.runArgs();
      expect(args, containsAllInOrder(['--country', 'auto']));
    });

    test('--share-lan only when opted in', () async {
      expect(await cli.runArgs(), isNot(contains('--share-lan')));
      settings.gephShareLan = true;
      expect(await cli.runArgs(), contains('--share-lan'));
    });

    test('passes --upstream when an explicit URL is given', () async {
      final args = await cli.runArgs(upstreamUrl: 'socks5://127.0.0.1:1080');
      expect(
        args,
        containsAllInOrder(['--upstream', 'socks5://127.0.0.1:1080']),
      );
    });

    test('applies the configured manual upstream on its own', () async {
      settings
        ..gephUpstreamType = 1 // manual
        ..gephProxyIp = '10.0.0.7'
        ..gephProxyPort = 1080;
      final args = await cli.runArgs();
      expect(
        args,
        containsAllInOrder(['--upstream', 'socks5://10.0.0.7:1080']),
      );
    });

    test('a custom account file overrides the default path', () async {
      settings.gephAccountFile = '/tmp/my-geph-account.txt';
      final args = await cli.runArgs();
      expect(
        args,
        containsAllInOrder(['--account-file', '/tmp/my-geph-account.txt']),
      );
    });

    test('login-code source sends the saved code as --secret', () async {
      settings
        ..gephAccountSource = AppSettings.gephAccountSourceCode
        ..gephAccountCode = '  gg_login_code  ';

      final run = await cli.runArgs();
      expect(run, containsAllInOrder(['run', '--secret', 'gg_login_code']));

      final login = await cli.loginArgs();
      expect(login, containsAllInOrder(['login', '--secret', 'gg_login_code']));
    });

    test('file source never passes --secret', () async {
      settings
        ..gephAccountSource = AppSettings.gephAccountSourceFile
        ..gephAccountCode = 'leftover-code';
      expect(await cli.runArgs(), isNot(contains('--secret')));
      expect(await cli.loginArgs(), isNot(contains('--secret')));
    });

    test('the account/cache paths never collide with the binary name', () async {
      // باینری داخل پوشهٔ داده به شکل فایلِ `geph5-proxy` می‌نشیند؛ والدِ
      // مسیرها نباید هم‌نام آن باشد وگرنه create_dir_all با
      // «File exists (os error 17)» شکست می‌خورد.
      final account = await GephCliService.accountFilePath();
      final cache = await GephCliService.cachePath();

      for (final path in [account, cache]) {
        expect(p.basename(p.dirname(path)), GephCliService.dataSubdir);
        expect(
          p.basename(p.dirname(path)),
          isNot(GephCliService.binaryName),
        );
      }
    });

    test('hasConfiguredAccount follows the selected source', () async {
      settings.gephAccountSource = AppSettings.gephAccountSourceCode;
      expect(await cli.hasConfiguredAccount(), isFalse);

      settings.gephAccountCode = 'something';
      expect(await cli.hasConfiguredAccount(), isTrue);
    });
  });

  group('subcommand argv', () {
    test('countries and signup/login keep the global flags', () async {
      expect(await cli.countriesArgs(level: 'free'), containsAllInOrder(
        ['countries', '--level', 'free'],
      ));
      expect(await cli.signupArgs(), contains('signup'));
      expect(await cli.loginArgs(secret: ' abc '), containsAllInOrder(
        ['login', '--secret', 'abc'],
      ));
    });
  });

  group('maskArgs', () {
    test('masks the secret and the upstream credentials', () {
      final masked = GephCliService.maskArgs([
        '--account-file',
        '/tmp/a.txt',
        '--upstream',
        'socks5://user:pass@10.0.0.5:1080',
        'login',
        '--secret',
        'bearer-token-value',
      ]);

      expect(masked, contains('socks5://user:****@10.0.0.5:1080'));
      expect(masked, contains('--secret ****'));
      expect(masked, isNot(contains('pass@')));
      expect(masked, isNot(contains('bearer-token-value')));
      expect(masked, contains('--account-file /tmp/a.txt'));
    });
  });

  group('parseCountries', () {
    const sample = '''
CC   country                exits level  cities
NL   Netherlands                3 free   Amsterdam(2), Rotterdam(1)
DE   Germany                    2 plus Berlin(2)
Connect with: geph5-proxy run --country <CC>   (or --country auto)
''';

    test('parses rows and skips the header/footer', () {
      final list = GephCliService.parseCountries(sample);
      expect(list, isNotNull);
      expect(list, hasLength(2));

      expect(list![0].code, 'NL');
      expect(list[0].name, 'Netherlands');
      expect(list[0].exits, 3);
      expect(list[0].free, isTrue);
      expect(list[0].cities, 'Amsterdam(2), Rotterdam(1)');
      expect(list[0].label, 'NL — Netherlands (free, 3)');

      expect(list[1].code, 'DE');
      expect(list[1].name, 'Germany');
      expect(list[1].free, isFalse);
      expect(list[1].label, 'DE — Germany (plus, 2)');
    });

    test('returns null when nothing parses', () {
      expect(GephCliService.parseCountries(''), isNull);
      expect(GephCliService.parseCountries('no exits here'), isNull);
    });

    test('json round-trip keeps the label intact', () {
      const c = GephCountryInfo(
        code: 'NL',
        name: 'Netherlands',
        exits: 3,
        free: true,
        cities: 'Amsterdam',
      );
      final back = GephCountryInfo.fromJson(c.toJson());
      expect(back.label, c.label);
    });
  });

  group('sanitizeLine', () {
    test('strips ANSI sequences', () {
      expect(
        GephCliService.sanitizeLine('\x1B[32mconnected\x1B[0m    : NL'),
        'connected    : NL',
      );
    });

    test('masks a lone long token (the account code)', () {
      expect(
        GephCliService.maskSecretLine(
          'gg_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        ),
        '****',
      );
      expect(
        GephCliService.maskSecretLine('SOCKS5 proxy : socks5h://127.0.0.1:9909'),
        'SOCKS5 proxy : socks5h://127.0.0.1:9909',
      );
      expect(GephCliService.maskSecretLine('short'), 'short');
    });

    test('keeps only the final solving ticker line', () {
      expect(GephCliService.sanitizeLine('solving...   0%'), '');
      expect(GephCliService.sanitizeLine('solving...  99%'), '');
      expect(GephCliService.sanitizeLine('solving... 100%'), 'solving... 100%');
      expect(GephCliService.sanitizeLine('registering account...'),
          'registering account...');
    });
  });

  test('the binary is started without the noisy debug default', () {
    expect(GephCliService.environment['RUST_LOG'], 'geph=info');
  });
}
