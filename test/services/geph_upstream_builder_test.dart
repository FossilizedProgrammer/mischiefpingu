// test/services/geph_upstream_builder_test.dart
//
// تست تبدیل تنظیمات آپ‌استریم گف به URL فلگ `--upstream`.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/services/geph/geph_upstream_builder.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  late AppSettings settings;
  late ProcessService ps;
  late GephUpstreamBuilder builder;

  setUp(() {
    settings = AppSettings();
    ps = ProcessService();
    builder = GephUpstreamBuilder(settings: settings, processService: ps);
  });

  test('direct builds no upstream', () {
    expect(builder.hasUpstream, isFalse);
    expect(builder.buildUrl(), isEmpty);
    expect(builder.isAvailable, isTrue);

    final args = <String>[];
    builder.apply(args);
    expect(args, isEmpty);
  });

  test('internal tunnels map to their local SOCKS port', () {
    settings.gephUpstreamType = GephUpstreamBuilder.psiphon;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.socksPort}');
    expect(builder.socksPort, settings.socksPort);

    settings.gephUpstreamType = GephUpstreamBuilder.tor;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.torSocksPort}');

    settings.gephUpstreamType = GephUpstreamBuilder.sstp;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.sstpSocksPort}');

    settings.gephUpstreamType = GephUpstreamBuilder.wireguard;
    expect(
      builder.buildUrl(),
      'socks5://127.0.0.1:${settings.wireguardSocksPort}',
    );

    settings.gephUpstreamType = GephUpstreamBuilder.ffvpn;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.ffvpnSocksPort}');
    expect(builder.label, 'Firefox VPN');

    settings.gephUpstreamType = GephUpstreamBuilder.lantern;
    expect(builder.buildUrl(), 'socks5://127.0.0.1:${settings.lanternSocksPort}');
    expect(builder.label, 'Lantern');
  });

  test('manual upstream needs host and port', () {
    settings.gephUpstreamType = GephUpstreamBuilder.manual;
    expect(builder.buildUrl(), isEmpty);
    expect(builder.isAvailable, isFalse);

    settings
      ..gephProxyIp = '10.0.0.5'
      ..gephProxyPort = 1080;
    expect(builder.buildUrl(), 'socks5://10.0.0.5:1080');
    expect(builder.isAvailable, isTrue);
  });

  test('manual upstream carries credentials into the URL', () {
    settings
      ..gephUpstreamType = GephUpstreamBuilder.manual
      ..gephProxyType = 'http'
      ..gephProxyIp = '10.0.0.5'
      ..gephProxyPort = 3128
      ..gephProxyUser = 'user'
      ..gephProxyPass = 'pass';

    expect(builder.buildUrl(), 'http://user:pass@10.0.0.5:3128');
    expect(builder.describeUrl(), 'http://user:****@10.0.0.5:3128');
  });

  test('apply appends --upstream with masked credentials in the log', () {
    settings
      ..gephUpstreamType = GephUpstreamBuilder.manual
      ..gephProxyIp = '10.0.0.5'
      ..gephProxyPort = 1080
      ..gephProxyUser = 'user'
      ..gephProxyPass = 'pass';

    final args = <String>['run'];
    builder.apply(args);
    expect(
      args,
      containsAllInOrder(['--upstream', 'socks5://user:pass@10.0.0.5:1080']),
    );
  });

  test('maskCredentials hides the password only', () {
    expect(
      GephUpstreamBuilder.maskCredentials('socks5://user:pass@h:1'),
      'socks5://user:****@h:1',
    );
    expect(
      GephUpstreamBuilder.maskCredentials('socks5://h:1'),
      'socks5://h:1',
    );
  });
}
