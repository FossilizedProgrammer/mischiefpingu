library;

import 'wireguard_config_parser.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardUriCodec — تبدیل بین کانفیگ استاندارد و URI.
/// ═══════════════════════════════════════════════════════════════
class WireGuardUriCodec {
  WireGuardUriCodec._();

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

      return WireGuardConfig(
        privateKey: privateKey,
        address: Uri.decodeComponent(q['address'] ?? '10.0.0.2/32'),
        dns: Uri.decodeComponent(q['dns'] ?? '1.1.1.1'),
        mtu: Uri.decodeComponent(q['mtu'] ?? '1280'),
        publicKey: publicKey,
        endpoint: '$host:$port',
        allowedIps: Uri.decodeComponent(q['allowedips'] ?? '0.0.0.0/0, ::/0'),
        persistentKeepalive:
            Uri.decodeComponent(q['persistentkeepalive'] ?? '25'),
        preSharedKey: Uri.decodeComponent(q['presharedkey'] ?? ''),
        reserved: Uri.decodeComponent(q['reserved'] ?? ''),
        jc: Uri.decodeComponent(q['jc'] ?? ''),
        jmin: Uri.decodeComponent(q['jmin'] ?? ''),
        jmax: Uri.decodeComponent(q['jmax'] ?? ''),
        s1: Uri.decodeComponent(q['s1'] ?? ''),
        s2: Uri.decodeComponent(q['s2'] ?? ''),
        s3: Uri.decodeComponent(q['s3'] ?? ''),
        s4: Uri.decodeComponent(q['s4'] ?? ''),
        h1: Uri.decodeComponent(q['h1'] ?? ''),
        h2: Uri.decodeComponent(q['h2'] ?? ''),
        h3: Uri.decodeComponent(q['h3'] ?? ''),
        h4: Uri.decodeComponent(q['h4'] ?? ''),
        i1: Uri.decodeComponent(q['i1'] ?? ''),
        i2: Uri.decodeComponent(q['i2'] ?? ''),
        i3: Uri.decodeComponent(q['i3'] ?? ''),
        i4: Uri.decodeComponent(q['i4'] ?? ''),
        i5: Uri.decodeComponent(q['i5'] ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

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
    if (cfg.preSharedKey.isNotEmpty) qp['presharedkey'] = cfg.preSharedKey;
    if (cfg.reserved.isNotEmpty) qp['reserved'] = cfg.reserved;

    if (cfg.jc.isNotEmpty) qp['jc'] = cfg.jc;
    if (cfg.jmin.isNotEmpty) qp['jmin'] = cfg.jmin;
    if (cfg.jmax.isNotEmpty) qp['jmax'] = cfg.jmax;
    if (cfg.s1.isNotEmpty) qp['s1'] = cfg.s1;
    if (cfg.s2.isNotEmpty) qp['s2'] = cfg.s2;
    if (cfg.s3.isNotEmpty) qp['s3'] = cfg.s3;
    if (cfg.s4.isNotEmpty) qp['s4'] = cfg.s4;
    if (cfg.h1.isNotEmpty) qp['h1'] = cfg.h1;
    if (cfg.h2.isNotEmpty) qp['h2'] = cfg.h2;
    if (cfg.h3.isNotEmpty) qp['h3'] = cfg.h3;
    if (cfg.h4.isNotEmpty) qp['h4'] = cfg.h4;
    if (cfg.i1.isNotEmpty) qp['i1'] = cfg.i1;
    if (cfg.i2.isNotEmpty) qp['i2'] = cfg.i2;
    if (cfg.i3.isNotEmpty) qp['i3'] = cfg.i3;
    if (cfg.i4.isNotEmpty) qp['i4'] = cfg.i4;
    if (cfg.i5.isNotEmpty) qp['i5'] = cfg.i5;

    final query = qp.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'wireguard://${Uri.encodeComponent(cfg.privateKey)}'
        '@$host:$port/?$query';
  }
}
