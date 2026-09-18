library;

class TlsClientHelloBuilder {
  TlsClientHelloBuilder._();

  /// ساخت یک TLS 1.2 ClientHello حداقلی برای probe.
  static List<int> build() {
    final record = <int>[0x16, 0x03, 0x01, 0x00, 0x00];

    final handshake = <int>[0x01, 0x00, 0x00, 0x00];

    final body = <int>[
      0x03,
      0x03,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x02,
      0x00,
      0xff,
      0x01,
      0x00,
      0x00,
      0x08,
      0x00,
      0x00,
      0x00,
      0x04,
      0x00,
      0x02,
      0x00,
      0x00,
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
