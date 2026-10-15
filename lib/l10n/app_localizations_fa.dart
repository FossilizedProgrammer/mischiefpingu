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
      'کلاینت غیر رسمی سایفون، تور، اس‌اس‌تی‌پی، وایرگارد، فایرفاکس VPN';

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
  String get psiphonUpstream => 'سایفون (آپ‌استریم SOCKS)';

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
      'ظاهر، سایفون، تور، اس‌اس‌تی‌پی، وایرگارد، فایرفاکس VPN، اسکنر، آپدیت‌ها، لاگ';

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
  String get sstpSocksUpstream => 'اس‌اس‌تی‌پی (آپ‌استریم SOCKS)';

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
  String get torSocksUpstream => 'تور (آپ‌استریم SOCKS)';

  @override
  String get torUpstream => 'تور (آپ‌استریم SOCKS)';

  @override
  String get torViaPsiphon => 'از طریق سایفون (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'از طریق اس‌اس‌تی‌پی (Tor-over-SSTP)';

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
  String get psiphonWireGuardUpstream => 'وایرگارد (آپ‌استریم SOCKS)';

  @override
  String get sstpWireGuardUpstream => 'وایرگارد (آپ‌استریم SOCKS)';

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
  String get ffvpnUpstreamPsiphon => 'سایفون (SOCKS)';

  @override
  String get ffvpnUpstreamTor => 'تور (SOCKS)';

  @override
  String get ffvpnUpstreamSstp => 'SSTP (SOCKS)';

  @override
  String get ffvpnUpstreamWireguard => 'وایرگارد (SOCKS)';

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
  String get ffvpnShowPremium => 'نمایش کشورهای مخصوص اکانت پرمیوم';

  @override
  String get ffvpnShowPremiumDesc =>
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
  String get ffvpnErrOther => 'خطای ffvpn';

  @override
  String get logSourceLantern => 'لنترن';

  @override
  String get lanternSettings => 'تنظیمات لنترن';

  @override
  String get lanternConnectionSection => 'اتصال';

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
  String get lanternToolsRefreshServers => 'بروزرسانی لیست';

  @override
  String get lanternToolsCheckServers => 'بررسی دسترس‌پذیری';

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
}
