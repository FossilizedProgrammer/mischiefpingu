// lib/services/wireguard/wireguard_config_parser.dart

library;

import 'wireguard_uri_codec.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardConfig — مدل کانفیگ WireGuard + پشتیبانی از AmneziaWG.
/// ═══════════════════════════════════════════════════════════════
class WireGuardConfig {
  final String privateKey;
  final String address;
  final String dns;
  final String mtu;
  final String publicKey;
  final String endpoint;
  final String allowedIps;
  final String persistentKeepalive;
  final String preSharedKey;
  final String reserved;

  // AmneziaWG parameters
  final String jc;
  final String jmin;
  final String jmax;
  final String s1;
  final String s2;
  final String s3;
  final String s4;
  final String h1;
  final String h2;
  final String h3;
  final String h4;
  final String i1;
  final String i2;
  final String i3;
  final String i4;
  final String i5;

  const WireGuardConfig({
    required this.privateKey,
    required this.address,
    required this.dns,
    required this.mtu,
    required this.publicKey,
    required this.endpoint,
    required this.allowedIps,
    required this.persistentKeepalive,
    this.preSharedKey = '',
    this.reserved = '',
    this.jc = '',
    this.jmin = '',
    this.jmax = '',
    this.s1 = '',
    this.s2 = '',
    this.s3 = '',
    this.s4 = '',
    this.h1 = '',
    this.h2 = '',
    this.h3 = '',
    this.h4 = '',
    this.i1 = '',
    this.i2 = '',
    this.i3 = '',
    this.i4 = '',
    this.i5 = '',
  });

  bool get isValid =>
      privateKey.isNotEmpty && publicKey.isNotEmpty && endpoint.isNotEmpty;

  bool get hasAmneziaParams =>
      jc.isNotEmpty ||
      jmin.isNotEmpty ||
      jmax.isNotEmpty ||
      s1.isNotEmpty ||
      s2.isNotEmpty ||
      s3.isNotEmpty ||
      s4.isNotEmpty ||
      h1.isNotEmpty ||
      h2.isNotEmpty ||
      h3.isNotEmpty ||
      h4.isNotEmpty ||
      i1.isNotEmpty ||
      i2.isNotEmpty ||
      i3.isNotEmpty ||
      i4.isNotEmpty ||
      i5.isNotEmpty;

  String get key => '$publicKey|$endpoint';

  WireGuardConfig copyWith({
    String? privateKey,
    String? address,
    String? dns,
    String? mtu,
    String? publicKey,
    String? endpoint,
    String? allowedIps,
    String? persistentKeepalive,
    String? preSharedKey,
    String? reserved,
    String? jc,
    String? jmin,
    String? jmax,
    String? s1,
    String? s2,
    String? s3,
    String? s4,
    String? h1,
    String? h2,
    String? h3,
    String? h4,
    String? i1,
    String? i2,
    String? i3,
    String? i4,
    String? i5,
  }) {
    return WireGuardConfig(
      privateKey: privateKey ?? this.privateKey,
      address: address ?? this.address,
      dns: dns ?? this.dns,
      mtu: mtu ?? this.mtu,
      publicKey: publicKey ?? this.publicKey,
      endpoint: endpoint ?? this.endpoint,
      allowedIps: allowedIps ?? this.allowedIps,
      persistentKeepalive: persistentKeepalive ?? this.persistentKeepalive,
      preSharedKey: preSharedKey ?? this.preSharedKey,
      reserved: reserved ?? this.reserved,
      jc: jc ?? this.jc,
      jmin: jmin ?? this.jmin,
      jmax: jmax ?? this.jmax,
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      s3: s3 ?? this.s3,
      s4: s4 ?? this.s4,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      i1: i1 ?? this.i1,
      i2: i2 ?? this.i2,
      i3: i3 ?? this.i3,
      i4: i4 ?? this.i4,
      i5: i5 ?? this.i5,
    );
  }
}

class WireGuardConfigParser {
  WireGuardConfigParser._();

