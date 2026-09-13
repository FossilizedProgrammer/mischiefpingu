// lib/services/sstp/tls_client_hello_builder.dart
//
// ═══════════════════════════════════════════════════════════════
//  ساخت TLS ClientHello ساده برای probe SSTP
// ═══════════════════════════════════════════════════════════════
library;

class TlsClientHelloBuilder {
  TlsClientHelloBuilder._();

  /// ساخت یک TLS 1.2 ClientHello حداقلی برای probe.
  static List<int> build() {
    // TLS Record Header
    final record = <int>[
      0x16, // Content Type: Handshake
      0x03, 0x01, // Version: TLS 1.0
      0x00, 0x00, // Length (placeholder)
    ];

    // Handshake Header
    final handshake = <int>[
      0x01, // Handshake Type: ClientHello
      0x00, 0x00, 0x00, // Length (placeholder)
    ];

    // ClientHello Body
    final body = <int>[
      0x03, 0x03, // Version: TLS 1.2
      // Random (32 bytes)
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, // Session ID Length: 0
      0x00, 0x02, // Cipher Suites Length: 2
      0x00, 0xff, // Cipher Suite: SCSV
      0x01, // Compression Methods Length: 1
      0x00, // Compression Method: null
      0x00, 0x08, // Extensions Length: 8
      0x00, 0x00, // Extension Type: server_name
      0x00, 0x04, // Extension Length
      0x00, 0x02, // Server Name List Length
      0x00, // Host Name Type
      0x00, // Host Name Length (placeholder)
    ];

    final bodyLength = body.length;
    handshake[1] = (bodyLength >> 16) & 0xff;
    handshake[2] = (bodyLength >> 8) & 0xff;
    handshake[3] = bodyLength & 0xff;

    final handshakeTotal = handshake.length + body.length;
    record[3] = (handshakeTotal >> 8) & 0xff;
    record[4] = handshakeTotal & 0xff;

    return [...record, ...handshake, ...body];
  }

  /// آیا داده دریافتی، پاسخ TLS است؟
  static bool isTlsResponse(List<int> data) {
    if (data.isEmpty) return false;
    return data[0] == 0x16 || data[0] == 0x15 || data[0] == 0x17;
  }
}
