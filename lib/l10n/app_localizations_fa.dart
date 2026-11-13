// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'پینگوی شیطون';

  @override
  String get appSubtitle =>
      'کلاینت غیررسمی سایفون، تور، اس‌اس‌تی‌پی و وایرگارد،';

  @override
  String get appSubtitle2 =>
      'فایرفاکس وی‌پی‌ان، لنترن آن‌آفیشیال کلاینت، گف آن‌آفیشیال کلاینت، ان‌پی‌وی (napsternetV)';

  @override
  String get add => 'افزودن';

  @override
  String get addNew => 'افزودن جدید';

  @override
  String get allServers => 'همه سرورها';

  @override
  String get any => 'هرکدام';

  @override
  String get appearance => 'ظاهر';

  @override
  String get appliedTop20Ips => '۲۰ آی‌پی برتر اعمال شد';

  @override
  String get appliedTop5Ips => '۵ آی‌پی برتر + SNI اعمال شد';

  @override
  String get applyTop20 => 'اعمال ۲۰ تای برتر';

  @override
  String get applyTop5 => 'اعمال ۵ تای برتر';

  @override
  String get authenticationOptional => 'احراز هویت (اختیاری)';

  @override
  String get autoFindIpSni => 'یافتن خودکار IP و SNI';

  @override
  String get autoFirstProxy => 'خودکار (اولین پروکسی فعال)';

  @override
  String get autoFirstRunningProxy => 'خودکار (اولین پروکسی فعال)';

  @override
  String get autoReconnectPsiphon => 'اتصال مجدد خودکار سایفون';

  @override
  String get autoReconnectSstp => 'اتصال مجدد خودکار اس‌اس‌تی‌پی';

  @override
  String get autoReconnectTor => 'اتصال مجدد خودکار تور';

  @override
  String get autoRefresh15Min => 'بازخوانی خودکار هر ۱۵ دقیقه';

  @override
  String get autoRefreshSubtitle =>
      'سرورهای جدید را دریافت و سلامت را مجدداً بررسی می‌کند';

  @override
  String get binaryNotFound => 'فایل اجرایی پیدا نشد';

  @override
  String get bridgePresets => 'پیش‌تنظیم‌های بریج (اختیاری)';

  @override
  String get bridges => 'بریج‌ها (هر خط یکی، پشتیبانی از webtunnel)';

  @override
  String get bridgesHint => 'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get cancel => 'لغو';

  @override
  String get cancelBtn => 'لغو';

  @override
  String get cdnPreset => 'پیش‌تنظیم CDN';

  @override
  String get cdnScanner => 'اسکنر آی‌پی برای سایفون شیر و خورشید';

  @override
  String get cdnScanModeQuick => 'سریع';

  @override
  String get cdnScanModeBalanced => 'متعادل';

  @override
  String get cdnScanModeDeep => 'عمیق';

  @override
  String cdnScanModeQuickDesc(String samples, String max) {
    return 'سریع · $samples آی‌پی در هر CIDR · حداکثر $max آی‌پی در مجموع · حدود 1-2 دقیقه';
  }

  @override
  String cdnScanModeBalancedDesc(String samples, String max) {
    return 'متعادل · $samples آی‌پی در هر CIDR · حداکثر $max آی‌پی در مجموع · حدود 5-10 دقیقه';
  }

  @override
  String cdnScanModeDeepDesc(String max) {
    return 'عمیق · گسترش کامل · حداکثر $max آی‌پی در مجموع · حدود 30-60 دقیقه';
  }

  @override
  String get cdnScoutTitle => 'یافتن SNIهای کارکننده (پیشنهادی)';

  @override
  String cdnScoutProgress(String done, String total) {
    return 'در حال کاوش $done/$total…';
  }

  @override
  String get cdnScoutHint =>
      'SNIهای Discord/Reddit در ایران فیلتر هستند. قابلیت کاوش، موارد کارکننده را پیدا می‌کند.';

  @override
  String get cdnScoutButton => 'کاوش';

  @override
  String cdnScanPreview(String lines, String ips) {
    return '$lines خط · $ips آی‌پی اسکن خواهد شد';
  }

  @override
  String cdnScanWarningsMore(String count) {
    return '…و $count مورد دیگر';
  }

  @override
  String cdnApplyIpsToPsiphon(String count) {
    return 'اعمال $count آی‌پی روی Psiphon';
  }

  @override
  String cdnApplyIpsSnack(String count, String ip, String sni) {
    return '$count آی‌پی → Psiphon\nآی‌پی فرانتینگ: $ip\nSNI: $sni';
  }

  @override
  String get cdnSendToPsiphon => 'ارسال به Psiphon';

  @override
  String get cdnSaveEnteredIps => 'ذخیره آی‌پی‌های واردشده';

  @override
  String cdnIpsSavedSnack(String count, String total) {
    return '$count آی‌پی ذخیره شد ($total در لیست)';
  }

  @override
  String cdnCustomIpsSent(String count, String ip) {
    return '$count آی‌پی سفارشی → Psiphon (فرانتینگ: $ip)';
  }

  @override
  String cdnResultSubtitle(String score, String reliability, String latency,
      String download, String sni) {
    return 'امتیاز $score · پایداری $reliability/5 · ${latency}ms · دانلود ${download}ms · $sni';
  }

  @override
  String get check => 'بررسی';

  @override
  String get checkHealth => 'بررسی سلامت';

  @override
  String get checking => 'در حال بررسی…';

  @override
  String get clear => 'پاک کردن';

  @override
  String get clearAll => 'پاک کردن همه';

  @override
  String get clearLog => 'پاک کردن';

  @override
  String get close => 'بستن';

  @override
  String get colorTheme => 'تم رنگی';

  @override
  String get colorThemeSubtitle => 'یک طرح رنگ برای کل برنامه انتخاب کنید.';

  @override
  String get conduitWebrtc => 'Conduit (WebRTC Inproxy)';

  @override
  String get connected => 'متصل';

  @override
  String get connecting => 'در حال اتصال…';

  @override
  String get copiedToClipboard => 'در کلیپ‌بورد کپی شد';

  @override
  String get copyAllToClipboard => 'کپی همه';

  @override
  String get importFromClipboard => 'ورود از کلیپ‌بورد';

  @override
  String get importedFromClipboard => 'از کلیپ‌بورد وارد شد';

  @override
  String get nothingToImport => 'کلیپ‌بورد خالی است';

  @override
  String get itemsAddedCount => 'آیتم‌های افزوده‌شده';

  @override
  String get copy => 'کپی';

  @override
  String get copyAllCsv => 'کپی همه (CSV با جزئیات)';

  @override
  String get copyAllIpPort => 'کپی همه (ip:port)';

  @override
  String get copyLog => 'کپی';

  @override
  String get coreUpdates => 'آپدیت هسته‌ها';

  @override
  String get customIps => 'آی‌پی‌های سفارشی';

  @override
  String get delete => 'حذف';

  @override
  String get directNoProxy => 'مستقیم (بدون پروکسی)';

  @override
  String get directNoProxyOption => 'مستقیم (بدون پروکسی)';

  @override
  String get directNoUpstream => 'مستقیم (بدون آپ‌استریم)';

  @override
  String get disconnected => 'قطع‌شده';

  @override
  String get disconnectingTunnels => 'در حال قطع تونل‌های فعال…';

  @override
  String get download => 'دانلود';

  @override
  String get downloadVia => 'دانلود از طریق';

  @override
  String get downloadViaSubtitle =>
      'بررسی و دانلود از پروکسی انتخاب‌شده استفاده می‌کند وقتی دسترسی مستقیم فیلتر باشد.';

  @override
  String get egressRegion => 'منطقه خروجی';

  @override
  String get enableLogging => 'فعال‌سازی لاگ';

  @override
  String get enableLoggingSubtitle =>
      'وقتی خاموش باشد، لاگ جدیدی جمع‌آوری نمی‌شود';

  @override
  String get exitCountry => 'کشور خروجی';

  @override
  String get exitCountryAny => 'هرکدام (تصادفی)';

  @override
  String get fetch => 'دریافت';

  @override
  String get fetchVia => 'دریافت از طریق';

  @override
  String get fetching => 'در حال دریافت…';

  @override
  String get fingerprint => 'اثر انگشت';

  @override
  String get frontingAdvanced => 'فرانتینگ (پیشرفته، اختیاری)';

  @override
  String get frontingIp => 'آی‌پی فرانتینگ';

  @override
  String get httpHostHeader => 'هدر Host (مثلاً aparat.com, snapp.ir)';

  @override
  String get httpPort => 'پورت HTTP';

  @override
  String get installed => 'نصب‌شده';

  @override
  String get ipsCidrRanges => 'آی‌پی‌ها / CIDR / محدوده‌ها';

  @override
  String get ipv4Only => 'فقط IPv4';

  @override
  String get language => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSpanish => 'Español';

  @override
  String get latest => 'آخرین';

  @override
  String get lines => 'خط';

  @override
  String get listIsEmpty => 'لیست خالی است';

  @override
  String get localProxyPorts => 'پورت‌های پروکسی محلی';

  @override
  String get log => 'لاگ';

  @override
  String get logSourceFilter => 'فیلتر منابع لاگ';

  @override
  String get logSourcePsiphon => 'سایفون';

  @override
  String get logSourceTor => 'تور';

  @override
  String get logSourceSstp => 'اس‌اس‌تی‌پی';

  @override
  String get logSourceApp => 'برنامه';

  @override
  String get logSourceSystem => 'سیستم';

  @override
  String get manageList => 'مدیریت لیست (افزودن / حذف)';

  @override
  String get manualProxy => 'پروکسی دستی';

  @override
  String get manualProxyOption => 'پروکسی دستی';

  @override
  String get muteSounds => 'بی‌صدا کردن صداها';

  @override
  String get muteSoundsSubtitle =>
      'همه صداهای پینگو را غیرفعال کنید. واکنش‌های بصری همچنان پخش می‌شوند.';

  @override
  String get noCustomIpsSaved => 'هنوز هیچ آی‌پی سفارشی ذخیره نشده';

  @override
  String get noLogsYet => 'هنوز لاگی نیست';

  @override
  String get noUpstreamDirect => 'بدون آپ‌استریم (مستقیم)';

  @override
  String get notInstalled => 'نصب نشده';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get obfOff => 'خاموش';

  @override
  String get officialCore => 'هسته رسمی سایفون';

  @override
  String get password => 'رمز عبور';

  @override
  String get passwordOptional => 'رمز عبور (اختیاری)';

  @override
  String get port => 'پورت';

  @override
  String portRangeError(int min, int max) {
    return 'شماره پورتی بین $min تا $max وارد کنید';
  }

  @override
  String get preset1Subtitle =>
      'از هسته سایفون شیر و خورشید استفاده می‌کند (فورک غیررسمی).';

  @override
  String get preset1Title => '۱ · فرانتینگ (CDN). بهترین برای سانسور سنگین.';

  @override
  String get preset2Subtitle =>
      'از پروتکل‌های INPROXY-WEBRTC سایفون استفاده می‌کند.';

  @override
  String get preset2Title =>
      '2 · Conduit (WebRTC Inproxy). رله‌های غیرمتمرکز همتا.';

  @override
  String get preset3Subtitle => 'مستقیماً از هسته رسمی سایفون استفاده می‌کند.';

  @override
  String get preset3Title => '3 · اتصال مستقیم. مناسب برای سانسور خفیف.';

  @override
  String get profile => 'پروفایل';

  @override
  String get aetherPresetControlsNote =>
      'پروتکل، حالت اسکن و مبهم‌سازی از پروفایل انتخاب‌شده پیروی می‌کنند. برای ویرایش، Manual را انتخاب کنید.';

  @override
  String get protocol => 'پروتکل';

  @override
  String get proxyIp => 'آی‌پی پروکسی';

  @override
  String get proxyType => 'نوع پروکسی';

  @override
  String get psiphonConnectedVia => 'سایفون متصل شد از طریق';

  @override
  String get psiphonConnectionMode => 'حالت اتصال سایفون';

  @override
  String get psiphonSettings => 'تنظیمات سایفون';

  @override
  String get psiphonUpstream => 'سایفون';

  @override
  String get save => 'ذخیره';

  @override
  String get saveFoundIpsSni => 'ذخیره خودکار IPها و SNIهای یافت‌شده';

  @override
  String get scanMode => 'حالت اسکن';

  @override
  String get select => 'انتخاب…';

  @override
  String get selectAll => 'انتخاب همه';

  @override
  String get server => 'سرور';

  @override
  String get serverAddress => 'آدرس سرور';

  @override
  String get shareOnLan => 'اشتراک در شبکه محلی (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphon => 'اشتراک در شبکه محلی (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphonSubtitle =>
      'فوروارد پورت‌های SOCKS و HTTP روی همه رابط‌ها';

  @override
  String get showLess => 'نمایش کمتر';

  @override
  String get showLessSubtitle => 'پنهان کردن تنظیمات پیشرفته و لاگ‌ها';

  @override
  String get showMore => 'نمایش بیشتر';

  @override
  String get showMoreSubtitle =>
      'ظاهر، سایفون، تور، اس‌اس‌تی‌پی، وایرگارد، فایرفاکس وی‌پی‌ان، لنترن، گف، اسکنر، آپدیت‌ها، لاگ';

  @override
  String get sni => 'SNI';

  @override
  String get sniList => 'لیست SNI (هر خط یکی، ترتیب = اولویت)';

  @override
  String get socksPort => 'پورت SOCKS';

  @override
  String get sstpConnected => 'اس‌اس‌تی‌پی متصل شد';

  @override
  String get sstpSettings => 'تنظیمات اس‌اس‌تی‌پی';

  @override
  String get sstpSocksUpstream => 'SSTP';

  @override
  String get start => 'اتصال';

  @override
  String get startScan => 'شروع اسکن';

  @override
  String get stop => 'قطع';

  @override
  String get stopHealthCheck => 'توقف';

  @override
  String get stopScan => 'توقف';

  @override
  String get sunandlionCore => 'هسته سایفون شیر و خورشید';

  @override
  String get threads => 'تعداد رشته‌ها';

  @override
  String get tlsSni => 'TLS SNI (مثلاً a248.e.akamai.net)';

  @override
  String get torBridge => 'بریج (obfs4 / snowflake / سفارشی)';

  @override
  String get torConnected => 'تور متصل شد';

  @override
  String get torConnection => 'اتصال تور';

  @override
  String get torDirect => 'مستقیم (بدون بریج، بدون آپ‌استریم) — پیش‌فرض';

  @override
  String get torManual => 'پراکسی دستی';

  @override
  String get torSettings => 'تنظیمات تور';

  @override
  String get torSocksUpstream => 'تور';

  @override
  String get torUpstream => 'تور';

  @override
  String get torViaPsiphon => 'از طریق سایفون (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'از طریق اس‌اس‌تی‌پی (Tor-over-SSTP)';

  @override
  String get torViaFfvpn => 'از طریق فایرفاکس وی‌پی‌ان (Tor-over-Firefox VPN)';

  @override
  String get torViaLantern => 'از طریق لنترن (Tor-over-Lantern)';

  @override
  String get torViaGeph => 'از طریق گف (Tor-over-Geph)';

  @override
  String get torUpstreamNpv => 'از طریق NPV (Tor-over-NPV)';

  @override
  String get tunnelCore => 'هسته تونل';

  @override
  String get update => 'آپدیت';

  @override
  String get upstream => 'آپ‌استریم';

  @override
  String get upstreamType => 'نوع آپ‌استریم';

  @override
  String get usableIps => 'آی‌پی‌های قابل استفاده (مرتب‌شده بر اساس امتیاز)';

  @override
  String get useFronting => 'استفاده از فرانتینگ (CDN)';

  @override
  String get userOptional => 'نام کاربری (اختیاری)';

  @override
  String get username => 'نام کاربری';

  @override
  String get verboseLogging => 'لاگ تفصیلی';

  @override
  String get verboseLoggingSubtitle =>
      'فعال‌سازی خروجی دیباگ دقیق از sstp-proxy';

  @override
  String get vpngateServers => 'سرورهای اس‌اس‌تی‌پی VPN Gate';

  @override
  String get working => 'در حال کار';

  @override
  String get watchdog => 'واچ‌داگ';

  @override
  String get watchdogEnabled => 'فعال‌سازی واچ‌داگ';

  @override
  String get watchdogEnabledSubtitle =>
      'راه‌اندازی مجدد خودکار تونل‌ها در صورت عدم پاسخ‌دهی';

  @override
  String get watchdogSettings => 'تنظیمات واچ‌داگ';

  @override
  String get backToPresets => 'بازگشت به پروفایل‌های آماده';

  @override
  String get watchdogNetworkProfile => 'پروفایل شبکه';

  @override
  String get watchdogNetworkProfileSubtitle =>
      'شدت بررسی واچ‌داگ را تنظیم می‌کند. بر اساس شرایط شبکه انتخاب کنید.';

  @override
  String get watchdogProfileStable => 'پایدار';

  @override
  String get watchdogProfileStableDesc =>
      'کیفیت اینترنت خوب — بررسی سخت‌گیرانه، تشخیص سریع‌تر قطعی.';

  @override
  String get watchdogProfileNormal => 'معمولی';

  @override
  String get watchdogProfileNormalDesc =>
      'تنظیمات متعادل برای اکثر شبکه‌ها (پیش‌فرض).';

  @override
  String get watchdogProfileHarsh => 'فیلترینگ شدید';

  @override
  String get watchdogProfileHarshDesc =>
      'فیلترینگ سنگین یا شبکه ناپایدار — بررسی آسان‌گیر، restart بی‌مورد کمتر.';

  @override
  String get appUpdate => 'بروزرسانی برنامه';

  @override
  String get appUpdateChecking => 'در حال بررسی برای بروزرسانی...';

  @override
  String get appUpdateFailed => 'بررسی بروزرسانی ناموفق بود';

  @override
  String get appUpdateSaveDialogTitle => 'محل ذخیره بروزرسانی را انتخاب کنید';

  @override
  String get appUpdateDownloading => 'در حال دانلود بروزرسانی...';

  @override
  String get appUpdateDownloaded => 'بروزرسانی با موفقیت دانلود شد';

  @override
  String get appUpdateOpenFolder => 'باز کردن پوشه';

  @override
  String get appUpdateAvailable => 'بروزرسانی موجود است';

  @override
  String get appUpdateCurrentVersion => 'نسخه فعلی';

  @override
  String get appUpdateLatestVersion => 'آخرین نسخه';

  @override
  String get appUpdateReleaseNotes => 'یادداشت‌های انتشار';

  @override
  String get appUpdateCheck => 'بررسی بروزرسانی';

  @override
  String get appUpdateDownload => 'دانلود بروزرسانی';

  @override
  String get appUpdateUpToDate => 'شما بروز هستید';

  @override
  String get internetQuality => 'کیفیت اینترنت';

  @override
  String get internetQualityAvg => 'میانگین';

  @override
  String get internetQualityDeep => 'عمیق (۵ دقیقه)';

  @override
  String get internetQualityDegraded => 'افت‌کرده';

  @override
  String get internetQualityDirectDetails => 'جزئیات کیفیت مستقیم';

  @override
  String get internetQualityDns => 'DNS';

  @override
  String get internetQualityDown => 'قطع';

  @override
  String get internetQualityExcellent => 'عالی';

  @override
  String get internetQualityGood => 'خوب';

  @override
  String get internetQualityHttps => 'HTTPS';

  @override
  String get internetQualityJitter => 'نوسان';

  @override
  String get internetQualityLastCheck => 'آخرین بررسی';

  @override
  String get internetQualityLight => 'سبک (۱۵ ثانیه)';

  @override
  String get internetQualityMax => 'بیشترین';

  @override
  String get internetQualityMed => 'میانه';

  @override
  String get internetQualityMin => 'کمترین';

  @override
  String get internetQualityMonitoring => 'پایش پس‌زمینه';

  @override
  String get internetQualityNoResult => 'نتیجه‌ای نیست';

  @override
  String get internetQualityNormal => 'معمولی (۲ دقیقه)';

  @override
  String get internetQualityNotTested => 'تست نشده';

  @override
  String get internetQualityOff => 'خاموش';

  @override
  String get internetQualityP95 => 'P95';

  @override
  String get internetQualityQuality => 'کیفیت';

  @override
  String get internetQualitySnackbar => 'اینترنت:';

  @override
  String get internetQualityStatusFailing => 'ناموفق';

  @override
  String get internetQualityStatusOk => 'سالم';

  @override
  String get internetQualityStatusPartial => 'ناقص';

  @override
  String get internetQualityStatusSlow => 'کند';

  @override
  String get internetQualityStatusUnknown => 'نامعلوم';

  @override
  String get internetQualityTcp => 'TCP';

  @override
  String get internetQualityTest => 'تست';

  @override
  String get internetQualityUnstable => 'ناپایدار';

  @override
  String get wireguardSettings => 'تنظیمات وایرگارد';

  @override
  String get wireguardCoreTitle => 'هسته وایرگارد';

  @override
  String get wireguardCoreDescription =>
      'پیاده‌سازی WireGuard را انتخاب کنید. Amnezia برای فیلترینگ سنگین، مبهم‌سازی اضافه می‌کند.';

  @override
  String get wireguardCoreStandard => 'استاندارد (wireguard-go)';

  @override
  String get wireguardCoreAmnezia => 'Amnezia (wireguard-awg)';

  @override
  String get tunnelHealth => 'سلامت تونل';

  @override
  String get tunnelHealthProbeAll => 'تست همه';

  @override
  String get tunnelHealthProbeAgain => 'تست مجدد';

  @override
  String tunnelHealthNotRunning(String tunnel) {
    return '$tunnel در حال اجرا نیست';
  }

  @override
  String get tunnelHealthNoTunnelRunning => 'هیچ تونلی در حال اجرا نیست';

  @override
  String get tunnelHealthStopped => 'متوقف';

  @override
  String get tunnelHealthReachable => 'قابل دسترس (تست موفق)';

  @override
  String get tunnelHealthMeasuring => 'در حال اندازه‌گیری…';

  @override
  String get tunnelHealthExcellent => 'عالی';

  @override
  String get tunnelHealthGood => 'خوب';

  @override
  String get tunnelHealthFair => 'متوسط';

  @override
  String get tunnelHealthDegraded => 'ضعیف';

  @override
  String get tunnelHealthFailing => 'خراب';

  @override
  String get tunnelHealthLatency => 'تأخیر';

  @override
  String get tunnelHealthLoss => 'افت';

  @override
  String get tunnelHealthJitter => 'نوسان';

  @override
  String get tunnelHealthUptime => 'زمان اتصال';

  @override
  String get tunnelHealthReconnects => 'اتصال مجدد';

  @override
  String get tunnelHealthTrend => 'روند';

  @override
  String get tunnelHealthProtocol => 'پروتکل';

  @override
  String get tunnelHealthThroughput => 'توان عبور';

  @override
  String get tunnelHealthCircuits => 'مدارها';

  @override
  String get tunnelHealthIp => 'آی‌پی';

  @override
  String tunnelHealthLastProbeOk(int latency) {
    return 'آخرین تست: ${latency}ms — موفق';
  }

  @override
  String tunnelHealthLastProbeFailed(String error) {
    return 'آخرین تست ناموفق: $error';
  }

  @override
  String get tunnelHealthNoDataWarning =>
      'تونل فعال است ولی داده‌ای عبور نمی‌کند';

  @override
  String get tunnelHealthMeasuringHealth => 'در حال اندازه‌گیری سلامت…';

  @override
  String tunnelHealthTitle(String tunnel) {
    return 'سلامت $tunnel';
  }

  @override
  String get wireguardConfig => 'کانفیگ وایرگارد';

  @override
  String get wireguardConfigHint =>
      'کانفیگ استاندارد WireGuard (فرمت INI) یا URI با پروتکل wireguard:// را بچسبانید. برنامه فرمت را به‌صورت خودکار تشخیص می‌دهد.';

  @override
  String get wireguardConfigInvalid =>
      'کانفیگ WireGuard نامعتبر است — PrivateKey، PublicKey و Endpoint را بررسی کنید.';

  @override
  String get wireguardFormatStandard => 'استاندارد';

  @override
  String get wireguardFormatUri => 'URI';

  @override
  String get wireguardConvertToUri => 'تبدیل به URI';

  @override
  String get wireguardConvertToStandard => 'تبدیل به استاندارد';

  @override
  String get wireguardLoadConfFile => 'بارگذاری فایل .conf';

  @override
  String get wireguardConfFileLoaded => 'کانفیگ WireGuard از فایل بارگذاری شد';

  @override
  String get wireguardConfFileEmpty => 'فایل انتخاب‌شده خالی است';

  @override
  String get wireguardConfFileReadError => 'خواندن فایل انتخاب‌شده ممکن نشد';

  @override
  String get wireguardConnected => 'وایرگارد متصل شد';

  @override
  String get autoReconnectWireGuard => 'اتصال مجدد خودکار وایرگارد';

  @override
  String get logSourceWireGuard => 'وایرگارد';

  @override
  String get torViaWireGuard => 'از طریق وایرگارد (Tor-over-WireGuard)';

  @override
  String get psiphonWireGuardUpstream => 'وایرگارد';

  @override
  String get sstpWireGuardUpstream => 'وایرگارد';

  @override
  String get upstreamViaFfvpn => 'فایرفاکس وی‌پی‌ان';

  @override
  String get upstreamViaLantern => 'لنترن';

  @override
  String get upstreamViaGeph => 'گف';

  @override
  String get psiphonUpstreamNpv => 'NPV';

  @override
  String get sstpUpstreamNpv => 'NPV';

  @override
  String get diagnosticsReport => 'گزارش تشخیصی';

  @override
  String get diagnosticsReportGenerate => 'تولید گزارش';

  @override
  String get diagnosticsReportCopy => 'کپی گزارش';

  @override
  String get diagnosticsReportSave => 'ذخیره گزارش';

  @override
  String get diagnosticsReportGenerated => 'گزارش با موفقیت تولید شد';

  @override
  String get diagnosticsReportCopied => 'گزارش در کلیپ‌بورد کپی شد';

  @override
  String diagnosticsReportSaved(String path) {
    return 'گزارش ذخیره شد در: $path';
  }

  @override
  String get diagnosticsReportRedacted => 'اطلاعات حساس حذف شده‌اند';

  @override
  String get diagnosticsReportPreview => 'پیش‌نمایش';

  @override
  String get diagnosticsReportClose => 'بستن';

  @override
  String get diagnosticsReportGenerating => 'در حال تولید گزارش…';

  @override
  String get amneziaLinkDetected => 'لینک وی‌پی‌ان آمنزیا شناسایی شد';

  @override
  String get amneziaLinkName => 'نام';

  @override
  String get amneziaLinkEndpoint => 'اندپوینت API';

  @override
  String get amneziaLinkHint =>
      'برای دریافت کانفیگ واقعی AmneziaWG از API، روی «دریافت کانفیگ» کلیک کنید.';

  @override
  String get amneziaFetch => 'دریافت کانفیگ';

  @override
  String get amneziaFetching => 'در حال دریافت…';

  @override
  String get amneziaFetchSuccess => 'کانفیگ AmneziaWG با موفقیت دریافت شد';

  @override
  String get amneziaFetchFailed => 'دریافت کانفیگ AmneziaWG ناموفق بود';

  @override
  String get amneziaCoreRequired =>
      'برای لینک‌های vpn://، هسته AmneziaWG لازم است. برنامه به صورت خودکار آن را انتخاب می‌کند.';

  @override
  String get amneziaApiError => 'خطای API آمنزیا';

  @override
  String get amneziaInvalidLink => 'فرمت لینک vpn:// نامعتبر است';

  @override
  String get bridgeScanner => 'اسکنر بریج';

  @override
  String get bridgeScannerDescription =>
      'دریافت و تست بریج‌های تور (obfs4، webtunnel، snowflake، meek، conjure). رنگ‌بندی پینگ کمک می‌کند بریج‌هایی که واقعاً روی شبکه شما کار می‌کنند را انتخاب کنید.';

  @override
  String get bridgeLines => 'خطوط بریج (هر خط یکی)';

  @override
  String get bridgeLinesHint =>
      'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get bridgeThreads => 'تعداد رشته';

  @override
  String get bridgeStartScan => 'شروع اسکن';

  @override
  String get bridgeStopScan => 'توقف';

  @override
  String get bridgeResults => 'نتایج';

  @override
  String bridgeApplyWorking(int count) {
    return 'اعمال موارد کارکننده ($count)';
  }

  @override
  String bridgeApplyWorkingSnackbar(int count) {
    return '$count بریج کارکننده به تنظیمات تور اعمال شد';
  }

  @override
  String bridgeApplyWorkingRestarting(int count) {
    return '$count بریج اعمال شد — تور در حال راه‌اندازی مجدد برای اعمال تغییرات';
  }

  @override
  String bridgeApplyWorkingTorNotRunning(int count) {
    return '$count بریج اعمال شد — تور را شروع کنید تا استفاده شوند';
  }

  @override
  String bridgeFetch(String transport) {
    return 'دریافت $transport';
  }

  @override
  String get bridgeSaveWorking => 'ذخیره موارد کارکننده';

  @override
  String get bridgeLoadSaved => 'بارگذاری ذخیره‌شده';

  @override
  String get bridgeRescanSaved => 'اسکن مجدد ذخیره‌شده';

  @override
  String get bridgeClearSaved => 'پاک کردن ذخیره‌شده';

  @override
  String bridgeSavedCount(int count) {
    return 'ذخیره‌شده: $count';
  }

  @override
  String get bridgeNoSaved => 'هنوز بریجی ذخیره نشده';

  @override
  String get bridgeSavedBridges => 'بریج‌های ذخیره‌شده';

  @override
  String bridgeSaveSuccess(int count) {
    return '$count بریج ذخیره شد';
  }

  @override
  String bridgeLoadedSuccess(int count) {
    return '$count بریج ذخیره‌شده بارگذاری شد';
  }

  @override
  String bridgeRescanStarted(int count) {
    return 'اسکن مجدد $count بریج ذخیره‌شده';
  }

  @override
  String get bridgeClearedSaved => 'بریج‌های ذخیره‌شده پاک شدند';

  @override
  String get bridgeNothingToSave => 'بریج کارکننده‌ای برای ذخیره نیست';

  @override
  String get bridgeLoadFromScanner => 'بارگذاری از اسکنر بریج';

  @override
  String get bridgeLoadFromScannerSubtitle =>
      'بارگذاری بریج‌های کارکنندهٔ ذخیره‌شده از بخش اسکنر بریج در پایین';

  @override
  String get bridgeNoSavedInScanner => 'هنوز بریجی در اسکنر بریج ذخیره نشده';

  @override
  String get logSourceFfvpn => 'وی‌پی‌ان فایرفاکس';

  @override
  String get ffvpnSettings => 'تنظیمات وی‌پی‌ان فایرفاکس';

  @override
  String get ffvpnLoginSection => 'ورود / ثبت‌نام در مرورگر موزیلا';

  @override
  String get ffvpnLoginHint =>
      'صفحهٔ موزیلا را برای ورود یا ساخت حساب باز کنید. رمز، کد ایمیل و کپچا را همان‌جا وارد کنید. مرورگر را تا پایان تأیید باز نگه دارید؛ توکن نشست تأییدشده خودکار در قسمت پایین ذخیره می‌شود.';

  @override
  String get ffvpnEmailLabel => 'ایمیل حساب فایرفاکس (اختیاری)';

  @override
  String get ffvpnSignIn => 'باز کردن صفحهٔ ورود موزیلا';

  @override
  String get ffvpnConfirmingSignIn =>
      'تأیید ایمیل را در مرورگر تکمیل کنید. در انتظار تأیید نشست از طرف موزیلا…';

  @override
  String get ffvpnSigningIn => 'در حال ورود…';

  @override
  String get ffvpnSignedIn => 'وارد شدید — توکن نشست ذخیره شد.';

  @override
  String get ffvpnGuideTitle => 'توکن نشست حساب فایرفاکس';

  @override
  String get ffvpnGuideIntro =>
      'این پروکسی از وی‌پی‌ان داخلی مرورگر فایرفاکس (IP Protection، مبتنی بر Mozilla VPN) استفاده می‌کند و به توکن نشست حساب فایرفاکس شما نیاز دارد:';

  @override
  String get ffvpnGuideStep1 =>
      '۱. داخل خود مرورگر فایرفاکس یک حساب فایرفاکس بسازید یا وارد آن شوید تا نشست در مرورگر ذخیره شود.';

  @override
  String get ffvpnGuideStep2 =>
      '۲. در فایرفاکس صفحهٔ about:profiles را باز کنید تا پوشهٔ ریشهٔ پروفایل پیش‌فرض را پیدا کنید.';

  @override
  String get ffvpnGuideStep3 =>
      '۳. فایل signedInUser.json را در همان پوشه باز کنید و مقدار accountData.sessionToken (رشتهٔ ۶۴ کاراکتری هگز) را بردارید و در پایین بچسبانید.';

  @override
  String get ffvpnPathWindows =>
      'ویندوز: %APPDATA%\\Mozilla\\Firefox\\Profiles\\<profile>\\signedInUser.json';

  @override
  String get ffvpnPathLinux =>
      'لینوکس: ~/.mozilla/firefox/<profile>/signedInUser.json';

  @override
  String get ffvpnTokenLabel => 'توکن نشست حساب فایرفاکس';

  @override
  String get ffvpnTokenHint =>
      '۶۴ کاراکتر هگز — accountData.sessionToken از signedInUser.json';

  @override
  String get ffvpnPortSocks => 'پورت SOCKS';

  @override
  String get ffvpnPortHttp => 'پورت HTTP (0 = خاموش)';

  @override
  String get ffvpnSniLabel => 'SNI در TLS';

  @override
  String get ffvpnSniHint =>
      'نام میزبانی که در ClientHello به لبهٔ پروکسی فایرفاکس فرستاده می‌شود — خالی بگذارید تا نام دامنهٔ لبه استفاده شود';

  @override
  String get ffvpnUpstreamSection => 'پروکسی آپ‌استریم SOCKS';

  @override
  String get ffvpnUpstreamDesc =>
      'Firefox VPN اول به این hop از SOCKS5 وصل می‌شود و بعد به لبهٔ پروکسی فایرفاکس. وقتی لبه فیلتر شده یا مستقیم در دسترس نیست به کار می‌رود.';

  @override
  String get ffvpnUpstreamDirect => 'مستقیم (بدون آپ‌استریم)';

  @override
  String get ffvpnUpstreamManual => 'پروکسی SOCKS5 دستی';

  @override
  String get ffvpnUpstreamPsiphon => 'سایفون';

  @override
  String get ffvpnUpstreamTor => 'تور';

  @override
  String get ffvpnUpstreamSstp => 'SSTP';

  @override
  String get ffvpnUpstreamWireguard => 'وایرگارد';

  @override
  String get ffvpnUpstreamLantern => 'لنترن';

  @override
  String get ffvpnUpstreamGeph => 'گف';

  @override
  String get ffvpnUpstreamNpv => 'NPV';

  @override
  String ffvpnUpstreamVia(String name, String port) {
    return '$name به‌عنوان hop آپ‌استریم استفاده می‌شود (SOCKS روی 127.0.0.1:$port) و اگر هنوز بالا نیست به‌صورت خودکار بالا می‌آید.';
  }

  @override
  String get ffvpnUpstreamManualNote =>
      'نام میزبان همیشه به پروکسی فرستاده می‌شود تا DNS همان‌جا حل شود.';

  @override
  String get ffvpnCountrySection => 'کشور خروجی';

  @override
  String get ffvpnCountryAuto => 'خودکار (پیشنهاد سرور)';

  @override
  String get ffvpnLoadCountries => 'دریافت فهرست کشورها';

  @override
  String get ffvpnCountriesLoading => 'در حال دریافت فهرست کشورها…';

  @override
  String get ffvpnCountriesEmpty =>
      'هنوز کشوری بارگذاری نشده — «دریافت فهرست کشورها» را بزنید.';

  @override
  String get ffvpnCountriesFilteredOut =>
      'هیچ کشوری با فیلتر انتخاب‌شده مطابقت ندارد.';

  @override
  String get ffvpnCountryFilter => 'نمایش';

  @override
  String get ffvpnCountryFilterAll => 'همهٔ کشورها';

  @override
  String get ffvpnCountryFilterFree => 'فقط رایگان';

  @override
  String get ffvpnCountryFilterPlus => 'فقط پرمیوم';

  @override
  String get ffvpnCountryFilterHint =>
      'کشورهای قفل‌شده که اشتراک Mozilla VPN می‌خواهند؛ مثل خود فایرفاکس، به‌صورت پیش‌فرض پنهان‌اند.';

  @override
  String get ffvpnPremiumTag => 'پرمیوم';

  @override
  String get ffvpnQuotaSection => 'سهمیهٔ ماهانهٔ پهنای باند';

  @override
  String get ffvpnCheckQuota => 'بررسی سهمیه';

  @override
  String get ffvpnQuotaLoading => 'در حال بررسی سهمیه…';

  @override
  String ffvpnQuotaUsedOf(String used, String total, String percent) {
    return '$used از $total مصرف شده ($percent٪)';
  }

  @override
  String ffvpnQuotaLeft(String remaining) {
    return '$remaining باقی مانده';
  }

  @override
  String ffvpnQuotaResets(String date) {
    return 'ریست در $date';
  }

  @override
  String get ffvpnQuotaUnlimited =>
      'پهنای باند نامحدود — این حساب سهمیهٔ ماهانه ندارد.';

  @override
  String get ffvpnQuotaNoToken =>
      'برای بررسی سهمیه، اول توکن نشست را در بالا وارد کنید.';

  @override
  String get ffvpnErrNotEntitled =>
      'این حساب فایرفاکس اشتراک Mozilla VPN ندارد (HTTP 403) — سرویس پروکسی به اشتراک نیاز دارد.';

  @override
  String get ffvpnErrRegion => 'سرویس در منطقهٔ شما ارائه نمی‌شود (HTTP 451).';

  @override
  String get ffvpnErrBadToken =>
      'توکن نشست نامعتبر یا منقضی است. دوباره در فایرفاکس وارد شوید و توکن تازه‌ای از signedInUser.json بردارید.';

  @override
  String get ffvpnErrQuota =>
      'سهمیهٔ ماهانهٔ پهنای باند تمام شده — صبر کنید تا تاریخ ریست برسد.';

  @override
  String get ffvpnErrBinaryMissing =>
      'باینری ffvpn در پوشهٔ دادهٔ برنامه پیدا نشد.';

  @override
  String get ffvpnErrNetwork =>
      'خطای شبکه در اتصال به موزیلا — اتصال را بررسی کنید (شاید لازم باشد تونل دیگری فعال باشد) و دوباره تلاش کنید.';

  @override
  String get ffvpnErrBadCredentials =>
      'ایمیل یا رمز عبور نادرست است (یا ورود بلاک شده) — اطلاعات حساب فایرفاکس را بررسی کنید.';

  @override
  String get ffvpnErrSignInUnsupported =>
      'برای ورود مرورگری، در لینوکس Firefox و در ویندوز Microsoft Edge WebView2 Runtime را نصب کنید؛ یا توکن نشست را دستی بچسبانید.';

  @override
  String get ffvpnErrBlocked =>
      'لبهٔ امنیتی موزیلا درخواست ورود را از این شبکه بلاک کرد (HTTP 406). از داخل یک تونل یا شبکهٔ دیگر وارد شوید و دوباره تلاش کنید.';

  @override
  String get ffvpnErrOther => 'خطای ffvpn';

  @override
  String get logSourceLantern => 'لنترن';

  @override
  String get lanternSettings => 'تنظیمات لنترن';

  @override
  String get lanternConnectionSection => 'اتصال';

  @override
  String get lanternEngine => 'موتور اتصال';

  @override
  String get lanternEngineRadiance => 'رادیانس (رسمی نسخهٔ ۱۰، پیشنهادی)';

  @override
  String get lanternEngineClassic => 'کلاسیک (flashlight)';

  @override
  String get lanternEngineDesc =>
      'رادیانس همان موتور رسمی کلاینت لنترن نسخهٔ ۱۰ را اجرا می‌کند و خودش از فیلترینگ عبور می‌کند. کلاسیک همان کلاینت قدیمی است.';

  @override
  String get lanternPortSocks => 'پورت SOCKS';

  @override
  String get lanternPortHttp => 'پورت HTTP (۰ = غیرفعال)';

  @override
  String get lanternUpstreamSection => 'آپ‌استریم';

  @override
  String get lanternUpstreamDirect => 'بدون آپ‌استریم (مستقیم)';

  @override
  String get lanternUpstreamManual => 'پروکسی دستی';

  @override
  String get lanternUpstreamPsiphon => 'سایفون';

  @override
  String get lanternUpstreamTor => 'تور';

  @override
  String get lanternUpstreamSstp => 'SSTP';

  @override
  String get lanternUpstreamWireguard => 'وایرگارد';

  @override
  String get lanternUpstreamFfvpn => 'فایرفاکس وی‌پی‌ان';

  @override
  String get lanternUpstreamGeph => 'گف';

  @override
  String get lanternUpstreamNpv => 'NPV';

  @override
  String get lanternUpstreamDesc =>
      'اتصال به سرورهای لنترن (و در نبود سرور سالم، ترافیک شما هم) از این پروکسی عبور می‌کند — وقتی IP سرورهای لنترن بلاک است از آن استفاده کنید.';

  @override
  String get lanternUpstreamManualNote =>
      'اسکیم‌های مجاز: socks5:// ،socks5h:// ،http:// و https://.';

  @override
  String lanternUpstreamVia(String name, String port) {
    return '$name هاپ آپ‌استریم است (SOCKS روی 127.0.0.1:$port) و اگر بالا نباشد به‌طور خودکار بالا آورده می‌شود.';
  }

  @override
  String get lanternToolsSection => 'ابزارهای لنترن';

  @override
  String get lanternToolsServers => 'سرورها';

  @override
  String get lanternToolsCheckServers => 'بررسی سرورها';

  @override
  String get lanternServerReachable => 'در دسترس';

  @override
  String get lanternServerUnreachable => 'غیرقابل دسترسی';

  @override
  String get lanternServerNotChecked => 'بررسی‌نشده';

  @override
  String get lanternToolsAuth => 'حساب کاربری';

  @override
  String get lanternEmailLabel => 'ایمیل';

  @override
  String get lanternPasswordLabel => 'گذرواژه';

  @override
  String get lanternLoginBtn => 'ورود';

  @override
  String get lanternSignupBtn => 'ثبت‌نام';

  @override
  String get lanternLogoutBtn => 'خروج';

  @override
  String get lanternRunning => 'در حال اجرا';

  @override
  String get gephSettings => 'تنظیمات گف';

  @override
  String get gephConnectionSection => 'اتصال';

  @override
  String get gephPortSocks => 'پورت SOCKS';

  @override
  String get gephPortHttp => 'پورت HTTP (۰ = غیرفعال)';

  @override
  String get gephCountry => 'کشور خروجی';

  @override
  String get gephCountryAuto => 'خودکار (هر کشوری)';

  @override
  String get gephCountryRefresh => 'بروزرسانی لیست';

  @override
  String get gephCountryFilter => 'نمایش';

  @override
  String get gephCountryFilterAll => 'همهٔ کشورها';

  @override
  String get gephCountryFilterFree => 'فقط رایگان';

  @override
  String get gephCountryFilterPlus => 'فقط پرمیوم';

  @override
  String get gephAccountSection => 'حساب گف';

  @override
  String get gephAccountReady => 'کد حساب ذخیره شده است.';

  @override
  String get gephAccountMissing =>
      'هنوز حسابی ساخته نشده — «ساخت حساب» را بزنید، یا منبع کد/فایل را بالا مشخص کنید.';

  @override
  String gephAccountPath(String path) {
    return 'فایل کد حساب: $path';
  }

  @override
  String get gephSignupBtn => 'ساخت حساب';

  @override
  String get gephIHaveAccount => 'حساب دارم';

  @override
  String get gephRunning => 'در حال اجرا';

  @override
  String get logSourceGeph => 'گف';

  @override
  String get gephUpstreamSection => 'آپ‌استریم';

  @override
  String get gephUpstreamDirect => 'بدون آپ‌استریم (مستقیم)';

  @override
  String get gephUpstreamManual => 'پروکسی دستی';

  @override
  String get gephUpstreamPsiphon => 'سایفون';

  @override
  String get gephUpstreamTor => 'تور';

  @override
  String get gephUpstreamSstp => 'SSTP';

  @override
  String get gephUpstreamWireguard => 'وایرگارد';

  @override
  String get gephUpstreamFfvpn => 'فایرفاکس وی‌پی‌ان';

  @override
  String get gephUpstreamLantern => 'لنترن';

  @override
  String get gephUpstreamNpv => 'NPV';

  @override
  String get gephUpstreamDesc =>
      'گف اول بروکر و خروجی‌هایش را از این پروکسی می‌فرستد — وقتی اتصال مستقیم بلاک است از آن استفاده کنید. ساخت و بررسی حساب هم از همین مسیر می‌رود.';

  @override
  String get gephUpstreamManualNote =>
      'اسکیم‌های مجاز: socks5:// ،socks5h:// ،http:// و https://.';

  @override
  String gephUpstreamVia(String name, String port) {
    return '$name هاپ آپ‌استریم است (SOCKS روی 127.0.0.1:$port) و اگر بالا نباشد به‌طور خودکار بالا آورده می‌شود.';
  }

  @override
  String get gephAccountSource => 'منبع کد حساب';

  @override
  String get gephAccountSourceFile => 'فایل';

  @override
  String get gephAccountSourceCode => 'کد لاگین';

  @override
  String get gephAccountFilePath => 'فایل کد حساب';

  @override
  String get gephAccountFileHint =>
      'خالی بگذارید تا از فایل کد حساب داخل پوشهٔ دادهٔ برنامه استفاده شود.';

  @override
  String get gephLoginCodeLabel => 'کد لاگین';

  @override
  String get gephLoginCodeHint =>
      'کد لاگین گف — در تنظیمات برنامه ذخیره می‌شود.';

  @override
  String gephAccountSavedTo(String path) {
    return 'کد لاگین در $path ذخیره شد';
  }

  @override
  String get npvSettings => 'تنظیمات NPV Tunnel';

  @override
  String get npvEngineName => 'NPV';

  @override
  String get npvConfigSection => 'فایل کانفیگ NPV';

  @override
  String get npvConfigDesc =>
      'فایل .npvs که NPV با آن وصل می‌شود. یکی را از کامپیوتر انتخاب کنید.';

  @override
  String get npvPickConfigFile => 'انتخاب فایل';

  @override
  String get npvChangeConfigFile => 'عوض کردن فایل';

  @override
  String get npvClearConfigFile => 'حذف';

  @override
  String get npvNoConfigFile => 'هنوز فایلی انتخاب نشده';

  @override
  String npvConfigLoaded(String name) {
    return 'انتخاب شد: $name';
  }

  @override
  String get npvConfigReadError => 'خواندن فایل انتخاب‌شده ممکن نشد';

  @override
  String get npvConfigLockedWhileRunning =>
      'برای عوض کردن فایل، اول اتصال را متوقف کنید.';

  @override
  String get npvConnectionSection => 'پروکسی محلی و سنجش';

  @override
  String get npvPortSocks => 'پورت SOCKS';

  @override
  String get npvPortHttp => 'پورت HTTP (۰ = خاموش)';

  @override
  String get npvProbeSection => 'سنجش کانفیگ‌ها';

  @override
  String get npvProbeDesc =>
      'هر کانفیگ یک‌بار آزمایش می‌شود و سریع‌ترین کانفیگِ سالم استفاده می‌شود.';

  @override
  String get npvProbeTimeout => 'مهلت هر درخواست (ثانیه)';

  @override
  String get npvProbeJobs => 'سنجش‌های همزمان';

  @override
  String get npvProbeUrl => 'آدرس تست (اختیاری)';

  @override
  String get autoReconnectNpv => 'اتصال مجدد خودکار NPV';

  @override
  String get npvServersSection => 'سرورهای همین فایل';

  @override
  String get npvServersDesc =>
      'همهٔ کانفیگ‌های داخل فایل. «بررسی سرورها» تک‌تکشان را آزمایش می‌کند و نشان می‌دهد کدام‌ها کار می‌کنند؛ سریع‌ترین‌ها بالا.';

  @override
  String get npvServersListBtn => 'نمایش سرورها';

  @override
  String get npvServersCheckBtn => 'بررسی سرورها';

  @override
  String get npvServersCancelBtn => 'لغو';

  @override
  String get npvServersScanning => 'در حال سنجش کانفیگ‌ها…';

  @override
  String npvServersSummary(Object answered, Object total) {
    return '$answered از $total کانفیگ کار می‌کند';
  }

  @override
  String npvServersCount(Object total) {
    return '$total کانفیگ در همین فایل';
  }

  @override
  String get npvServersCreator => 'یادداشت';

  @override
  String get npvServersNone => 'این فایل هیچ کانفیگی ندارد.';

  @override
  String get npvServersNoFile =>
      'اول یک فایل .npvs انتخاب کنید؛ فعلاً چیزی برای نمایش نیست.';

  @override
  String get npvServersInUse => 'در حال استفاده';

  @override
  String get npvServersDead => 'غیرقابل دسترس';

  @override
  String get npvServersPinHint =>
      'روی هر کانفیگ بزنید تا همان استفاده شود؛ یک ضربهٔ دیگر برنامه را به انتخاب سریع‌ترین برمی‌گرداند.';

  @override
  String get npvServersPinnedChip => 'انتخاب‌شده';

  @override
  String get npvServersUnpinHint => 'انتخاب شده — برای لغو بزنید';

  @override
  String get npvServersAutoBtn => 'خودکار (سریع‌ترین)';

  @override
  String npvServersPinnedTo(Object label) {
    return 'انتخاب شده: $label';
  }

  @override
  String npvServersStalePin(Object index) {
    return 'کانفیگ انتخاب‌شدهٔ #$index در همین فایل نیست؛ یکی دیگر را انتخاب کنید یا به خودکار برگردید.';
  }

  @override
  String get npvServersPinIgnored =>
      'هستهٔ NPV کانفیگ دیگری استفاده کرد — برای انتخاب دستی، هسته را آپدیت کنید.';

  @override
  String get aetherConnected => 'اتر متصل شد';

  @override
  String get aetherManualHint =>
      'حالت دستی: پروتکل، مبهم‌سازی، حالت اسکن و اندپوینت سفارشی در پایین در اختیار شماست. حالت اسکن فقط وقتی اثر دارد که اندپوینت سفارشی خالی باشد.';

  @override
  String get aetherSettings => 'تنظیمات اتر';

  @override
  String get autoReconnectAether => 'اتصال مجدد خودکار اتر';

  @override
  String get both => 'هر دو';

  @override
  String get connectionMode => 'حالت اتصال';

  @override
  String get customEndpoint => 'اندپوینت سفارشی (اختیاری)';

  @override
  String get customEndpointHint => 'برای اسکن خودکار خالی بگذارید';

  @override
  String get endpointPinning => 'پین کردن اندپوینت';

  @override
  String get endpointPinningAutomatic => 'خودکار';

  @override
  String get endpointPinningAutomaticDesc =>
      'همیشه اسکن خودکار برای بهترین اندپوینت. توصیه‌شده برای اکثر کاربران.';

  @override
  String get endpointPinningCustomFirst => 'اول سفارشی';

  @override
  String get endpointPinningCustomFirstDesc =>
      'اول اندپوینت سفارشی را امتحان کن. اگر شکست خورد، به اسکن خودکار برگرد.';

  @override
  String get endpointPinningCustomOnly => 'فقط سفارشی';

  @override
  String get endpointPinningCustomOnlyDesc =>
      'فقط اندپوینت سفارشی. بدون fallback. برای تست یک سرور خاص.';

  @override
  String get endpointPinningNeedsCustom =>
      'برای فعال‌سازی حالت‌های «اول سفارشی» و «فقط سفارشی»، یک اندپوینت سفارشی پایین تعیین کنید.';

  @override
  String get endpointPinningSubtitle =>
      'کنترل کنید Aether چطور اندپوینت خود را انتخاب کند';

  @override
  String get ipType => 'نوع IP';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv6 => 'IPv6';

  @override
  String get localSocksPort => 'پورت SOCKS محلی';

  @override
  String get logSourceAether => 'اتر';

  @override
  String get obfAggressive => 'تهاجمی';

  @override
  String get obfBalanced => 'متعادل';

  @override
  String get obfDefaultCore => 'پیش‌فرض هسته';

  @override
  String get obfFirewall => 'فایروال';

  @override
  String get obfGfw => 'GFW';

  @override
  String get obfLight => 'سبک';

  @override
  String get obfuscation => 'مبهم‌سازی (--noize)';

  @override
  String get profileAdaptive => 'تطبیقی';

  @override
  String get profileAdaptiveDesc => 'تعادل سرعت و پوشش — مناسب اکثر شبکه‌ها';

  @override
  String get profileManual => 'دستی';

  @override
  String get profileManualDesc => 'همه گزینه‌ها دستی — برای کاربران حرفه‌ای';

  @override
  String get profilePatchy => 'سیگنال ناپایدار';

  @override
  String get profilePatchyDesc =>
      'دیتای موبایل ناپایدار — جستجوی سخت‌تر و مقاوم‌تر';

  @override
  String get profileStrict => 'شبکه محدود';

  @override
  String get profileStrictDesc =>
      'وای‌فای محدود یا فیلتر سنگین — fragment + masque-in-masque + noize gfw';

  @override
  String get protoGool => 'Gool (WARP-in-WARP)';

  @override
  String get protoMasque => 'MASQUE (HTTP/3 یا HTTP/2)';

  @override
  String get protoMim => 'MIM (masque-in-masque)';

  @override
  String get protoWireguard => 'WireGuard';

  @override
  String get scanBalanced => 'متعادل';

  @override
  String get scanIronclad => 'آهنین';

  @override
  String get scanStealth => 'مخفیانه';

  @override
  String get scanThorough => 'دقیق';

  @override
  String get scanTurbo => 'توربو';

  @override
  String get scanVerified => 'تأییدشده';

  @override
  String get torViaAether => 'از طریق اتر (Tor-over-Aether)';

  @override
  String get tryLastEndpointFirst => 'اول آخرین اندپوینت موفق را امتحان کن';

  @override
  String get tryLastEndpointFirstSubtitle =>
      'اگر فعال باشد، قبل از اسکن آخرین اندپوینت کارکننده امتحان می‌شود';

  @override
  String get aetherUpstream => 'اتر';
}
