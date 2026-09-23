library;

import 'wireguard_config_parser.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardUriCodec — تبدیل بین کانفیگ استاندارد و URI.
///
///  URI format:
///    `wireguard://<privateKey>@<host>:<port>/?publickey=...&address=...&allowedips=...&dns=...#<name>`
///
///  مثال:
///    ```
///    wireguard://iOXJFL6YVfjU5SAw%2BEeh83ZgB5R1bi%2FviYzMdV9Gzn8%3D@gc-wgupt-ai.ramzshadi.ir:51861/?publickey=2K6ji30yzmdnrlvcuDajHy8zPY%2BI7aiovLLvK8HJW1M%3D&address=10.0.14.47%2F32&allowedips=0.0.0.0%2F0%2C%3A%3A%2F0&dns=1.1.1.1%2C8.8.8.8#WGTorkish
///    ```
/// ═══════════════════════════════════════════════════════════════
class WireGuardUriCodec {
  WireGuardUriCodec._();

  /// دیکد URI به model.
  static WireGuardConfig? decode(String uri) {
    try {
      final u = Uri.parse(uri);
      if (u.scheme.toLowerCase() != 'wireguard') return null;

      final privateKey = Uri.decodeComponent(u.userInfo);
      final host = u.host;
      final port = u.port;
      if (privateKey.isEmpty || host.isEmpty || port <= 0) return null;

      final q = u.queryParameters;
      final publicKey = Uri.decodeComponent(q['publickey'] ?? '');
      if (publicKey.isEmpty) return null;

      final address = Uri.decodeComponent(q['address'] ?? '10.0.0.2/32');
      final allowedIps = Uri.decodeComponent(
        q['allowedips'] ?? '0.0.0.0/0, ::/0',
      );
      final dns = Uri.decodeComponent(q['dns'] ?? '1.1.1.1');
      final mtu = Uri.decodeComponent(q['mtu'] ?? '1280');
      final keepalive = Uri.decodeComponent(
        q['persistentkeepalive'] ?? '25',
      );
      final preshared = Uri.decodeComponent(q['presharedkey'] ?? '');
      final reserved = Uri.decodeComponent(q['reserved'] ?? '');

      return WireGuardConfig(
        privateKey: privateKey,
        address: address,
        dns: dns,
        mtu: mtu,
        publicKey: publicKey,
        endpoint: '$host:$port',
        allowedIps: allowedIps,
        persistentKeepalive: keepalive,
        preSharedKey: preshared,
        reserved: reserved,
      );
    } catch (_) {
      return null;
    }
  }

  /// انکد model به URI.
  static String encode(WireGuardConfig cfg) {
    final colon = cfg.endpoint.lastIndexOf(':');
    final host = colon > 0 ? cfg.endpoint.substring(0, colon) : cfg.endpoint;
    final port = colon > 0
        ? int.tryParse(cfg.endpoint.substring(colon + 1)) ?? 51820
        : 51820;

    final qp = <String, String>{
      'publickey': cfg.publicKey,
      'address': cfg.address,
      'allowedips': cfg.allowedIps,
      'dns': cfg.dns,
    };
    if (cfg.mtu.isNotEmpty && cfg.mtu != '1280') qp['mtu'] = cfg.mtu;
    if (cfg.persistentKeepalive.isNotEmpty) {
      qp['persistentkeepalive'] = cfg.persistentKeepalive;
    }
    if (cfg.preSharedKey.isNotEmpty) {
      qp['presharedkey'] = cfg.preSharedKey;
    }
    if (cfg.reserved.isNotEmpty) qp['reserved'] = cfg.reserved;

    final query = qp.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'wireguard://${Uri.encodeComponent(cfg.privateKey)}'
        '@$host:$port/?$query';
  }
}
