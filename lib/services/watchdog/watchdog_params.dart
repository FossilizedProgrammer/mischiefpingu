// lib/services/watchdog/watchdog_params.dart
//
// ═══════════════════════════════════════════════════════════════
//  WatchdogParams — پارامترهای ثابت یک watchdog
//  (تفکیک شده از tunnel_watchdog.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'watchdog_config.dart';

class WatchdogParams {
  final String name;
  final int socksPort;
  final Duration interval;
  final int maxFailures;
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;
  final String probeHost;
  final int probePort;
  final bool doHttpProbe;

  const WatchdogParams({
    required this.name,
    required this.socksPort,
    this.interval = WatchdogConfig.psiphonInterval,
    this.maxFailures = WatchdogConfig.maxFailures,
    this.connectTimeout = WatchdogConfig.connectTimeout,
    this.socksTimeout = WatchdogConfig.socksTimeout,
    this.httpProbeTimeout = WatchdogConfig.httpProbeTimeout,
    this.probeHost = '8.8.8.8',
    this.probePort = 80,
    this.doHttpProbe = false,
  });
}
