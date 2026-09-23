import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mischief Pingu'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unofficial Psiphon client, Aether client, Tor client, SSTP client'**
  String get appSubtitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  /// No description provided for @aetherConnected.
  ///
  /// In en, this message translates to:
  /// **'Aether Connected'**
  String get aetherConnected;

  /// No description provided for @aetherSettings.
  ///
  /// In en, this message translates to:
  /// **'Aether Settings'**
  String get aetherSettings;

  /// No description provided for @aetherSocksUpstream.
  ///
  /// In en, this message translates to:
  /// **'Aether (SOCKS upstream)'**
  String get aetherSocksUpstream;

  /// No description provided for @aetherUpstream.
  ///
  /// In en, this message translates to:
  /// **'Aether (SOCKS upstream)'**
  String get aetherUpstream;

  /// No description provided for @allServers.
  ///
  /// In en, this message translates to:
  /// **'All servers'**
  String get allServers;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appliedTop20Ips.
  ///
  /// In en, this message translates to:
  /// **'Applied Top 20 IPs'**
  String get appliedTop20Ips;

  /// No description provided for @appliedTop5Ips.
  ///
  /// In en, this message translates to:
  /// **'Applied Top 5 IPs + SNI'**
  String get appliedTop5Ips;

  /// No description provided for @applyTop20.
  ///
  /// In en, this message translates to:
  /// **'Apply Top 20'**
  String get applyTop20;

  /// No description provided for @applyTop5.
  ///
  /// In en, this message translates to:
  /// **'Apply Top 5'**
  String get applyTop5;

  /// No description provided for @authenticationOptional.
  ///
  /// In en, this message translates to:
  /// **'Authentication (optional)'**
  String get authenticationOptional;

  /// No description provided for @autoFindIpSni.
  ///
  /// In en, this message translates to:
  /// **'Auto-find IP & SNI'**
  String get autoFindIpSni;

  /// No description provided for @autoFirstProxy.
  ///
  /// In en, this message translates to:
  /// **'Auto (first running proxy)'**
  String get autoFirstProxy;

  /// No description provided for @autoFirstRunningProxy.
  ///
  /// In en, this message translates to:
  /// **'Auto (first running proxy)'**
  String get autoFirstRunningProxy;

  /// No description provided for @autoReconnectAether.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect Aether'**
  String get autoReconnectAether;

  /// No description provided for @autoReconnectPsiphon.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect Psiphon'**
  String get autoReconnectPsiphon;

  /// No description provided for @autoReconnectSstp.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect SSTP'**
  String get autoReconnectSstp;

  /// No description provided for @autoReconnectTor.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect Tor'**
  String get autoReconnectTor;

  /// No description provided for @autoRefresh15Min.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh every 15 minutes'**
  String get autoRefresh15Min;

  /// No description provided for @autoRefreshSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fetches new servers and re-checks health automatically'**
  String get autoRefreshSubtitle;

  /// No description provided for @binaryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Binary Not Found'**
  String get binaryNotFound;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @bridgePresets.
  ///
  /// In en, this message translates to:
  /// **'Bridge presets (optional)'**
  String get bridgePresets;

  /// No description provided for @bridges.
  ///
  /// In en, this message translates to:
  /// **'Bridges (one per line, custom supported — incl. webtunnel)'**
  String get bridges;

  /// No description provided for @bridgesHint.
  ///
  /// In en, this message translates to:
  /// **'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0'**
  String get bridgesHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @cdnPreset.
  ///
  /// In en, this message translates to:
  /// **'CDN Preset'**
  String get cdnPreset;

  /// No description provided for @cdnScanner.
  ///
  /// In en, this message translates to:
  /// **'CDN IP Scanner'**
  String get cdnScanner;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @checkHealth.
  ///
  /// In en, this message translates to:
  /// **'Check health'**
  String get checkHealth;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLog;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @colorThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color scheme for the entire app.'**
  String get colorThemeSubtitle;

  /// No description provided for @conduitWebrtc.
  ///
  /// In en, this message translates to:
  /// **'Conduit (WebRTC Inproxy)'**
  String get conduitWebrtc;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @connectionMode.
  ///
  /// In en, this message translates to:
  /// **'Connection Mode'**
  String get connectionMode;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copyAllCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy all (CSV with details)'**
  String get copyAllCsv;

  /// No description provided for @copyAllIpPort.
  ///
  /// In en, this message translates to:
  /// **'Copy all (ip:port)'**
  String get copyAllIpPort;

  /// No description provided for @copyLog.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyLog;

  /// No description provided for @coreUpdates.
  ///
  /// In en, this message translates to:
  /// **'Core Updates'**
  String get coreUpdates;

  /// No description provided for @customEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Custom Endpoint (optional)'**
  String get customEndpoint;

  /// No description provided for @customEndpointHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for auto-scan'**
  String get customEndpointHint;

  /// No description provided for @customIps.
  ///
  /// In en, this message translates to:
  /// **'Custom IPs'**
  String get customIps;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @directNoProxy.
  ///
  /// In en, this message translates to:
  /// **'Direct (no proxy)'**
  String get directNoProxy;

  /// No description provided for @directNoProxyOption.
  ///
  /// In en, this message translates to:
  /// **'Direct (no proxy)'**
  String get directNoProxyOption;

  /// No description provided for @directNoUpstream.
  ///
  /// In en, this message translates to:
  /// **'Direct (no upstream)'**
  String get directNoUpstream;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @disconnectingTunnels.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting active tunnels…'**
  String get disconnectingTunnels;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadVia.
  ///
  /// In en, this message translates to:
  /// **'Download via'**
  String get downloadVia;

  /// No description provided for @downloadViaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checks and downloads ride the selected proxy when direct access is filtered.'**
  String get downloadViaSubtitle;

  /// No description provided for @egressRegion.
  ///
  /// In en, this message translates to:
  /// **'Egress region'**
  String get egressRegion;

  /// No description provided for @enableLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable logging'**
  String get enableLogging;

  /// No description provided for @enableLoggingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, no new logs are collected'**
  String get enableLoggingSubtitle;

  /// No description provided for @exitCountry.
  ///
  /// In en, this message translates to:
  /// **'Exit country'**
  String get exitCountry;

  /// No description provided for @exitCountryAny.
  ///
  /// In en, this message translates to:
  /// **'Any (random)'**
  String get exitCountryAny;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetch;

  /// No description provided for @fetchVia.
  ///
  /// In en, this message translates to:
  /// **'Fetch via'**
  String get fetchVia;

  /// No description provided for @fetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get fetching;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @frontingAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Fronting (advanced, optional)'**
  String get frontingAdvanced;

  /// No description provided for @frontingIp.
  ///
  /// In en, this message translates to:
  /// **'Fronting IP'**
  String get frontingIp;

  /// No description provided for @httpHostHeader.
  ///
  /// In en, this message translates to:
  /// **'HTTP Host Header (e.g. aparat.com, snapp.ir)'**
  String get httpHostHeader;

  /// No description provided for @httpPort.
  ///
  /// In en, this message translates to:
  /// **'HTTP port'**
  String get httpPort;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @ipType.
  ///
  /// In en, this message translates to:
  /// **'IP Type'**
  String get ipType;

  /// No description provided for @ipsCidrRanges.
  ///
  /// In en, this message translates to:
  /// **'IPs / CIDR / Ranges'**
  String get ipsCidrRanges;

  /// No description provided for @ipv4.
  ///
  /// In en, this message translates to:
  /// **'IPv4'**
  String get ipv4;

  /// No description provided for @ipv4Only.
  ///
  /// In en, this message translates to:
  /// **'IPv4 only'**
  String get ipv4Only;

  /// No description provided for @ipv6.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get ipv6;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFarsi.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languageFarsi;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @lines.
  ///
  /// In en, this message translates to:
  /// **'lines'**
  String get lines;

  /// No description provided for @listIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get listIsEmpty;

  /// No description provided for @localProxyPorts.
  ///
  /// In en, this message translates to:
  /// **'Local proxy ports'**
  String get localProxyPorts;

  /// No description provided for @localSocksPort.
  ///
  /// In en, this message translates to:
  /// **'Local SOCKS port'**
  String get localSocksPort;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @logSourceFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter Log Sources'**
  String get logSourceFilter;

  /// No description provided for @logSourcePsiphon.
  ///
  /// In en, this message translates to:
  /// **'Psiphon'**
  String get logSourcePsiphon;

  /// No description provided for @logSourceAether.
  ///
  /// In en, this message translates to:
  /// **'Aether'**
  String get logSourceAether;

  /// No description provided for @logSourceTor.
  ///
  /// In en, this message translates to:
  /// **'Tor'**
  String get logSourceTor;

  /// No description provided for @logSourceSstp.
  ///
  /// In en, this message translates to:
  /// **'SSTP'**
  String get logSourceSstp;

  /// No description provided for @logSourceApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get logSourceApp;

  /// No description provided for @logSourceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get logSourceSystem;

  /// No description provided for @manageList.
  ///
  /// In en, this message translates to:
  /// **'Manage list (Add / Delete)'**
  String get manageList;

  /// No description provided for @manualProxy.
  ///
  /// In en, this message translates to:
  /// **'Manual proxy'**
  String get manualProxy;

  /// No description provided for @manualProxyOption.
  ///
  /// In en, this message translates to:
  /// **'Manual proxy'**
  String get manualProxyOption;

  /// No description provided for @muteSounds.
  ///
  /// In en, this message translates to:
  /// **'Mute sounds'**
  String get muteSounds;

  /// No description provided for @muteSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable all penguin sounds (ouch / sigh / happy). The visual reactions still play.'**
  String get muteSoundsSubtitle;

  /// No description provided for @noCustomIpsSaved.
  ///
  /// In en, this message translates to:
  /// **'No custom IPs saved yet'**
  String get noCustomIpsSaved;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @noUpstreamDirect.
  ///
  /// In en, this message translates to:
  /// **'No upstream (direct)'**
  String get noUpstreamDirect;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get notInstalled;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @obfAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get obfAggressive;

  /// No description provided for @obfBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get obfBalanced;

  /// No description provided for @obfFirewall.
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get obfFirewall;

  /// No description provided for @obfGfw.
  ///
  /// In en, this message translates to:
  /// **'GFW'**
  String get obfGfw;

  /// No description provided for @obfLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get obfLight;

  /// No description provided for @obfOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get obfOff;

  /// No description provided for @obfuscation.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation (--noize)'**
  String get obfuscation;

  /// No description provided for @officialCore.
  ///
  /// In en, this message translates to:
  /// **'official psiphon tunnel core'**
  String get officialCore;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get passwordOptional;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @preset1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses the SunAndLion Psiphon Tunnel Core (Unofficial fork of Psiphon tunnel core).'**
  String get preset1Subtitle;

  /// No description provided for @preset1Title.
  ///
  /// In en, this message translates to:
  /// **'1 · Fronting (CDN). Best for heavy censorship.'**
  String get preset1Title;

  /// No description provided for @preset2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses official Psiphon Tunnel Core with Aether upstream.'**
  String get preset2Subtitle;

  /// No description provided for @preset2Title.
  ///
  /// In en, this message translates to:
  /// **'2 · Aether traffic as upstream. Suitable when Aether works.'**
  String get preset2Title;

  /// No description provided for @preset3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses Psiphon INPROXY-WEBRTC protocols via volunteer stations.'**
  String get preset3Subtitle;

  /// No description provided for @preset3Title.
  ///
  /// In en, this message translates to:
  /// **'3 · Conduit (WebRTC Inproxy). Decentralized peer relays.'**
  String get preset3Title;

  /// No description provided for @preset4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses the official Psiphon Tunnel Core directly.'**
  String get preset4Subtitle;

  /// No description provided for @preset4Title.
  ///
  /// In en, this message translates to:
  /// **'4 · Direct connection. Suitable for mild censorship.'**
  String get preset4Title;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get profileAdaptive;

  /// No description provided for @profileAdaptiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Balance of speed and coverage — suitable for most networks'**
  String get profileAdaptiveDesc;

  /// No description provided for @profileManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get profileManual;

  /// No description provided for @profileManualDesc.
  ///
  /// In en, this message translates to:
  /// **'All options manual — for advanced users'**
  String get profileManualDesc;

  /// No description provided for @profilePatchy.
  ///
  /// In en, this message translates to:
  /// **'Patchy signal'**
  String get profilePatchy;

  /// No description provided for @profilePatchyDesc.
  ///
  /// In en, this message translates to:
  /// **'Unstable mobile data — harder and more resilient search'**
  String get profilePatchyDesc;

  /// No description provided for @profileStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict network'**
  String get profileStrict;

  /// No description provided for @profileStrictDesc.
  ///
  /// In en, this message translates to:
  /// **'Restricted Wi-Fi or heavy filtering — fragment + masque-in-masque + noize gfw'**
  String get profileStrictDesc;

  /// No description provided for @protoGool.
  ///
  /// In en, this message translates to:
  /// **'Gool (WARP-in-WARP)'**
  String get protoGool;

  /// No description provided for @protoMasque.
  ///
  /// In en, this message translates to:
  /// **'MASQUE (HTTP/3 or HTTP/2)'**
  String get protoMasque;

  /// No description provided for @protoMim.
  ///
  /// In en, this message translates to:
  /// **'MIM (masque-in-masque)'**
  String get protoMim;

  /// No description provided for @protoWireguard.
  ///
  /// In en, this message translates to:
  /// **'WireGuard'**
  String get protoWireguard;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @proxyIp.
  ///
  /// In en, this message translates to:
  /// **'Proxy IP'**
  String get proxyIp;

  /// No description provided for @proxyType.
  ///
  /// In en, this message translates to:
  /// **'Proxy type'**
  String get proxyType;

  /// No description provided for @psiphonConnectedVia.
  ///
  /// In en, this message translates to:
  /// **'Psiphon Connected via'**
  String get psiphonConnectedVia;

  /// No description provided for @psiphonConnectionMode.
  ///
  /// In en, this message translates to:
  /// **'Psiphon connection mode'**
  String get psiphonConnectionMode;

  /// No description provided for @psiphonSettings.
  ///
  /// In en, this message translates to:
  /// **'Psiphon Settings'**
  String get psiphonSettings;

  /// No description provided for @psiphonUpstream.
  ///
  /// In en, this message translates to:
  /// **'Psiphon (SOCKS upstream)'**
  String get psiphonUpstream;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveFoundIpsSni.
  ///
  /// In en, this message translates to:
  /// **'Save found IPs & SNI automatically'**
  String get saveFoundIpsSni;

  /// No description provided for @scanBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get scanBalanced;

  /// No description provided for @scanIronclad.
  ///
  /// In en, this message translates to:
  /// **'Ironclad'**
  String get scanIronclad;

  /// No description provided for @scanMode.
  ///
  /// In en, this message translates to:
  /// **'Scan mode'**
  String get scanMode;

  /// No description provided for @scanStealth.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get scanStealth;

  /// No description provided for @scanThorough.
  ///
  /// In en, this message translates to:
  /// **'Thorough'**
  String get scanThorough;

  /// No description provided for @scanTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get scanTurbo;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// No description provided for @shareOnLan.
  ///
  /// In en, this message translates to:
  /// **'Share on LAN (bind 0.0.0.0)'**
  String get shareOnLan;

  /// No description provided for @shareOnLanPsiphon.
  ///
  /// In en, this message translates to:
  /// **'Share on LAN (bind 0.0.0.0)'**
  String get shareOnLanPsiphon;

  /// No description provided for @shareOnLanPsiphonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forward SOCKS & HTTP ports on all interfaces via Dart'**
  String get shareOnLanPsiphonSubtitle;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showLessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide advanced settings & logs'**
  String get showLessSubtitle;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showMoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, Aether, Psiphon, Tor, SSTP, WireGuard, Scanner, Updates, Log'**
  String get showMoreSubtitle;

  /// No description provided for @sni.
  ///
  /// In en, this message translates to:
  /// **'SNI'**
  String get sni;

  /// No description provided for @sniList.
  ///
  /// In en, this message translates to:
  /// **'SNI list (one per line, order = priority)'**
  String get sniList;

  /// No description provided for @socksPort.
  ///
  /// In en, this message translates to:
  /// **'SOCKS port'**
  String get socksPort;

  /// No description provided for @sstpConnected.
  ///
  /// In en, this message translates to:
  /// **'SSTP Connected'**
  String get sstpConnected;

  /// No description provided for @sstpSettings.
  ///
  /// In en, this message translates to:
  /// **'SSTP Settings'**
  String get sstpSettings;

  /// No description provided for @sstpSocksUpstream.
  ///
  /// In en, this message translates to:
  /// **'SSTP (SOCKS upstream)'**
  String get sstpSocksUpstream;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopHealthCheck;

  /// No description provided for @stopScan.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopScan;

  /// No description provided for @sunandlionCore.
  ///
  /// In en, this message translates to:
  /// **'sunandlion psiphon tunnel core'**
  String get sunandlionCore;

  /// No description provided for @threads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threads;

  /// No description provided for @tlsSni.
  ///
  /// In en, this message translates to:
  /// **'TLS SNI (e.g. a248.e.akamai.net)'**
  String get tlsSni;

  /// No description provided for @torBridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge (obfs4 / snowflake / custom)'**
  String get torBridge;

  /// No description provided for @torConnected.
  ///
  /// In en, this message translates to:
  /// **'Tor Connected'**
  String get torConnected;

  /// No description provided for @torConnection.
  ///
  /// In en, this message translates to:
  /// **'Tor connection'**
  String get torConnection;

  /// No description provided for @torDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct (no bridge, no upstream) — default'**
  String get torDirect;

  /// No description provided for @torManual.
  ///
  /// In en, this message translates to:
  /// **'Manual proxy'**
  String get torManual;

  /// No description provided for @torSettings.
  ///
  /// In en, this message translates to:
  /// **'Tor Settings'**
  String get torSettings;

  /// No description provided for @torSocksUpstream.
  ///
  /// In en, this message translates to:
  /// **'Tor (SOCKS upstream)'**
  String get torSocksUpstream;

  /// No description provided for @torUpstream.
  ///
  /// In en, this message translates to:
  /// **'Tor (SOCKS upstream)'**
  String get torUpstream;

  /// No description provided for @torViaAether.
  ///
  /// In en, this message translates to:
  /// **'Via Aether (Tor-over-Aether)'**
  String get torViaAether;

  /// No description provided for @torViaPsiphon.
  ///
  /// In en, this message translates to:
  /// **'Via Psiphon (Tor-over-Psiphon)'**
  String get torViaPsiphon;

  /// No description provided for @torViaSstp.
  ///
  /// In en, this message translates to:
  /// **'Via SSTP (Tor-over-SSTP)'**
  String get torViaSstp;

  /// No description provided for @tryLastEndpointFirst.
  ///
  /// In en, this message translates to:
  /// **'Try last successful endpoint first'**
  String get tryLastEndpointFirst;

  /// No description provided for @tryLastEndpointFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If enabled, will try the last working endpoint before scanning'**
  String get tryLastEndpointFirstSubtitle;

  /// No description provided for @tunnelCore.
  ///
  /// In en, this message translates to:
  /// **'Tunnel core'**
  String get tunnelCore;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @upstream.
  ///
  /// In en, this message translates to:
  /// **'Upstream'**
  String get upstream;

  /// No description provided for @upstreamType.
  ///
  /// In en, this message translates to:
  /// **'Upstream type'**
  String get upstreamType;

  /// No description provided for @usableIps.
  ///
  /// In en, this message translates to:
  /// **'Usable IPs (sorted by score)'**
  String get usableIps;

  /// No description provided for @useFronting.
  ///
  /// In en, this message translates to:
  /// **'Use fronting (CDN)'**
  String get useFronting;

  /// No description provided for @userOptional.
  ///
  /// In en, this message translates to:
  /// **'User (optional)'**
  String get userOptional;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @verboseLogging.
  ///
  /// In en, this message translates to:
  /// **'Verbose logging'**
  String get verboseLogging;

  /// No description provided for @verboseLoggingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable detailed debug output from sstp-proxy'**
  String get verboseLoggingSubtitle;

  /// No description provided for @vpngateServers.
  ///
  /// In en, this message translates to:
  /// **'VPN Gate SSTP Servers'**
  String get vpngateServers;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;

  /// No description provided for @watchdog.
  ///
  /// In en, this message translates to:
  /// **'Watchdog'**
  String get watchdog;

  /// No description provided for @watchdogEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable watchdog'**
  String get watchdogEnabled;

  /// No description provided for @watchdogEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically restart tunnels when they become unresponsive'**
  String get watchdogEnabledSubtitle;

  /// No description provided for @watchdogSettings.
  ///
  /// In en, this message translates to:
  /// **'Watchdog Settings'**
  String get watchdogSettings;

  /// No description provided for @backToPresets.
  ///
  /// In en, this message translates to:
  /// **'Back to presets'**
  String get backToPresets;

  /// No description provided for @aetherManualHint.
  ///
  /// In en, this message translates to:
  /// **'Manual mode: Protocol, obfuscation, scan mode, and custom endpoint are fully under your control below.'**
  String get aetherManualHint;

  /// No description provided for @watchdogNetworkProfile.
  ///
  /// In en, this message translates to:
  /// **'Network Profile'**
  String get watchdogNetworkProfile;

  /// No description provided for @watchdogNetworkProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjusts how aggressively the watchdog probes. Choose based on your network conditions.'**
  String get watchdogNetworkProfileSubtitle;

  /// No description provided for @watchdogProfileStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get watchdogProfileStable;

  /// No description provided for @watchdogProfileStableDesc.
  ///
  /// In en, this message translates to:
  /// **'Good internet quality — strict probing, faster detection of failures.'**
  String get watchdogProfileStableDesc;

  /// No description provided for @watchdogProfileNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get watchdogProfileNormal;

  /// No description provided for @watchdogProfileNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced settings for most networks (default).'**
  String get watchdogProfileNormalDesc;

  /// No description provided for @watchdogProfileHarsh.
  ///
  /// In en, this message translates to:
  /// **'Harsh filtering'**
  String get watchdogProfileHarsh;

  /// No description provided for @watchdogProfileHarshDesc.
  ///
  /// In en, this message translates to:
  /// **'Heavy filtering or unstable network — lenient probing, fewer false restarts.'**
  String get watchdogProfileHarshDesc;

  /// No description provided for @appUpdate.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get appUpdate;

  /// No description provided for @appUpdateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get appUpdateChecking;

  /// No description provided for @appUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get appUpdateFailed;

  /// No description provided for @appUpdateSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select where to save the update'**
  String get appUpdateSaveDialogTitle;

  /// No description provided for @appUpdateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get appUpdateDownloading;

  /// No description provided for @appUpdateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Update downloaded successfully'**
  String get appUpdateDownloaded;

  /// No description provided for @appUpdateOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get appUpdateOpenFolder;

  /// No description provided for @appUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get appUpdateAvailable;

  /// No description provided for @appUpdateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get appUpdateCurrentVersion;

  /// No description provided for @appUpdateLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest Version'**
  String get appUpdateLatestVersion;

  /// No description provided for @appUpdateReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes'**
  String get appUpdateReleaseNotes;

  /// No description provided for @appUpdateCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get appUpdateCheck;

  /// No description provided for @appUpdateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Update'**
  String get appUpdateDownload;

  /// No description provided for @appUpdateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date'**
  String get appUpdateUpToDate;

  /// No description provided for @internetQuality.
  ///
  /// In en, this message translates to:
  /// **'Internet Quality'**
  String get internetQuality;

  /// No description provided for @internetQualityAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get internetQualityAvg;

  /// No description provided for @internetQualityDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep (5m)'**
  String get internetQualityDeep;

  /// No description provided for @internetQualityDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get internetQualityDegraded;

  /// No description provided for @internetQualityDirectDetails.
  ///
  /// In en, this message translates to:
  /// **'Direct quality details'**
  String get internetQualityDirectDetails;

  /// No description provided for @internetQualityDns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get internetQualityDns;

  /// No description provided for @internetQualityDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get internetQualityDown;

  /// No description provided for @internetQualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get internetQualityExcellent;

  /// No description provided for @internetQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get internetQualityGood;

  /// No description provided for @internetQualityHttps.
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get internetQualityHttps;

  /// No description provided for @internetQualityJitter.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get internetQualityJitter;

  /// No description provided for @internetQualityLastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last check'**
  String get internetQualityLastCheck;

  /// No description provided for @internetQualityLight.
  ///
  /// In en, this message translates to:
  /// **'Light (15s)'**
  String get internetQualityLight;

  /// No description provided for @internetQualityMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get internetQualityMax;

  /// No description provided for @internetQualityMed.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get internetQualityMed;

  /// No description provided for @internetQualityMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get internetQualityMin;

  /// No description provided for @internetQualityMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Background monitoring'**
  String get internetQualityMonitoring;

  /// No description provided for @internetQualityNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get internetQualityNoResult;

  /// No description provided for @internetQualityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal (2m)'**
  String get internetQualityNormal;

  /// No description provided for @internetQualityNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get internetQualityNotTested;

  /// No description provided for @internetQualityOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get internetQualityOff;

  /// No description provided for @internetQualityP95.
  ///
  /// In en, this message translates to:
  /// **'P95'**
  String get internetQualityP95;

  /// No description provided for @internetQualityQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get internetQualityQuality;

  /// No description provided for @internetQualitySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Internet:'**
  String get internetQualitySnackbar;

  /// No description provided for @internetQualityStatusFailing.
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get internetQualityStatusFailing;

  /// No description provided for @internetQualityStatusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get internetQualityStatusOk;

  /// No description provided for @internetQualityStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get internetQualityStatusPartial;

  /// No description provided for @internetQualityStatusSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get internetQualityStatusSlow;

  /// No description provided for @internetQualityStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get internetQualityStatusUnknown;

  /// No description provided for @internetQualityTcp.
  ///
  /// In en, this message translates to:
  /// **'TCP'**
  String get internetQualityTcp;

  /// No description provided for @internetQualityTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get internetQualityTest;

  /// No description provided for @internetQualityUnstable.
  ///
  /// In en, this message translates to:
  /// **'Unstable'**
  String get internetQualityUnstable;

  /// No description provided for @wireguardSettings.
  ///
  /// In en, this message translates to:
  /// **'WireGuard Settings'**
  String get wireguardSettings;

  /// No description provided for @tunnelHealth.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Health'**
  String get tunnelHealth;

  /// No description provided for @tunnelHealthProbeAll.
  ///
  /// In en, this message translates to:
  /// **'Test all'**
  String get tunnelHealthProbeAll;

  /// No description provided for @tunnelHealthProbeAgain.
  ///
  /// In en, this message translates to:
  /// **'Retest'**
  String get tunnelHealthProbeAgain;

  /// No description provided for @tunnelHealthNotRunning.
  ///
  /// In en, this message translates to:
  /// **'{tunnel} is not running'**
  String tunnelHealthNotRunning(String tunnel);

  /// No description provided for @tunnelHealthNoTunnelRunning.
  ///
  /// In en, this message translates to:
  /// **'No tunnel is running'**
  String get tunnelHealthNoTunnelRunning;

  /// No description provided for @tunnelHealthStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get tunnelHealthStopped;

  /// No description provided for @tunnelHealthReachable.
  ///
  /// In en, this message translates to:
  /// **'Reachable (probe OK)'**
  String get tunnelHealthReachable;

  /// No description provided for @tunnelHealthMeasuring.
  ///
  /// In en, this message translates to:
  /// **'Measuring…'**
  String get tunnelHealthMeasuring;

  /// No description provided for @tunnelHealthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get tunnelHealthExcellent;

  /// No description provided for @tunnelHealthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get tunnelHealthGood;

  /// No description provided for @tunnelHealthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get tunnelHealthFair;

  /// No description provided for @tunnelHealthDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get tunnelHealthDegraded;

  /// No description provided for @tunnelHealthFailing.
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get tunnelHealthFailing;

  /// No description provided for @tunnelHealthLatency.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get tunnelHealthLatency;

  /// No description provided for @tunnelHealthLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get tunnelHealthLoss;

  /// No description provided for @tunnelHealthJitter.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get tunnelHealthJitter;

  /// No description provided for @tunnelHealthUptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get tunnelHealthUptime;

  /// No description provided for @tunnelHealthReconnects.
  ///
  /// In en, this message translates to:
  /// **'Reconnects'**
  String get tunnelHealthReconnects;

  /// No description provided for @tunnelHealthTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get tunnelHealthTrend;

  /// No description provided for @tunnelHealthProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get tunnelHealthProtocol;

  /// No description provided for @tunnelHealthThroughput.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get tunnelHealthThroughput;

  /// No description provided for @tunnelHealthCircuits.
  ///
  /// In en, this message translates to:
  /// **'Circuits'**
  String get tunnelHealthCircuits;

  /// No description provided for @tunnelHealthIp.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get tunnelHealthIp;

  /// No description provided for @tunnelHealthLastProbeOk.
  ///
  /// In en, this message translates to:
  /// **'Last probe: {latency}ms — OK'**
  String tunnelHealthLastProbeOk(int latency);

  /// No description provided for @tunnelHealthLastProbeFailed.
  ///
  /// In en, this message translates to:
  /// **'Last probe failed: {error}'**
  String tunnelHealthLastProbeFailed(String error);

  /// No description provided for @tunnelHealthNoDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Tunnel is up but no data is flowing'**
  String get tunnelHealthNoDataWarning;

  /// No description provided for @tunnelHealthMeasuringHealth.
  ///
  /// In en, this message translates to:
  /// **'Measuring health…'**
  String get tunnelHealthMeasuringHealth;

  /// No description provided for @tunnelHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'{tunnel} Health'**
  String tunnelHealthTitle(String tunnel);

  /// No description provided for @wireguardConfig.
  ///
  /// In en, this message translates to:
  /// **'WireGuard Config'**
  String get wireguardConfig;

  /// No description provided for @wireguardConfigHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a standard WireGuard config (INI format) or a wireguard:// URI. The app auto-detects the format.'**
  String get wireguardConfigHint;

  /// No description provided for @wireguardConfigInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid WireGuard config — check PrivateKey, PublicKey, and Endpoint.'**
  String get wireguardConfigInvalid;

  /// No description provided for @wireguardFormatStandard.
  ///
  /// In en, this message translates to:
  /// **'STANDARD'**
  String get wireguardFormatStandard;

  /// No description provided for @wireguardFormatUri.
  ///
  /// In en, this message translates to:
  /// **'URI'**
  String get wireguardFormatUri;

  /// No description provided for @wireguardConvertToUri.
  ///
  /// In en, this message translates to:
  /// **'Convert to URI'**
  String get wireguardConvertToUri;

  /// No description provided for @wireguardConvertToStandard.
  ///
  /// In en, this message translates to:
  /// **'Convert to Standard'**
  String get wireguardConvertToStandard;

  /// No description provided for @wireguardConnected.
  ///
  /// In en, this message translates to:
  /// **'WireGuard Connected'**
  String get wireguardConnected;

  /// No description provided for @autoReconnectWireGuard.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect WireGuard'**
  String get autoReconnectWireGuard;

  /// No description provided for @logSourceWireGuard.
  ///
  /// In en, this message translates to:
  /// **'WireGuard'**
  String get logSourceWireGuard;

  /// No description provided for @torViaWireGuard.
  ///
  /// In en, this message translates to:
  /// **'Via WireGuard (Tor-over-WireGuard)'**
  String get torViaWireGuard;

  /// No description provided for @psiphonWireGuardUpstream.
  ///
  /// In en, this message translates to:
  /// **'WireGuard (SOCKS upstream)'**
  String get psiphonWireGuardUpstream;

  /// No description provided for @sstpWireGuardUpstream.
  ///
  /// In en, this message translates to:
  /// **'WireGuard (SOCKS upstream)'**
  String get sstpWireGuardUpstream;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
