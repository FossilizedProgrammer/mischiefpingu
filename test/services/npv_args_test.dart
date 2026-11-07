// test/services/npv_args_test.dart
//
// آرگومان‌های `npv connect` / `npv serve` و قاعدهٔ «از نتیجهٔ چک قبلی
// استفاده کن». پرچم‌ها باید قبل از نام فایل بیایند (flag package بعد از
// آن‌ها نمی‌خواند) و `-s` معنا را از «سنجش همه» به «سنجش یکی» عوض می‌کند.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/services/npv/npv_args.dart';
import 'package:mischiefpingu/services/npv/npv_server_list.dart';

List<String> args(
        {String? pinnedIndex, int httpPort = 8086, bool lan = false}) =>
    npvConnectArgs(
      configPath: '/tmp/BOMB.npvs',
      bindHost: lan ? '0.0.0.0' : '127.0.0.1',
      socksPort: 1086,
      httpPort: httpPort,
      probeTimeoutSeconds: 10,
      probeJobs: 3,
      probeUrl: 'https://example.test/generate_204',
      pinnedIndex: pinnedIndex,
    );

final _now = DateTime(2026, 10, 29, 12);
const _file = '/tmp/BOMB.npvs';

NpvServerEntry _entry(int index, {bool ok = true}) => NpvServerEntry(
      index: index,
      remark: 'config-$index',
      proto: 'ss',
      kind: 'link',
      transport: 'tcp',
      ok: ok,
      medianMs: ok ? 100 : 0,
      error: ok ? '' : 'timeout',
    );

/// همان ترتیب باینری: زنده‌ها اول (سریع‌ترین به قبل)، بعد مرده‌ها.
NpvServerList _list(List<NpvServerEntry> servers, {bool checked = true}) =>
    NpvServerList(
      creatorMessage: '',
      checked: checked,
      total: servers.length,
      answered: servers.where((s) => s.ok).length,
      servers: servers,
    );

String? _cached({
  NpvServerList? list,
  bool checked = true,
  DateTime? checkedAt,
  String checkedConfigPath = _file,
  String? pinnedIndex,
}) =>
    npvCheckedServeIndex(
      list: list,
      checked: checked,
      checkedAt: checkedAt ?? _now.subtract(const Duration(minutes: 2)),
      checkedConfigPath: checkedConfigPath,
      configPath: _file,
      pinnedIndex: pinnedIndex,
      now: _now,
    );

void main() {
  group('npvConnectArgs', () {
    test('auto mode sends no -s at all', () {
      final a = args();
      expect(a.first, 'connect');
      expect(a, isNot(contains('-s')));
      expect(a.last, '/tmp/BOMB.npvs');
      expect(a, containsAllInOrder(['-socks', '127.0.0.1:1086']));
      expect(a, containsAllInOrder(['-http', '127.0.0.1:8086']));
      expect(a, containsAllInOrder(['-timeout', '10s']));
      expect(a, containsAllInOrder(['-jobs', '3']));
    });

    test('a pinned config adds -s before the file name', () {
      final a = args(pinnedIndex: '12');
      final s = a.indexOf('-s');
      expect(s, greaterThan(0));
      expect(a[s + 1], '12');
      expect(a.indexOf('/tmp/BOMB.npvs'), greaterThan(s));
    });

    test('blank or whitespace-only pin stays in auto mode', () {
      expect(args(pinnedIndex: ''), isNot(contains('-s')));
      expect(args(pinnedIndex: '   '), isNot(contains('-s')));
      expect(args(pinnedIndex: null), isNot(contains('-s')));
    });

    test('http port 0 still passes an explicit empty -http', () {
      final a = args(httpPort: 0);
      expect(a, containsAllInOrder(['-http', '']));
      expect(a, isNot(contains('127.0.0.1:0')));
    });

    test('sharing on LAN binds both listeners to 0.0.0.0', () {
      final a = args(lan: true);
      expect(a, containsAllInOrder(['-socks', '0.0.0.0:1086']));
      expect(a, containsAllInOrder(['-http', '0.0.0.0:8086']));
    });
  });

  group('npvServeArgs', () {
    test('serves one index and sends no probe flags', () {
      expect(
        npvServeArgs(
          configPath: '/tmp/BOMB.npvs',
          bindHost: '127.0.0.1',
          socksPort: 1086,
          httpPort: 8086,
          selectedIndex: '7',
        ),
        [
          'serve',
          '-s',
          '7',
          '-socks',
          '127.0.0.1:1086',
          '-http',
          '127.0.0.1:8086',
          '/tmp/BOMB.npvs',
        ],
      );
    });

    test('http port 0 still passes an explicit empty -http', () {
      final a = npvServeArgs(
        configPath: '/tmp/BOMB.npvs',
        bindHost: '0.0.0.0',
        socksPort: 1086,
        httpPort: 0,
        selectedIndex: '3',
      );
      expect(a, containsAllInOrder(['-http', '']));
      expect(a.last, '/tmp/BOMB.npvs');
    });
  });

  group('npvCheckedServeIndex', () {
    // سریع‌ترین زنده #4، بعد #9؛ #2 در همان چک مرده بوده است.
    final checkedList = _list([_entry(4), _entry(9), _entry(2, ok: false)]);

    test('a fresh check serves the fastest alive config', () {
      expect(_cached(list: checkedList), '4');
    });

    test('a fresh check serves a hand-picked alive config', () {
      expect(_cached(list: checkedList, pinnedIndex: '9'), '9');
    });

    test('a pick that was dead in the check must still be probed', () {
      expect(_cached(list: checkedList, pinnedIndex: '2'), isNull);
    });

    test('a pick missing from the checked file must still be probed', () {
      expect(_cached(list: checkedList, pinnedIndex: '77'), isNull);
    });

    test('a remark-style pin is not a number, so it is not trusted', () {
      expect(_cached(list: checkedList, pinnedIndex: 'config-9'), isNull);
    });

    test('nothing is served when no config answered', () {
      expect(
        _cached(list: _list([_entry(1, ok: false), _entry(2, ok: false)])),
        isNull,
      );
    });

    test('an old check is not reused', () {
      expect(
        _cached(
          list: checkedList,
          checkedAt: _now.subtract(kNpvCheckedTtl + const Duration(minutes: 1)),
        ),
        isNull,
      );
    });

    test('a check from a different config file is not reused', () {
      expect(_cached(list: checkedList, checkedConfigPath: '/tmp/other.npvs'),
          isNull);
    });

    test('a check that never recorded its file is not reused', () {
      expect(_cached(list: checkedList, checkedConfigPath: ''), isNull);
    });

    test('a list-only scan is not treated as a verdict', () {
      expect(_cached(list: checkedList, checked: false), isNull);
    });

    test('a report the binary did not mark as checked is not reused', () {
      expect(_cached(list: _list([_entry(4)], checked: false)), isNull);
    });

    test('no check at all yet means probing', () {
      expect(_cached(list: null), isNull);
    });
  });
}
