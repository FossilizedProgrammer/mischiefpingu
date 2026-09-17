library;

import '../../models/settings_model.dart';

class PsiphonBaseConfigBuilder {
  final AppSettings settings;

  const PsiphonBaseConfigBuilder({required this.settings});

  /// ساخت config پایه بر اساس نوع upstream.
  Map<String, dynamic> build({required bool isConduit}) {
    final config = <String, dynamic>{
      "PropagationChannelId": "92AACC5BABE0944C",
      "SponsorId": "1BC527D3D09985CF",
      "LocalSocksProxyPort": settings.socksPort,
      "LocalHttpProxyPort": settings.httpPort,
      "DisableTactics": !isConduit,
      "AggressiveEstablishment": !isConduit,
      "UseIndistinguishableTLS": true,
      "TunnelWholeDevice": false,
      "EgressRegion": settings.egressRegion,
      "EstablishTunnelTimeoutSeconds": 0,
      "EmitDiagnosticNotices": true,
      "EmitBytesTransferred": true,
      "ClientPlatform": "Linux",
    };

    if (isConduit) {
      config["ServerEntrySignaturePublicKey"] =
          "sHuUVTWaRyh5pZwy4UguSgkwmBe0EHtJJkoF5WrxmvA=";
      config["DeviceRegion"] = "IR";
    }

    return config;
  }
}
