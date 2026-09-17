library;

import 'dart:convert';
import '../models/settings_model.dart';
import 'process_service.dart';
import 'psiphon/psiphon_base_config_builder.dart';
import 'psiphon/psiphon_fronting_builder.dart';
import 'psiphon/psiphon_upstream_builder.dart';
import 'psiphon/psiphon_conduit_builder.dart';

class PsiphonConfigBuilder {
  final AppSettings settings;
  final List<String> ipList;
  final ProcessService processService;

  late final PsiphonBaseConfigBuilder _base;
  late final PsiphonFrontingBuilder _fronting;
  late final PsiphonUpstreamBuilder _upstream;
  late final PsiphonConduitBuilder _conduit;

  PsiphonConfigBuilder({
    required this.settings,
    required this.ipList,
    required this.processService,
  }) {
    _base = PsiphonBaseConfigBuilder(settings: settings);
    _fronting = PsiphonFrontingBuilder(
      settings: settings,
      ipList: ipList,
      processService: processService,
    );
    _upstream = PsiphonUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    _conduit = PsiphonConduitBuilder(
      settings: settings,
      processService: processService,
    );
  }

  String build() {
    final isConduit = settings.upstreamType == 3;
    final config = _base.build(isConduit: isConduit);

    if (settings.onlyIpv4) config["NetworkStack"] = "IPv4Only";

    _upstream.apply(config);

    if (isConduit && !_upstream.hasOverride) {
      _conduit.apply(config);
    } else if (_upstream.hasOverride) {
      config["InproxyEnabled"] = false;
      config["InproxyAllowClient"] = false;
    }

    _fronting.apply(config);

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);
    processService.addLog(
      '→ Psiphon config generated (${jsonStr.length} bytes)',
      source: LogSource.psiphon,
    );

    _logFinalState();

    return jsonStr;
  }

  void _logFinalState() {
    _conduit.logFinalState();

    if (settings.psiphonShareLan) {
      processService.addLog(
        '→ Psiphon Share on LAN: enabled (via Dart native forwarders)',
        source: LogSource.psiphon,
      );
    }
  }
}
