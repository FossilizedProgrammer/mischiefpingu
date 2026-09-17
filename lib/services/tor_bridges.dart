library;

class TorBridges {
  static const String meekCdn77 =
      'meek_lite 192.0.2.20:80 url=https://1603026938.rsc.cdn77.org front=www.phpmyadmin.net utls=HelloRandomizedALPN';

  static const String snowflakeCdn77 =
      'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
      'url=https://1098762253.rsc.cdn77.org/ '
      'front=www.cdn77.com '
      'ice=stun:stun.antisip.com:3478,stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.nextcloud.com:3478,stun:stun.bethesda.net:3478,stun:stun.nextcloud.com:443,stun:stun.sipgate.net:3478,stun:stun.sipgate.net:10000,stun:stun.sonetel.com:3478,stun:stun.voipia.net:3478 '
      'utls-imitate=hellorandomizedalpn';

  static const List<String> obfs4Iat = [
    'obfs4 212.83.43.95:443 BFE712113A72899AD685764B211FACD30FF52C31 cert=ayq0XzCwhpdysn5o0EyDUbmSOx3X/oTEbzDMvczHOdBJKlvIdHHLJGkZARtT4dcBFArPPg iat-mode=1',
    'obfs4 212.83.43.74:443 39562501228A4D5E27FCA4C0C81A01EE23AE3EE4 cert=PBwr+S8JTVZo6MPdHnkTwXJPILWADLqfMGoVvhZClMq/Urndyd42BwX9YFJHZnBB3H0XCw iat-mode=1',
  ];

  static const List<String> obfs4Public = [
    'obfs4 51.222.13.177:80 5EDAC3B810E12B01F6FD8050D2FD3E277B289A08 cert=2uplIpLQ0q9+0qMFrK5pkaYRDOe460LL9WHBvatgkuRr/SL31wBOEupaMMJ6koRE6Ld0ew iat-mode=0',
    'obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D cert=bjRaMrr1BRiAW8IE9U5z27fQaYgOhX1UCmOpg2pFpoMvo6ZgQMzLsaTzzQNTlm7hNcb+Sg iat-mode=0',
    'obfs4 45.145.95.6:27015 C5B7CD6946FF10C5B3E89691A7D3F2C122D2117C cert=TD7PbUO0/0k6xYHMPW3vJxICfkMZNdkRrb63Zhl5j9dW3iRGiCx0A7mPhe5T2EDzQ35+Zw iat-mode=0',
    'obfs4 209.148.46.65:443 74FAD13168806246602538555B5521A0383A1875 cert=ssH+9rP8dG2NLDN2XuFw63hIO/9MNNinLmxQDpVa+7kTOa9/m+tGWT1SmSYpQ9uTBGa6Hw iat-mode=0',
  ];

  /// Parses a multi-line bridge text into `Bridge <line>` payloads.
  /// Lines starting with `#` and empty lines are ignored; a leading
  /// `Bridge ` prefix is stripped (torrc adds it back).
  static List<String> parseBridges(String? raw) {
    final result = <String>[];
    if (raw == null || raw.trim().isEmpty) return result;
    for (final line in raw.replaceAll('\r\n', '\n').split('\n')) {
      var t = line.trim();
      if (t.isEmpty || t.startsWith('#')) continue;
      if (t.toLowerCase().startsWith('bridge ')) {
        t = t.substring('bridge '.length).trim();
      }
      if (t.isNotEmpty) result.add(t);
    }
    return result;
  }

  static String normalizeExitCountry(String? raw) {
    var v = (raw ?? '').trim().replaceAll(RegExp(r'^[{}]+|[{}]+$'), '');
    v = v.toLowerCase();
    if (v == 'auto' || v == 'any') return '';
    return v;
  }
}
