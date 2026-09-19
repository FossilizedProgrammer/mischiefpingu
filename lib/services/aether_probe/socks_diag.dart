library;

enum SocksDiag {
  healthy,
  appListenerBaselineFailed,
  connectRefused,
  connectTimeout,
  notSocks,
  tunnelDead,
}

class SocksDiagText {
  SocksDiagText._();

  static String forDiag(SocksDiag d, int port) {
    switch (d) {
      case SocksDiag.healthy:
        return '✓ DIAG: TCP + SOCKS5 + data-plane all OK';
      case SocksDiag.appListenerBaselineFailed:
        return '✗ DIAG: even our own loopback listener test failed';
      case SocksDiag.connectRefused:
        return '✗ DIAG: TCP connect to 127.0.0.1:$port REFUSED';
      case SocksDiag.connectTimeout:
        return '✗ DIAG: TCP connect to 127.0.0.1:$port TIMED OUT';
      case SocksDiag.notSocks:
        return '✗ DIAG: port accepts TCP but does NOT answer SOCKS5';
      case SocksDiag.tunnelDead:
        return '✗ DIAG: SOCKS5 greeting OK but data-plane DEAD';
    }
  }
}
