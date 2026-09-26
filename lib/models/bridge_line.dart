library;

class BridgeLine {
  final String raw;
  final String transport;
  final String? address;
  final String? fingerprint;
  final Map<String, String> params;

  BridgeLine({
    required this.raw,
    required this.transport,
    this.address,
    this.fingerprint,
    required this.params,
  });

  static BridgeLine? parse(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) return null;

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2) return null;

    final transport = parts[0].toLowerCase();
    String? address;
    String? fingerprint;
    final params = <String, String>{};

    int startIndex = 1;
    if (parts[1].contains(':') || parts[1].contains('.')) {
      address = parts[1];
      startIndex = 2;
      if (parts.length > 2 && parts[2].length == 40) {
        fingerprint = parts[2];
        startIndex = 3;
      }
    } else if (parts[1].length == 40) {
      fingerprint = parts[1];
      startIndex = 2;
    }

    for (int i = startIndex; i < parts.length; i++) {
      final kv = parts[i].split('=');
      if (kv.length == 2) {
        params[kv[0]] = kv[1];
      }
    }

    return BridgeLine(
      raw: trimmed,
      transport: transport,
      address: address,
      fingerprint: fingerprint,
      params: params,
    );
  }

  String? get targetHost {
    if (address != null && address!.contains(':')) {
      return address!.split(':')[0];
    }
    return params['front'] ??
        (params['url'] != null ? Uri.parse(params['url']!).host : null);
  }

  int get targetPort {
    if (address != null && address!.contains(':')) {
      return int.tryParse(address!.split(':')[1]) ?? 443;
    }
    return 443;
  }
}
