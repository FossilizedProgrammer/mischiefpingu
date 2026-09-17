import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fa'),
    Locale('ru'),
  ];

  static const String prefsKey = 'appLocale';

  String _t(String key) {
    final lang = locale.languageCode;
    final map = kTranslations[lang] ?? kTranslations['en']!;
    return map[key] ?? kTranslations['en']![key] ?? key;
  }

  String get start => _t('start');
  String get stop => _t('stop');
  String get cancel => _t('cancel');
  String get connected => _t('connected');
  String get connecting => _t('connecting');
  String get disconnected => _t('disconnected');

  String get appTitle => _t('appTitle');
  String get appSubtitle => _t('appSubtitle');

  String get psiphonConnectionMode => _t('psiphonConnectionMode');
  String get preset1Title => _t('preset1Title');
  String get preset1Subtitle => _t('preset1Subtitle');
  String get preset2Title => _t('preset2Title');
  String get preset2Subtitle => _t('preset2Subtitle');
  String get preset3Title => _t('preset3Title');
  String get preset3Subtitle => _t('preset3Subtitle');
  String get preset4Title => _t('preset4Title');
  String get preset4Subtitle => _t('preset4Subtitle');

  String get showMore => _t('showMore');
  String get showLess => _t('showLess');
  String get showMoreSubtitle => _t('showMoreSubtitle');
  String get showLessSubtitle => _t('showLessSubtitle');

  String get appearance => _t('appearance');
  String get colorTheme => _t('colorTheme');
  String get colorThemeSubtitle => _t('colorThemeSubtitle');
  String get notifications => _t('notifications');
  String get muteSounds => _t('muteSounds');
  String get muteSoundsSubtitle => _t('muteSoundsSubtitle');
  String get aetherSettings => _t('aetherSettings');
  String get psiphonSettings => _t('psiphonSettings');
  String get torSettings => _t('torSettings');
  String get sstpSettings => _t('sstpSettings');
  String get cdnScanner => _t('cdnScanner');
  String get vpngateServers => _t('vpngateServers');
  String get coreUpdates => _t('coreUpdates');
  String get log => _t('log');

  String get profile => _t('profile');
  String get protocol => _t('protocol');
  String get ipType => _t('ipType');
  String get scanMode => _t('scanMode');
  String get obfuscation => _t('obfuscation');
  String get localSocksPort => _t('localSocksPort');
  String get connectionMode => _t('connectionMode');
  String get customEndpoint => _t('customEndpoint');
  String get customEndpointHint => _t('customEndpointHint');
  String get tryLastEndpointFirst => _t('tryLastEndpointFirst');
  String get tryLastEndpointFirstSubtitle => _t('tryLastEndpointFirstSubtitle');
  String get shareOnLan => _t('shareOnLan');
  String get autoReconnectAether => _t('autoReconnectAether');

  String get socksPort => _t('socksPort');
  String get httpPort => _t('httpPort');
  String get egressRegion => _t('egressRegion');
  String get any => _t('any');
  String get shareOnLanPsiphon => _t('shareOnLanPsiphon');
  String get shareOnLanPsiphonSubtitle => _t('shareOnLanPsiphonSubtitle');
  String get ipv4Only => _t('ipv4Only');
  String get useFronting => _t('useFronting');
  String get tunnelCore => _t('tunnelCore');
  String get officialCore => _t('officialCore');
  String get sunandlionCore => _t('sunandlionCore');
  String get frontingIp => _t('frontingIp');
  String get httpHostHeader => _t('httpHostHeader');
  String get tlsSni => _t('tlsSni');
  String get autoFindIpSni => _t('autoFindIpSni');
  String get saveFoundIpsSni => _t('saveFoundIpsSni');
  String get upstream => _t('upstream');
  String get directNoUpstream => _t('directNoUpstream');
  String get manualProxy => _t('manualProxy');
  String get aetherSocksUpstream => _t('aetherSocksUpstream');
  String get conduitWebrtc => _t('conduitWebrtc');
  String get torSocksUpstream => _t('torSocksUpstream');
  String get sstpSocksUpstream => _t('sstpSocksUpstream');
  String get autoReconnectPsiphon => _t('autoReconnectPsiphon');
  String get proxyType => _t('proxyType');
  String get proxyIp => _t('proxyIp');
  String get port => _t('port');
  String get userOptional => _t('userOptional');
  String get passwordOptional => _t('passwordOptional');

  String get torConnection => _t('torConnection');
  String get torDirect => _t('torDirect');
  String get torBridge => _t('torBridge');
  String get torViaAether => _t('torViaAether');
  String get torViaPsiphon => _t('torViaPsiphon');
  String get torViaSstp => _t('torViaSstp');
  String get exitCountry => _t('exitCountry');
  String get exitCountryAny => _t('exitCountryAny');
  String get bridgePresets => _t('bridgePresets');
  String get bridges => _t('bridges');
  String get bridgesHint => _t('bridgesHint');
  String get clear => _t('clear');
  String get autoReconnectTor => _t('autoReconnectTor');

  String get server => _t('server');
  String get serverAddress => _t('serverAddress');
  String get authenticationOptional => _t('authenticationOptional');
  String get username => _t('username');
  String get password => _t('password');
  String get localProxyPorts => _t('localProxyPorts');
  String get upstreamType => _t('upstreamType');
  String get noUpstreamDirect => _t('noUpstreamDirect');
  String get manualProxyOption => _t('manualProxyOption');
  String get aetherUpstream => _t('aetherUpstream');
  String get psiphonUpstream => _t('psiphonUpstream');
  String get torUpstream => _t('torUpstream');
  String get frontingAdvanced => _t('frontingAdvanced');
  String get sni => _t('sni');
  String get fingerprint => _t('fingerprint');
  String get autoReconnectSstp => _t('autoReconnectSstp');
  String get verboseLogging => _t('verboseLogging');
  String get verboseLoggingSubtitle => _t('verboseLoggingSubtitle');

  String get cdnPreset => _t('cdnPreset');
  String get ipsCidrRanges => _t('ipsCidrRanges');
  String get sniList => _t('sniList');
  String get threads => _t('threads');
  String get startScan => _t('startScan');
  String get stopScan => _t('stopScan');
  String get usableIps => _t('usableIps');
  String get applyTop5 => _t('applyTop5');
  String get applyTop20 => _t('applyTop20');
  String get customIps => _t('customIps');
  String get save => _t('save');
  String get copy => _t('copy');
  String get clearAll => _t('clearAll');
  String get noCustomIpsSaved => _t('noCustomIpsSaved');

  String get fetchVia => _t('fetchVia');
  String get autoFirstRunningProxy => _t('autoFirstRunningProxy');
  String get directNoProxy => _t('directNoProxy');
  String get autoRefresh15Min => _t('autoRefresh15Min');
  String get autoRefreshSubtitle => _t('autoRefreshSubtitle');
  String get fetch => _t('fetch');
  String get fetching => _t('fetching');
  String get checkHealth => _t('checkHealth');
  String get stopHealthCheck => _t('stopHealthCheck');
  String get allServers => _t('allServers');
  String get copyAllIpPort => _t('copyAllIpPort');
  String get copyAllCsv => _t('copyAllCsv');

  String get downloadVia => _t('downloadVia');
  String get downloadViaSubtitle => _t('downloadViaSubtitle');
  String get autoFirstProxy => _t('autoFirstProxy');
  String get directNoProxyOption => _t('directNoProxyOption');
  String get check => _t('check');
  String get checking => _t('checking');
  String get update => _t('update');
  String get download => _t('download');
  String get working => _t('working');
  String get notInstalled => _t('notInstalled');
  String get installed => _t('installed');
  String get latest => _t('latest');

  String get enableLogging => _t('enableLogging');
  String get enableLoggingSubtitle => _t('enableLoggingSubtitle');
  String get clearLog => _t('clearLog');
  String get copyLog => _t('copyLog');
  String get noLogsYet => _t('noLogsYet');
  String get lines => _t('lines');

  String get manageList => _t('manageList');
  String get addNew => _t('addNew');
  String get select => _t('select');
  String get listIsEmpty => _t('listIsEmpty');
  String get cancelBtn => _t('cancelBtn');
  String get add => _t('add');
  String get close => _t('close');
  String get delete => _t('delete');

  String get profileAdaptive => _t('profileAdaptive');
  String get profileAdaptiveDesc => _t('profileAdaptiveDesc');
  String get profilePatchy => _t('profilePatchy');
  String get profilePatchyDesc => _t('profilePatchyDesc');
  String get profileStrict => _t('profileStrict');
  String get profileStrictDesc => _t('profileStrictDesc');
  String get profileManual => _t('profileManual');
  String get profileManualDesc => _t('profileManualDesc');

  String get protoMasque => _t('protoMasque');
  String get protoMim => _t('protoMim');
  String get protoWireguard => _t('protoWireguard');
  String get protoGool => _t('protoGool');

  String get scanTurbo => _t('scanTurbo');
  String get scanBalanced => _t('scanBalanced');
  String get scanThorough => _t('scanThorough');
  String get scanStealth => _t('scanStealth');
  String get scanIronclad => _t('scanIronclad');

  String get obfOff => _t('obfOff');
  String get obfLight => _t('obfLight');
  String get obfFirewall => _t('obfFirewall');
  String get obfBalanced => _t('obfBalanced');
  String get obfGfw => _t('obfGfw');
  String get obfAggressive => _t('obfAggressive');

  String get ipv4 => _t('ipv4');
  String get ipv6 => _t('ipv6');
  String get both => _t('both');

  String get language => _t('language');
  String get languageEnglish => _t('languageEnglish');
  String get languageFarsi => _t('languageFarsi');
  String get languageRussian => _t('languageRussian');

  String get copiedToClipboard => _t('copiedToClipboard');
  String get psiphonConnectedVia => _t('psiphonConnectedVia');
  String get aetherConnected => _t('aetherConnected');
  String get torConnected => _t('torConnected');
  String get sstpConnected => _t('sstpConnected');
  String get disconnectingTunnels => _t('disconnectingTunnels');
  String get binaryNotFound => _t('binaryNotFound');
  String get appliedTop5Ips => _t('appliedTop5Ips');
  String get appliedTop20Ips => _t('appliedTop20Ips');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fa', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isRtl => _locale.languageCode == 'fa';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppLocalizations.prefsKey) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_locale.languageCode == code) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppLocalizations.prefsKey, code);

    _locale = Locale(code);
    notifyListeners();
  }
}