  /// پارس کانفیگ — فقط استاندارد و URI.
  static WireGuardConfig? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.toLowerCase().startsWith('wireguard://')) {
      return WireGuardUriCodec.decode(trimmed);
    }
    return parseStandard(trimmed);
  }

  static WireGuardConfig? parseStandard(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');

    String section = '';
    final values = <String, String>{};

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        section = line.substring(1, line.length - 1).toLowerCase();
        continue;
      }

      final eq = line.indexOf('=');
      if (eq <= 0) continue;

      final key = line.substring(0, eq).trim().toLowerCase();
      final value = line.substring(eq + 1).trim();
      if (value.isEmpty) continue;

      values['$section.$key'] = value;
    }

    final privateKey = values['interface.privatekey'] ?? '';
    final publicKey = values['peer.publickey'] ?? '';
    final endpoint = values['peer.endpoint'] ?? '';

    if (privateKey.isEmpty || publicKey.isEmpty || endpoint.isEmpty) {
      return null;
    }

    return WireGuardConfig(
      privateKey: privateKey,
      address: values['interface.address'] ?? '10.0.0.2/32',
      dns: values['interface.dns'] ?? '1.1.1.1',
      mtu: values['interface.mtu'] ?? '1280',
      publicKey: publicKey,
      endpoint: endpoint,
      allowedIps: values['peer.allowedips'] ?? '0.0.0.0/0, ::/0',
      persistentKeepalive: values['peer.persistentkeepalive'] ?? '25',
      preSharedKey: values['peer.presharedkey'] ?? '',
      reserved: values['peer.reserved'] ?? '',
      jc: values['interface.jc'] ?? '',
      jmin: values['interface.jmin'] ?? '',
      jmax: values['interface.jmax'] ?? '',
      s1: values['interface.s1'] ?? '',
      s2: values['interface.s2'] ?? '',
      s3: values['interface.s3'] ?? '',
      s4: values['interface.s4'] ?? '',
      h1: values['interface.h1'] ?? '',
      h2: values['interface.h2'] ?? '',
      h3: values['interface.h3'] ?? '',
      h4: values['interface.h4'] ?? '',
      i1: values['interface.i1'] ?? '',
      i2: values['interface.i2'] ?? '',
      i3: values['interface.i3'] ?? '',
      i4: values['interface.i4'] ?? '',
      i5: values['interface.i5'] ?? '',
    );
  }

  static String serialize(WireGuardConfig cfg, {bool includeAmnezia = true}) {
    final sb = StringBuffer();
    sb.writeln('[Interface]');
    sb.writeln('PrivateKey = ${cfg.privateKey}');
    sb.writeln('Address = ${cfg.address}');
    if (cfg.dns.isNotEmpty) sb.writeln('DNS = ${cfg.dns}');
    if (cfg.mtu.isNotEmpty) sb.writeln('MTU = ${cfg.mtu}');

    if (includeAmnezia) {
      if (cfg.jc.isNotEmpty) sb.writeln('Jc = ${cfg.jc}');
      if (cfg.jmin.isNotEmpty) sb.writeln('Jmin = ${cfg.jmin}');
      if (cfg.jmax.isNotEmpty) sb.writeln('Jmax = ${cfg.jmax}');
      if (cfg.s1.isNotEmpty) sb.writeln('S1 = ${cfg.s1}');
      if (cfg.s2.isNotEmpty) sb.writeln('S2 = ${cfg.s2}');
      if (cfg.s3.isNotEmpty) sb.writeln('S3 = ${cfg.s3}');
      if (cfg.s4.isNotEmpty) sb.writeln('S4 = ${cfg.s4}');
      if (cfg.h1.isNotEmpty) sb.writeln('H1 = ${cfg.h1}');
      if (cfg.h2.isNotEmpty) sb.writeln('H2 = ${cfg.h2}');
      if (cfg.h3.isNotEmpty) sb.writeln('H3 = ${cfg.h3}');
      if (cfg.h4.isNotEmpty) sb.writeln('H4 = ${cfg.h4}');
      if (cfg.i1.isNotEmpty) sb.writeln('I1 = ${cfg.i1}');
      if (cfg.i2.isNotEmpty) sb.writeln('I2 = ${cfg.i2}');
      if (cfg.i3.isNotEmpty) sb.writeln('I3 = ${cfg.i3}');
      if (cfg.i4.isNotEmpty) sb.writeln('I4 = ${cfg.i4}');
      if (cfg.i5.isNotEmpty) sb.writeln('I5 = ${cfg.i5}');
    }

    sb.writeln();
    sb.writeln('[Peer]');
    sb.writeln('PublicKey = ${cfg.publicKey}');
    if (cfg.preSharedKey.isNotEmpty) {
      sb.writeln('PreSharedKey = ${cfg.preSharedKey}');
    }
    sb.writeln('Endpoint = ${cfg.endpoint}');
    sb.writeln('AllowedIPs = ${cfg.allowedIps}');
    if (cfg.persistentKeepalive.isNotEmpty) {
      sb.writeln('PersistentKeepalive = ${cfg.persistentKeepalive}');
    }
    if (cfg.reserved.isNotEmpty) {
      sb.writeln('Reserved = ${cfg.reserved}');
    }
    return sb.toString();
  }
}
