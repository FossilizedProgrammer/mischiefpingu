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
      'Unofficial Psiphon client, Aether client, Tor client, SSTP client';

  @override
  String get add => 'Add';

  @override
  String get addNew => 'Add new';

  @override
  String get aetherConnected => 'Aether Connected';

  @override
  String get aetherSettings => 'Aether Settings';

  @override
  String get aetherSocksUpstream => 'Aether (SOCKS upstream)';

  @override
  String get aetherUpstream => 'Aether (SOCKS upstream)';

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
  String get autoReconnectAether => 'Auto-reconnect Aether';

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
  String get both => 'Both';

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
  String get connectionMode => 'Connection Mode';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

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
  String get customEndpoint => 'Custom Endpoint (optional)';

  @override
  String get customEndpointHint => 'Leave empty for auto-scan';

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
  String get ipType => 'IP Type';

  @override
  String get ipsCidrRanges => 'IPs / CIDR / Ranges';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv4Only => 'IPv4 only';

  @override
  String get ipv6 => 'IPv6';

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
  String get localSocksPort => 'Local SOCKS port';

  @override
  String get log => 'Log';

  @override
  String get logSourceFilter => 'Filter Log Sources';

  @override
  String get logSourcePsiphon => 'Psiphon';

  @override
  String get logSourceAether => 'Aether';

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
  String get obfAggressive => 'Aggressive';

  @override
  String get obfBalanced => 'Balanced';

  @override
  String get obfFirewall => 'Firewall';

  @override
  String get obfGfw => 'GFW';

  @override
  String get obfLight => 'Light';

  @override
  String get obfOff => 'Off';

  @override
  String get obfuscation => 'Obfuscation (--noize)';

  @override
  String get officialCore => 'official psiphon tunnel core';

  @override
  String get password => 'Password';

  @override
  String get passwordOptional => 'Password (optional)';

  @override
  String get port => 'Port';

  @override
  String get preset1Subtitle =>
      'Uses the SunAndLion Psiphon Tunnel Core (Unofficial fork of Psiphon tunnel core).';

  @override
  String get preset1Title => '1 · Fronting (CDN). Best for heavy censorship.';

  @override
  String get preset2Subtitle =>
      'Uses official Psiphon Tunnel Core with Aether upstream.';

  @override
  String get preset2Title =>
      '2 · Aether traffic as upstream. Suitable when Aether works.';

  @override
  String get preset3Subtitle =>
      'Uses Psiphon INPROXY-WEBRTC protocols via volunteer stations.';

  @override
  String get preset3Title =>
      '3 · Conduit (WebRTC Inproxy). Decentralized peer relays.';

  @override
  String get preset4Subtitle =>
      'Uses the official Psiphon Tunnel Core directly.';

  @override
  String get preset4Title =>
      '4 · Direct connection. Suitable for mild censorship.';

  @override
  String get profile => 'Profile';

  @override
  String get profileAdaptive => 'Adaptive';

  @override
  String get profileAdaptiveDesc =>
      'Balance of speed and coverage — suitable for most networks';

  @override
  String get profileManual => 'Manual';

  @override
  String get profileManualDesc => 'All options manual — for advanced users';

  @override
  String get profilePatchy => 'Patchy signal';

  @override
  String get profilePatchyDesc =>
      'Unstable mobile data — harder and more resilient search';

  @override
  String get profileStrict => 'Strict network';

  @override
  String get profileStrictDesc =>
      'Restricted Wi-Fi or heavy filtering — fragment + masque-in-masque + noize gfw';

  @override
  String get protoGool => 'Gool (WARP-in-WARP)';

  @override
  String get protoMasque => 'MASQUE (HTTP/3 or HTTP/2)';

  @override
  String get protoMim => 'MIM (masque-in-masque)';

  @override
  String get protoWireguard => 'WireGuard';

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
  String get scanBalanced => 'Balanced';

  @override
  String get scanIronclad => 'Ironclad';

  @override
  String get scanMode => 'Scan mode';

  @override
  String get scanStealth => 'Stealth';

  @override
  String get scanThorough => 'Thorough';

  @override
  String get scanTurbo => 'Turbo';

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
      'Appearance, Aether, Psiphon, Tor, SSTP, WireGuard, Scanner, Updates, Log';

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
  String get torViaAether => 'Via Aether (Tor-over-Aether)';

  @override
  String get torViaPsiphon => 'Via Psiphon (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'Via SSTP (Tor-over-SSTP)';

  @override
  String get tryLastEndpointFirst => 'Try last successful endpoint first';

  @override
  String get tryLastEndpointFirstSubtitle =>
      'If enabled, will try the last working endpoint before scanning';

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
  String get aetherManualHint =>
      'Manual mode: Protocol, obfuscation, scan mode, and custom endpoint are fully under your control below.';

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
}
