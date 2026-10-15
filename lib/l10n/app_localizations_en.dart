// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mischief Pingu';

  @override
  String get appSubtitle =>
      'Unofficial Psiphon client, Tor client, SSTP client, WireGuard client, Firefox VPN client, Lantern client';

  @override
  String get add => 'Add';

  @override
  String get addNew => 'Add new';

  @override
  String get allServers => 'All servers';

  @override
  String get any => 'Any';

  @override
  String get appearance => 'Appearance';

  @override
  String get appliedTop20Ips => 'Applied Top 20 IPs';

  @override
  String get appliedTop5Ips => 'Applied Top 5 IPs + SNI';

  @override
  String get applyTop20 => 'Apply Top 20';

  @override
  String get applyTop5 => 'Apply Top 5';

  @override
  String get authenticationOptional => 'Authentication (optional)';

  @override
  String get autoFindIpSni => 'Auto-find IP & SNI';

  @override
  String get autoFirstProxy => 'Auto (first running proxy)';

  @override
  String get autoFirstRunningProxy => 'Auto (first running proxy)';

  @override
  String get autoReconnectPsiphon => 'Auto-reconnect Psiphon';

  @override
  String get autoReconnectSstp => 'Auto-reconnect SSTP';

  @override
  String get autoReconnectTor => 'Auto-reconnect Tor';

  @override
  String get autoRefresh15Min => 'Auto-refresh every 15 minutes';

  @override
  String get autoRefreshSubtitle =>
      'Fetches new servers and re-checks health automatically';

  @override
  String get binaryNotFound => 'Binary Not Found';

  @override
  String get bridgePresets => 'Bridge presets (optional)';

  @override
  String get bridges =>
      'Bridges (one per line, custom supported — incl. webtunnel)';

  @override
  String get bridgesHint => 'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get cdnPreset => 'CDN Preset';

  @override
  String get cdnScanner => 'CDN IP Scanner';

  @override
  String get cdnScanModeQuick => 'Quick';

  @override
  String get cdnScanModeBalanced => 'Balanced';

  @override
  String get cdnScanModeDeep => 'Deep';

  @override
  String cdnScanModeQuickDesc(String samples, String max) {
    return 'Fast · $samples IPs per CIDR · up to $max total · ~1-2 min';
  }

  @override
  String cdnScanModeBalancedDesc(String samples, String max) {
    return 'Balanced · $samples IPs per CIDR · up to $max total · ~5-10 min';
  }

  @override
  String cdnScanModeDeepDesc(String max) {
    return 'Deep · full expansion · up to $max total · ~30-60 min';
  }

  @override
  String get cdnScoutTitle => 'Find working SNIs (recommended)';

  @override
  String cdnScoutProgress(String done, String total) {
    return 'Scouting $done/$total…';
  }

  @override
  String get cdnScoutHint =>
      'Discord/Reddit SNIs are blocked in Iran. Scout finds working ones.';

  @override
  String get cdnScoutButton => 'Scout';

  @override
  String cdnScanPreview(String lines, String ips) {
    return '$lines lines · $ips IP(s) will be scanned';
  }

  @override
  String cdnScanWarningsMore(String count) {
    return '…and $count more';
  }

  @override
  String cdnApplyIpsToPsiphon(String count) {
    return 'Apply $count IPs to Psiphon';
  }

  @override
  String cdnApplyIpsSnack(String count, String ip, String sni) {
    return '$count IPs → Psiphon\nFronting IP: $ip\nSNI: $sni';
  }

  @override
  String get cdnSendToPsiphon => 'Send to Psiphon';

  @override
  String get cdnSaveEnteredIps => 'Save entered IPs';

  @override
  String cdnIpsSavedSnack(String count, String total) {
    return '$count IPs saved ($total in list)';
  }

  @override
  String cdnCustomIpsSent(String count, String ip) {
    return '$count custom IPs → Psiphon (Fronting: $ip)';
  }

  @override
  String cdnResultSubtitle(String score, String reliability, String latency,
      String download, String sni) {
    return 'Score $score · Rel $reliability/5 · ${latency}ms · dl ${download}ms · $sni';
  }

  @override
  String get check => 'Check';

  @override
  String get checkHealth => 'Check health';

  @override
  String get checking => 'Checking…';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearLog => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get colorThemeSubtitle => 'Choose a color scheme for the entire app.';

  @override
  String get conduitWebrtc => 'Conduit (WebRTC Inproxy)';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting…';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copyAllToClipboard => 'Copy all';

  @override
  String get importFromClipboard => 'Import from clipboard';

  @override
  String get importedFromClipboard => 'Imported from clipboard';

  @override
  String get nothingToImport => 'Clipboard is empty';

  @override
  String get itemsAddedCount => 'Added items';

  @override
  String get copy => 'Copy';

  @override
  String get copyAllCsv => 'Copy all (CSV with details)';

  @override
  String get copyAllIpPort => 'Copy all (ip:port)';

  @override
  String get copyLog => 'Copy';

  @override
  String get coreUpdates => 'Core Updates';

  @override
  String get customIps => 'Custom IPs';

  @override
  String get delete => 'Delete';

  @override
  String get directNoProxy => 'Direct (no proxy)';

  @override
  String get directNoProxyOption => 'Direct (no proxy)';

  @override
  String get directNoUpstream => 'Direct (no upstream)';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get disconnectingTunnels => 'Disconnecting active tunnels…';

  @override
  String get download => 'Download';

  @override
  String get downloadVia => 'Download via';

  @override
  String get downloadViaSubtitle =>
      'Checks and downloads ride the selected proxy when direct access is filtered.';

  @override
  String get egressRegion => 'Egress region';

  @override
  String get enableLogging => 'Enable logging';

  @override
  String get enableLoggingSubtitle => 'When off, no new logs are collected';

  @override
  String get exitCountry => 'Exit country';

  @override
  String get exitCountryAny => 'Any (random)';

  @override
  String get fetch => 'Fetch';

  @override
  String get fetchVia => 'Fetch via';

  @override
  String get fetching => 'Fetching…';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get frontingAdvanced => 'Fronting (advanced, optional)';

  @override
  String get frontingIp => 'Fronting IP';

  @override
  String get httpHostHeader => 'HTTP Host Header (e.g. aparat.com, snapp.ir)';

  @override
  String get httpPort => 'HTTP port';

  @override
  String get installed => 'Installed';

  @override
  String get ipsCidrRanges => 'IPs / CIDR / Ranges';

  @override
  String get ipv4Only => 'IPv4 only';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageRussian => 'Русский';

  @override
  String get latest => 'Latest';

  @override
  String get lines => 'lines';

  @override
  String get listIsEmpty => 'List is empty';

  @override
  String get localProxyPorts => 'Local proxy ports';

  @override
  String get log => 'Log';

  @override
  String get logSourceFilter => 'Filter Log Sources';

  @override
  String get logSourcePsiphon => 'Psiphon';

  @override
  String get logSourceTor => 'Tor';

  @override
  String get logSourceSstp => 'SSTP';

  @override
  String get logSourceApp => 'App';

  @override
  String get logSourceSystem => 'System';

  @override
  String get manageList => 'Manage list (Add / Delete)';

  @override
  String get manualProxy => 'Manual proxy';

  @override
  String get manualProxyOption => 'Manual proxy';

  @override
  String get muteSounds => 'Mute sounds';

  @override
  String get muteSoundsSubtitle =>
      'Disable all penguin sounds (ouch / sigh / happy). The visual reactions still play.';

  @override
  String get noCustomIpsSaved => 'No custom IPs saved yet';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get noUpstreamDirect => 'No upstream (direct)';

  @override
  String get notInstalled => 'Not installed';

  @override
  String get notifications => 'Notifications';

  @override
  String get obfOff => 'Off';

  @override
  String get officialCore => 'official psiphon tunnel core';

  @override
  String get password => 'Password';

  @override
  String get passwordOptional => 'Password (optional)';

  @override
  String get port => 'Port';

  @override
  String portRangeError(int min, int max) {
    return 'Enter a port number from $min to $max';
  }

  @override
  String get preset1Subtitle =>
      'Uses the SunAndLion Psiphon Tunnel Core (Unofficial fork of Psiphon tunnel core).';

  @override
  String get preset1Title => '1 · Fronting (CDN). Best for heavy censorship.';

  @override
  String get preset2Subtitle =>
      'Uses Psiphon INPROXY-WEBRTC protocols via volunteer stations.';

  @override
  String get preset2Title =>
      '2 · Conduit (WebRTC Inproxy). Decentralized peer relays.';

  @override
  String get preset3Subtitle =>
      'Uses the official Psiphon Tunnel Core directly.';

  @override
  String get preset3Title =>
      '3 · Direct connection. Suitable for mild censorship.';

  @override
  String get profile => 'Profile';

  @override
  String get protocol => 'Protocol';

  @override
  String get proxyIp => 'Proxy IP';

  @override
  String get proxyType => 'Proxy type';

  @override
  String get psiphonConnectedVia => 'Psiphon Connected via';

  @override
  String get psiphonConnectionMode => 'Psiphon connection mode';

  @override
  String get psiphonSettings => 'Psiphon Settings';

  @override
  String get psiphonUpstream => 'Psiphon (SOCKS upstream)';

  @override
  String get save => 'Save';

  @override
  String get saveFoundIpsSni => 'Save found IPs & SNI automatically';

  @override
  String get scanMode => 'Scan mode';

  @override
  String get select => 'Select...';

  @override
  String get selectAll => 'Select all';

  @override
  String get server => 'Server';

  @override
  String get serverAddress => 'Server address';

  @override
  String get shareOnLan => 'Share on LAN (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphon => 'Share on LAN (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphonSubtitle =>
      'Forward SOCKS & HTTP ports on all interfaces via Dart';

  @override
  String get showLess => 'Show less';

  @override
  String get showLessSubtitle => 'Hide advanced settings & logs';

  @override
  String get showMore => 'Show more';

  @override
  String get showMoreSubtitle =>
      'Appearance, Psiphon, Tor, SSTP, WireGuard, Firefox VPN, Scanner, Updates, Log';

  @override
  String get sni => 'SNI';

  @override
  String get sniList => 'SNI list (one per line, order = priority)';

  @override
  String get socksPort => 'SOCKS port';

  @override
  String get sstpConnected => 'SSTP Connected';

  @override
  String get sstpSettings => 'SSTP Settings';

  @override
  String get sstpSocksUpstream => 'SSTP (SOCKS upstream)';

  @override
  String get start => 'Start';

  @override
  String get startScan => 'Start Scan';

  @override
  String get stop => 'Stop';

  @override
  String get stopHealthCheck => 'Stop';

  @override
  String get stopScan => 'Stop';

  @override
  String get sunandlionCore => 'sunandlion psiphon tunnel core';

  @override
  String get threads => 'Threads';

  @override
  String get tlsSni => 'TLS SNI (e.g. a248.e.akamai.net)';

  @override
  String get torBridge => 'Bridge (obfs4 / snowflake / custom)';

  @override
  String get torConnected => 'Tor Connected';

  @override
  String get torConnection => 'Tor connection';

  @override
  String get torDirect => 'Direct (no bridge, no upstream) — default';

  @override
  String get torManual => 'Manual proxy';

  @override
  String get torSettings => 'Tor Settings';

  @override
  String get torSocksUpstream => 'Tor (SOCKS upstream)';

  @override
  String get torUpstream => 'Tor (SOCKS upstream)';

  @override
  String get torViaPsiphon => 'Via Psiphon (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'Via SSTP (Tor-over-SSTP)';

  @override
  String get tunnelCore => 'Tunnel core';

  @override
  String get update => 'Update';

  @override
  String get upstream => 'Upstream';

  @override
  String get upstreamType => 'Upstream type';

  @override
  String get usableIps => 'Usable IPs (sorted by score)';

  @override
  String get useFronting => 'Use fronting (CDN)';

  @override
  String get userOptional => 'User (optional)';

  @override
  String get username => 'Username';

  @override
  String get verboseLogging => 'Verbose logging';

  @override
  String get verboseLoggingSubtitle =>
      'Enable detailed debug output from sstp-proxy';

  @override
  String get vpngateServers => 'VPN Gate SSTP Servers';

  @override
  String get working => 'Working';

  @override
  String get watchdog => 'Watchdog';

  @override
  String get watchdogEnabled => 'Enable watchdog';

  @override
  String get watchdogEnabledSubtitle =>
      'Automatically restart tunnels when they become unresponsive';

  @override
  String get watchdogSettings => 'Watchdog Settings';

  @override
  String get backToPresets => 'Back to presets';

  @override
  String get watchdogNetworkProfile => 'Network Profile';

  @override
  String get watchdogNetworkProfileSubtitle =>
      'Adjusts how aggressively the watchdog probes. Choose based on your network conditions.';

  @override
  String get watchdogProfileStable => 'Stable';

  @override
  String get watchdogProfileStableDesc =>
      'Good internet quality — strict probing, faster detection of failures.';

  @override
  String get watchdogProfileNormal => 'Normal';

  @override
  String get watchdogProfileNormalDesc =>
      'Balanced settings for most networks (default).';

  @override
  String get watchdogProfileHarsh => 'Harsh filtering';

  @override
  String get watchdogProfileHarshDesc =>
      'Heavy filtering or unstable network — lenient probing, fewer false restarts.';

  @override
  String get appUpdate => 'App Update';

  @override
  String get appUpdateChecking => 'Checking for updates...';

  @override
  String get appUpdateFailed => 'Update check failed';

  @override
  String get appUpdateSaveDialogTitle => 'Select where to save the update';

  @override
  String get appUpdateDownloading => 'Downloading update...';

  @override
  String get appUpdateDownloaded => 'Update downloaded successfully';

  @override
  String get appUpdateOpenFolder => 'Open Folder';

  @override
  String get appUpdateAvailable => 'Update Available';

  @override
  String get appUpdateCurrentVersion => 'Current Version';

  @override
  String get appUpdateLatestVersion => 'Latest Version';

  @override
  String get appUpdateReleaseNotes => 'Release Notes';

  @override
  String get appUpdateCheck => 'Check for Updates';

  @override
  String get appUpdateDownload => 'Download Update';

  @override
  String get appUpdateUpToDate => 'You are up to date';

  @override
  String get internetQuality => 'Internet Quality';

  @override
  String get internetQualityAvg => 'Avg';

  @override
  String get internetQualityDeep => 'Deep (5m)';

  @override
  String get internetQualityDegraded => 'Degraded';

  @override
  String get internetQualityDirectDetails => 'Direct quality details';

  @override
  String get internetQualityDns => 'DNS';

  @override
  String get internetQualityDown => 'Down';

  @override
  String get internetQualityExcellent => 'Excellent';

  @override
  String get internetQualityGood => 'Good';

  @override
  String get internetQualityHttps => 'HTTPS';

  @override
  String get internetQualityJitter => 'Jitter';

  @override
  String get internetQualityLastCheck => 'Last check';

  @override
  String get internetQualityLight => 'Light (15s)';

  @override
  String get internetQualityMax => 'Max';

  @override
  String get internetQualityMed => 'Med';

  @override
  String get internetQualityMin => 'Min';

  @override
  String get internetQualityMonitoring => 'Background monitoring';

  @override
  String get internetQualityNoResult => 'No result';

  @override
  String get internetQualityNormal => 'Normal (2m)';

  @override
  String get internetQualityNotTested => 'Not tested';

  @override
  String get internetQualityOff => 'Off';

  @override
  String get internetQualityP95 => 'P95';

  @override
  String get internetQualityQuality => 'Quality';

  @override
  String get internetQualitySnackbar => 'Internet:';

  @override
  String get internetQualityStatusFailing => 'Failing';

  @override
  String get internetQualityStatusOk => 'OK';

  @override
  String get internetQualityStatusPartial => 'Partial';

  @override
  String get internetQualityStatusSlow => 'Slow';

  @override
  String get internetQualityStatusUnknown => 'Unknown';

  @override
  String get internetQualityTcp => 'TCP';

  @override
  String get internetQualityTest => 'Test';

  @override
  String get internetQualityUnstable => 'Unstable';

  @override
  String get wireguardSettings => 'WireGuard Settings';

  @override
  String get wireguardCoreTitle => 'WireGuard Core';

  @override
  String get wireguardCoreDescription =>
      'Choose the WireGuard implementation. Amnezia adds obfuscation for heavy censorship.';

  @override
  String get wireguardCoreStandard => 'Standard (wireguard-go)';

  @override
  String get wireguardCoreAmnezia => 'Amnezia (wireguard-awg)';

  @override
  String get tunnelHealth => 'Tunnel Health';

  @override
  String get tunnelHealthProbeAll => 'Test all';

  @override
  String get tunnelHealthProbeAgain => 'Retest';

  @override
  String tunnelHealthNotRunning(String tunnel) {
    return '$tunnel is not running';
  }

  @override
  String get tunnelHealthNoTunnelRunning => 'No tunnel is running';

  @override
  String get tunnelHealthStopped => 'Stopped';

  @override
  String get tunnelHealthReachable => 'Reachable (probe OK)';

  @override
  String get tunnelHealthMeasuring => 'Measuring…';

  @override
  String get tunnelHealthExcellent => 'Excellent';

  @override
  String get tunnelHealthGood => 'Good';

  @override
  String get tunnelHealthFair => 'Fair';

  @override
  String get tunnelHealthDegraded => 'Degraded';

  @override
  String get tunnelHealthFailing => 'Failing';

  @override
  String get tunnelHealthLatency => 'Latency';

  @override
  String get tunnelHealthLoss => 'Loss';

  @override
  String get tunnelHealthJitter => 'Jitter';

  @override
  String get tunnelHealthUptime => 'Uptime';

  @override
  String get tunnelHealthReconnects => 'Reconnects';

  @override
  String get tunnelHealthTrend => 'Trend';

  @override
  String get tunnelHealthProtocol => 'Protocol';

  @override
  String get tunnelHealthThroughput => 'Throughput';

  @override
  String get tunnelHealthCircuits => 'Circuits';

  @override
  String get tunnelHealthIp => 'IP';

  @override
  String tunnelHealthLastProbeOk(int latency) {
    return 'Last probe: ${latency}ms — OK';
  }

  @override
  String tunnelHealthLastProbeFailed(String error) {
    return 'Last probe failed: $error';
  }

  @override
  String get tunnelHealthNoDataWarning => 'Tunnel is up but no data is flowing';

  @override
  String get tunnelHealthMeasuringHealth => 'Measuring health…';

  @override
  String tunnelHealthTitle(String tunnel) {
    return '$tunnel Health';
  }

  @override
  String get wireguardConfig => 'WireGuard Config';

  @override
  String get wireguardConfigHint =>
      'Paste a standard WireGuard config (INI format) or a wireguard:// URI. The app auto-detects the format.';

  @override
  String get wireguardConfigInvalid =>
      'Invalid WireGuard config — check PrivateKey, PublicKey, and Endpoint.';

  @override
  String get wireguardFormatStandard => 'STANDARD';

  @override
  String get wireguardFormatUri => 'URI';

  @override
  String get wireguardConvertToUri => 'Convert to URI';

  @override
  String get wireguardConvertToStandard => 'Convert to Standard';

  @override
  String get wireguardLoadConfFile => 'Load .conf file';

  @override
  String get wireguardConfFileLoaded => 'WireGuard config loaded from file';

  @override
  String get wireguardConfFileEmpty => 'The selected file is empty';

  @override
  String get wireguardConfFileReadError => 'Could not read the selected file';

  @override
  String get wireguardConnected => 'WireGuard Connected';

  @override
  String get autoReconnectWireGuard => 'Auto-reconnect WireGuard';

  @override
  String get logSourceWireGuard => 'WireGuard';

  @override
  String get torViaWireGuard => 'Via WireGuard (Tor-over-WireGuard)';

  @override
  String get psiphonWireGuardUpstream => 'WireGuard (SOCKS upstream)';

  @override
  String get sstpWireGuardUpstream => 'WireGuard (SOCKS upstream)';

  @override
  String get diagnosticsReport => 'Diagnostics Report';

  @override
  String get diagnosticsReportGenerate => 'Generate Report';

  @override
  String get diagnosticsReportCopy => 'Copy Report';

  @override
  String get diagnosticsReportSave => 'Save Report';

  @override
  String get diagnosticsReportGenerated => 'Report generated successfully';

  @override
  String get diagnosticsReportCopied => 'Report copied to clipboard';

  @override
  String diagnosticsReportSaved(String path) {
    return 'Report saved to: $path';
  }

  @override
  String get diagnosticsReportRedacted => 'Sensitive data has been redacted';

  @override
  String get diagnosticsReportPreview => 'Preview';

  @override
  String get diagnosticsReportClose => 'Close';

  @override
  String get diagnosticsReportGenerating => 'Generating report…';

  @override
  String get amneziaLinkDetected => 'Amnezia VPN link detected';

  @override
  String get amneziaLinkName => 'Name';

  @override
  String get amneziaLinkEndpoint => 'API Endpoint';

  @override
  String get amneziaLinkHint =>
      'Click \'Fetch Config\' to retrieve the real AmneziaWG configuration from the API.';

  @override
  String get amneziaFetch => 'Fetch Config';

  @override
  String get amneziaFetching => 'Fetching…';

  @override
  String get amneziaFetchSuccess =>
      'AmneziaWG configuration fetched successfully';

  @override
  String get amneziaFetchFailed => 'Failed to fetch AmneziaWG configuration';

  @override
  String get amneziaCoreRequired =>
      'AmneziaWG core required for vpn:// links. The app will auto-select it.';

  @override
  String get amneziaApiError => 'Amnezia API error';

  @override
  String get amneziaInvalidLink => 'Invalid vpn:// link format';

  @override
  String get bridgeScanner => 'Bridge Scanner';

  @override
  String get bridgeScannerDescription =>
      'Fetch and test Tor bridges (obfs4, webtunnel, snowflake, meek, conjure). Color-coded latency helps you pick the ones that actually work on your network.';

  @override
  String get bridgeLines => 'Bridge Lines (one per line)';

  @override
  String get bridgeLinesHint =>
      'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get bridgeThreads => 'Threads';

  @override
  String get bridgeStartScan => 'Start Scan';

  @override
  String get bridgeStopScan => 'Stop';

  @override
  String get bridgeResults => 'Results';

  @override
  String bridgeApplyWorking(int count) {
    return 'Apply Working ($count)';
  }

  @override
  String bridgeApplyWorkingSnackbar(int count) {
    return 'Applied $count working bridges to Tor settings';
  }

  @override
  String bridgeApplyWorkingRestarting(int count) {
    return 'Applied $count bridges — restarting Tor to apply';
  }

  @override
  String bridgeApplyWorkingTorNotRunning(int count) {
    return 'Applied $count bridges — start Tor to use them';
  }

  @override
  String bridgeFetch(String transport) {
    return 'Fetch $transport';
  }

  @override
  String get bridgeSaveWorking => 'Save Working';

  @override
  String get bridgeLoadSaved => 'Load Saved';

  @override
  String get bridgeRescanSaved => 'Rescan Saved';

  @override
  String get bridgeClearSaved => 'Clear Saved';

  @override
  String bridgeSavedCount(int count) {
    return 'Saved: $count';
  }

  @override
  String get bridgeNoSaved => 'No saved bridges yet';

  @override
  String get bridgeSavedBridges => 'Saved Bridges';

  @override
  String bridgeSaveSuccess(int count) {
    return '$count bridges saved';
  }

  @override
  String bridgeLoadedSuccess(int count) {
    return 'Loaded $count saved bridges';
  }

  @override
  String bridgeRescanStarted(int count) {
    return 'Rescanning $count saved bridges';
  }

  @override
  String get bridgeClearedSaved => 'Saved bridges cleared';

  @override
  String get bridgeNothingToSave => 'No working bridges to save';

  @override
  String get bridgeLoadFromScanner => 'Load from Bridge Scanner';

  @override
  String get bridgeLoadFromScannerSubtitle =>
      'Load saved working bridges from the Bridge Scanner section below';

  @override
  String get bridgeNoSavedInScanner => 'No saved bridges in Bridge Scanner yet';

  @override
  String get logSourceFfvpn => 'Firefox VPN';

  @override
  String get ffvpnSettings => 'Firefox VPN Settings';

  @override
  String get ffvpnGuideTitle => 'Firefox Account session token';

  @override
  String get ffvpnGuideIntro =>
      'This proxy uses the built-in IP Protection VPN of the Firefox browser (powered by Mozilla VPN). It needs the session token of your Firefox Account:';

  @override
  String get ffvpnGuideStep1 =>
      '1. Create a Firefox account or sign in inside the Firefox browser itself, so the browser stores your session.';

  @override
  String get ffvpnGuideStep2 =>
      '2. Open about:profiles in Firefox to find the root folder of your default profile.';

  @override
  String get ffvpnGuideStep3 =>
      '3. Open signedInUser.json in that folder and copy the value of accountData.sessionToken (a 64-character hex string), then paste it below.';

  @override
  String get ffvpnPathWindows =>
      'Windows: %APPDATA%\\Mozilla\\Firefox\\Profiles\\<profile>\\signedInUser.json';

  @override
  String get ffvpnPathLinux =>
      'Linux: ~/.mozilla/firefox/<profile>/signedInUser.json';

  @override
  String get ffvpnTokenLabel => 'Firefox Account session token';

  @override
  String get ffvpnTokenHint =>
      '64 hex characters — accountData.sessionToken from signedInUser.json';

  @override
  String get ffvpnPortSocks => 'SOCKS port';

  @override
  String get ffvpnPortHttp => 'HTTP port (0 = off)';

  @override
  String get ffvpnSniLabel => 'TLS SNI';

  @override
  String get ffvpnSniHint =>
      'Hostname sent in the TLS ClientHello to the Firefox proxy edge — leave empty to use the edge hostname';

  @override
  String get ffvpnUpstreamSection => 'Upstream SOCKS proxy';

  @override
  String get ffvpnUpstreamDesc =>
      'Firefox VPN first connects to this SOCKS5 hop and only then to the Firefox proxy edge. Use it when the edge is blocked or not directly reachable.';

  @override
  String get ffvpnUpstreamDirect => 'Direct (no upstream)';

  @override
  String get ffvpnUpstreamManual => 'Manual SOCKS5 proxy';

  @override
  String get ffvpnUpstreamPsiphon => 'Psiphon (SOCKS)';

  @override
  String get ffvpnUpstreamTor => 'Tor (SOCKS)';

  @override
  String get ffvpnUpstreamSstp => 'SSTP (SOCKS)';

  @override
  String get ffvpnUpstreamWireguard => 'WireGuard (SOCKS)';

  @override
  String ffvpnUpstreamVia(String name, String port) {
    return '$name is the upstream hop (SOCKS on 127.0.0.1:$port) and is started automatically if it is not running yet.';
  }

  @override
  String get ffvpnUpstreamManualNote =>
      'The hostname is always sent to the proxy, so DNS is resolved there.';

  @override
  String get ffvpnCountrySection => 'Exit country';

  @override
  String get ffvpnCountryAuto => 'Automatic (server-recommended)';

  @override
  String get ffvpnLoadCountries => 'Load country list';

  @override
  String get ffvpnCountriesLoading => 'Loading country list…';

  @override
  String get ffvpnCountriesEmpty =>
      'No countries loaded yet — press \"Load country list\".';

  @override
  String get ffvpnShowPremium => 'Show premium-only countries';

  @override
  String get ffvpnShowPremiumDesc =>
      'Countries locked behind a Mozilla VPN subscription are hidden by default, like in Firefox.';

  @override
  String get ffvpnPremiumTag => 'premium';

  @override
  String get ffvpnQuotaSection => 'Monthly bandwidth quota';

  @override
  String get ffvpnCheckQuota => 'Check quota';

  @override
  String get ffvpnQuotaLoading => 'Checking quota…';

  @override
  String ffvpnQuotaUsedOf(String used, String total, String percent) {
    return '$used of $total used ($percent%)';
  }

  @override
  String ffvpnQuotaLeft(String remaining) {
    return '$remaining remaining';
  }

  @override
  String ffvpnQuotaResets(String date) {
    return 'Resets on $date';
  }

  @override
  String get ffvpnQuotaUnlimited =>
      'Unlimited bandwidth — no monthly quota applies to this account.';

  @override
  String get ffvpnQuotaNoToken =>
      'Enter the session token above to check the quota.';

  @override
  String get ffvpnErrNotEntitled =>
      'This Firefox account has no Mozilla VPN subscription (HTTP 403) — the proxy service requires one.';

  @override
  String get ffvpnErrRegion =>
      'The service is not available in your region (HTTP 451).';

  @override
  String get ffvpnErrBadToken =>
      'The session token is invalid or expired. Sign in again in Firefox and copy a fresh token from signedInUser.json.';

  @override
  String get ffvpnErrQuota =>
      'Monthly bandwidth quota is exhausted — wait for the reset date.';

  @override
  String get ffvpnErrBinaryMissing =>
      'The ffvpn binary was not found in the app data folder.';

  @override
  String get ffvpnErrNetwork =>
      'Network error while reaching Mozilla — check your connection (a tunnel may be needed) and try again.';

  @override
  String get ffvpnErrOther => 'ffvpn error';

  @override
  String get logSourceLantern => 'Lantern';

  @override
  String get lanternSettings => 'Lantern Settings';

  @override
  String get lanternConnectionSection => 'Connection';

  @override
  String get lanternPortSocks => 'SOCKS port';

  @override
  String get lanternPortHttp => 'HTTP port (0 = off)';

  @override
  String get lanternUpstreamSection => 'Upstream proxy';

  @override
  String get lanternUpstreamDirect => 'None (direct)';

  @override
  String get lanternUpstreamManual => 'Manual proxy';

  @override
  String get lanternUpstreamPsiphon => 'Psiphon';

  @override
  String get lanternUpstreamTor => 'Tor';

  @override
  String get lanternUpstreamSstp => 'SSTP';

  @override
  String get lanternUpstreamWireguard => 'WireGuard';

  @override
  String get lanternUpstreamDesc =>
      'Connections to Lantern\'s servers (and, if none is reachable, your traffic as well) travel through this proxy — use it when Lantern\'s own server IPs are blocked.';

  @override
  String get lanternUpstreamManualNote =>
      'Accepted schemes: socks5://, socks5h://, http:// and https://.';

  @override
  String lanternUpstreamVia(String name, String port) {
    return '$name is the upstream hop (SOCKS on 127.0.0.1:$port) and is started automatically if it is not running yet.';
  }

  @override
  String get lanternToolsSection => 'Lantern tools';

  @override
  String get lanternToolsServers => 'Servers';

  @override
  String get lanternToolsRefreshServers => 'Refresh list';

  @override
  String get lanternToolsCheckServers => 'Check reachability';

  @override
  String get lanternServerReachable => 'Reachable';

  @override
  String get lanternServerUnreachable => 'Unreachable';

  @override
  String get lanternServerNotChecked => 'Not checked';

  @override
  String get lanternToolsAuth => 'Account';

  @override
  String get lanternEmailLabel => 'Email';

  @override
  String get lanternPasswordLabel => 'Password';

  @override
  String get lanternLoginBtn => 'Log in';

  @override
  String get lanternSignupBtn => 'Sign up';

  @override
  String get lanternLogoutBtn => 'Log out';

  @override
  String get lanternRunning => 'Running';
}
