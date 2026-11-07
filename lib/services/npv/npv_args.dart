library;

// ═══════════════════════════════════════════════════════════════
//  آرگومان‌های `npv connect` و `npv serve`.
//
//  جدا از ProcessService نوشته شده تا انتخاب دستی کانفیگ (`-s`) و رد
//  شدن از سنجش تکراری، بدون بالا بردن واقعی پروسه قابل تست باشد.
//  پرچم‌ها باید قبل از نام فایل بیایند (flag package همین‌طور می‌خواندشان).
// ═══════════════════════════════════════════════════════════════

import 'npv_server_list.dart';

/// تا چند دقیقهٔ بعد از «بررسی سرورها»، اتصال بدون سنجش مجدد سرو می‌کند.
const Duration kNpvCheckedTtl = Duration(minutes: 15);

List<String> npvConnectArgs({
  required String configPath,
  required String bindHost,
  required int socksPort,
  required int httpPort, // 0 = غیرفعال، npv با `-http ""` می‌فهمد
  required int probeTimeoutSeconds,
  required int probeJobs,
  String? probeUrl,
  String? pinnedIndex, // خالی/null = حالت خودکار: سریع‌ترین زنده
}) {
  final args = <String>[
    'connect',
    '-timeout',
    '${probeTimeoutSeconds}s',
    '-jobs',
    '$probeJobs',
    '-socks',
    '$bindHost:$socksPort',
  ];
  args.addAll(['-http', httpPort > 0 ? '$bindHost:$httpPort' : '']);
  if (probeUrl != null && probeUrl.isNotEmpty) {
    args.addAll(['-url', probeUrl]);
  }
  final pin = pinnedIndex?.trim() ?? '';
  if (pin.isNotEmpty) {
    // npv با -s فقط همین یک کانفیگ را می‌سنجد و اگر جواب داد همان را
    // سرویس می‌کند؛ پس انتخاب دستی هم مثل حالت خودکار اعتبارسنجی می‌شود.
    args.addAll(['-s', pin]);
  }
  args.add(configPath);
  return args;
}

/// آرگومان‌های `npv serve -s N`: همان کانفیگ را بدون هیچ سنجشی سرو می‌کند.
List<String> npvServeArgs({
  required String configPath,
  required String bindHost,
  required int socksPort,
  required int httpPort,
  required String selectedIndex,
}) {
  final args = <String>[
    'serve',
    '-s',
    selectedIndex,
    '-socks',
    '$bindHost:$socksPort',
    '-http',
    httpPort > 0 ? '$bindHost:$httpPort' : '',
  ];
  args.add(configPath);
  return args;
}

/// اگر آخرین «بررسی سرورها» هنوز معتبر است، شمارهٔ کانفیگی که بدون سنجش
/// مجدد سرو می‌شود را می‌دهد؛ null یعنی باید `connect` probe کند.
///
/// سه چیز باید جور باشند: نتیجه واقعاً چک شده باشد (نه فقط فهرست)، از همان
/// فایلِ حالا و تازه باشد. در حالت خودکار سریع‌ترین زنده انتخاب می‌شود؛ یک
/// انتخاب دستی که در نتیجهٔ چک مرده باشد یا اصلاً در آن نباشد، اجازهٔ
/// رد کردن probe را ندارد.
String? npvCheckedServeIndex({
  required NpvServerList? list,
  required bool checked,
  required DateTime? checkedAt,
  required String checkedConfigPath,
  required String configPath,
  String? pinnedIndex,
  Duration ttl = kNpvCheckedTtl,
  DateTime? now,
}) {
  if (list == null || !list.checked || !checked) return null;
  if (checkedConfigPath.isEmpty || checkedConfigPath != configPath) return null;
  final at = checkedAt;
  if (at == null || (now ?? DateTime.now()).difference(at) > ttl) return null;

  final pin = pinnedIndex?.trim() ?? '';
  if (pin.isNotEmpty) {
    final index = int.tryParse(pin);
    if (index == null) return null;
    for (final entry in list.servers) {
      if (entry.index == index) return entry.ok ? '$index' : null;
    }
    return null;
  }

  final alive = list.alive;
  return alive.isEmpty ? null : '${alive.first.index}';
}
