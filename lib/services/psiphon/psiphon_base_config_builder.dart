// lib/services/psiphon/psiphon_base_config_builder.dart
//
// ═══════════════════════════════════════════════════════════════
//  PsiphonBaseConfigBuilder — ساخت پایهٔ config Psiphon
//  (تفکیک شده از psiphon_config_builder.dart)
// ═══════════════════════════════════════════════════════════════
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

      // ═══════════════════════════════════════════════════════════════
      //  ⚠️ حیاتی: DisableTactics فقط برای Conduit باید false باشد.
      //
      //  در حالت fronting (SunAndLion)، Psiphon از
      //  FrontedMeekDialOverrides استفاده می‌کند که با tactics تداخل
      //  دارد. فعال بودن tactics باعث می‌شود core تنظیمات fronting
      //  کاربر را نادیده بگیرد و اتصال برقرار نشود.
      //
      //  در حالت عادی (direct/upstream)، tactics بی‌خطر است ولی
      //  برای سازگاری با نسخهٔ سالم، !isConduit نگه داشته می‌شود.
      // ═══════════════════════════════════════════════════════════════
      "DisableTactics": !isConduit,

      "AggressiveEstablishment": !isConduit,
      "UseIndistinguishableTLS": true,
      "TunnelWholeDevice": false,
      "EgressRegion": settings.egressRegion,

      // ═══════════════════════════════════════════════════════════════
      //  ⚠️ حیاتی: مقدار 0 = بی‌نهایت (بدون timeout).
      //
      //  مقدار 15 در نسخهٔ قبلی باعث می‌شد در شبکه‌های کند/فیلترشده
      //  core قبل از برقراری tunnel، timeout بخورد و رد شود.
      // ═══════════════════════════════════════════════════════════════
      "EstablishTunnelTimeoutSeconds": 0,

      "EmitDiagnosticNotices": true,
      "EmitBytesTransferred": true,
      "ClientPlatform": "Linux",
    };

    // ═══════════════════════════════════════════════════════════════
    //  ⚠️ حیاتی: ServerEntrySignaturePublicKey فقط برای Conduit.
    //
    //  کلید sHuUVTWaRyh5pZwy4UguSgkwmBe0EHtJJkoF5WrxmvA= مربوط به
    //  server entries مخصوص Conduit (INPROXY-WEBRTC) است، نه سرورهای
    //  معمولی Psiphon. اگر این کلید را به همه حالت‌ها تحمیل کنید،
    //  core نمی‌تواند server entries عادی را verify کند و در نتیجه
    //  خطای «missing public key» می‌دهد و tunnel ساخته نمی‌شود.
    // ═══════════════════════════════════════════════════════════════
    if (isConduit) {
      config["ServerEntrySignaturePublicKey"] =
          "sHuUVTWaRyh5pZwy4UguSgkwmBe0EHtJJkoF5WrxmvA=";
      config["DeviceRegion"] = "IR";
    }

    return config;
  }
}
