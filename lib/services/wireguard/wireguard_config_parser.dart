library;

import 'wireguard_uri_codec.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardConfigParser — پارس کانفیگ استاندارد WireGuard (.conf).
///
///  فرمت پشتیبانی‌شده:
///    [Interface]
///    PrivateKey = ...
///    Address = 10.0.0.2/32
///    DNS = 1.1.1.1, 8.8.8.8
///    MTU = 1280
///
///    [Peer]
///    PublicKey = ...
///    Endpoint = host:port
///    AllowedIPs = 0.0.0.0/0, ::/0
///    PersistentKeepalive = 25
///
///  این parser هم فرمت استاندارد و هم URI wireguard:// رو می‌شناسه.
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
  });

  bool get isValid =>
      privateKey.isNotEmpty && publicKey.isNotEmpty && endpoint.isNotEmpty;

  /// کلید یکتا برای dedupe.
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
    );
  }
}

class WireGuardConfigParser {
  WireGuardConfigParser._();

  /// ورودی می‌تونه کانفیگ استاندارد یا URI wireguard:// باشه.
  /// خروجی null یعنی پارس ناموفق بود.
  static WireGuardConfig? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.toLowerCase().startsWith('wireguard://')) {
      return WireGuardUriCodec.decode(trimmed);
    }
    return parseStandard(trimmed);
  }

  /// پارس کانفیگ استاندارد INI-مانند.
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
    );
  }

  /// ساخت متن کانفیگ استاندارد از روی model.
  static String serialize(WireGuardConfig cfg) {
    final sb = StringBuffer();
    sb.writeln('[Interface]');
    sb.writeln('PrivateKey = ${cfg.privateKey}');
    sb.writeln('Address = ${cfg.address}');
    if (cfg.dns.isNotEmpty) sb.writeln('DNS = ${cfg.dns}');
    if (cfg.mtu.isNotEmpty) sb.writeln('MTU = ${cfg.mtu}');
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
