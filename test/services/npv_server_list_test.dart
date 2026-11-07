// test/services/npv_server_list_test.dart
//
// fixtureها واقعی‌اند: خروجی `npv list -json` و `npv list -check -json`
// از باینری bundled روی یک فایل .npvs واقعی (با total/answered خلاصه‌شده).

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/services/npv/npv_server_list.dart';

const checkedOutput = r'''
{"creatorMessage":"https://t.me/configraygan...","checked":true,"total":5,"answered":3,"servers":[{"index":30,"remark":"configraygan-2","proto":"ss","kind":"v2ray","transport":"tcp/none","ok":true,"medianMs":406},{"index":16,"remark":"configraygan-16","proto":"ss","kind":"v2ray","transport":"tcp/none","ok":true,"medianMs":414},{"index":9,"remark":"configraygan-23","proto":"vless","kind":"v2ray","transport":"tcp/reality","ok":true,"medianMs":562},{"index":1,"remark":"configraygan-31","proto":"ss","kind":"v2ray","transport":"tcp/none","ok":false,"error":"Get \"https://www.gstatic.com/generate_204\": context deadline exceeded (Client.Timeout exceeded while awaiting headers)"},{"index":2,"remark":"configraygan-30","proto":"vless","kind":"v2ray","transport":"tcp/tls","ok":false,"error":"Get \"https://www.gstatic.com/generate_204\": read tcp 127.0.0.1:54890->127.0.0.1:36293: read: connection reset by peer"}]}
''';

const plainOutput =
    r'''{"checked":false,"total":2,"answered":0,"servers":[{"index":1,"remark":"a","proto":"ss","kind":"v2ray","transport":"tcp/none","ok":false},{"index":2,"remark":"b","proto":"vless","kind":"v2ray","transport":"ws/tls","ok":false}]}''';

void main() {
  group('npv list -json', () {
    test('checked scan keeps order, ranks and failure reasons', () {
      final list = NpvServerList.tryParse(checkedOutput)!;

      expect(list.checked, isTrue);
      expect(list.total, 5);
      expect(list.answered, 3);
      expect(list.creatorMessage, 'https://t.me/configraygan...');
      expect(list.alive.length, 3);

      // زنده‌ها سریع‌ترین به قبل، همان ترتیب باینری.
      expect(list.alive.map((e) => e.medianMs), [406, 414, 562]);
      expect(list.rankOf(list.alive.first), 1);
      expect(list.rankOf(list.alive.last), 3);

      final dead = list.servers.last;
      expect(dead.ok, isFalse);
      expect(list.rankOf(dead), 0);
      expect(dead.error, contains('connection reset by peer'));
    });

    test('plain list has no verdict for any config', () {
      final list = NpvServerList.tryParse(plainOutput)!;

      expect(list.checked, isFalse);
      expect(list.hasServers, isTrue);
      expect(list.alive, isEmpty);
      expect(list.servers.every((e) => !e.ok && e.error.isEmpty), isTrue);
    });

    test('unrecognised output returns null instead of throwing', () {
      // نسخهٔ قدیمی باینری، خروجی خراب، یا لاگ ناخواسته روی stdout.
      expect(NpvServerList.tryParse('npv-go: flag provided but not defined'),
          isNull);
      expect(NpvServerList.tryParse(''), isNull);
      expect(NpvServerList.tryParse('[1,2,3]'), isNull);
    });
  });
}
