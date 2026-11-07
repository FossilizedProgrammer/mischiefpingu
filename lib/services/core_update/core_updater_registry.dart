// lib/services/core_update/core_updater_registry.dart

import 'core_update_ffvpn.dart';
import 'core_update_lantern.dart';
import 'core_update_npv.dart';
import 'core_update_aether.dart';
import 'core_update_psiphon.dart';
import 'core_update_sstp.dart';
import 'core_update_sunandlion.dart';
import 'core_update_tor.dart';
import 'wireguard/wireguard_updater.dart';
import 'core_updater.dart';
import 'core_updater_adapters.dart';

class CoreUpdaterRegistry {
  final Map<String, CoreUpdater> _updaters;

  CoreUpdaterRegistry({
    required AetherUpdater aether,
    required TorUpdater tor,
    required PsiphonUpdater psiphon,
    required SunAndLionUpdater sunAndLion,
    required SstpProxyUpdater sstp,
    required WireGuardUpdater wireguard,
    required WireGuardAwgUpdater wireguardAwg, // 🆕
    required FfvpnUpdater ffvpn,
    required LanternUpdater lantern, // 🆕
    required NpvUpdater npv, // 🆕
  }) : _updaters = {
          'aether': aetherAdapter(aether),
          'tor': torAdapter(tor),
          'psiphon': psiphonAdapter(psiphon),
          'sunandlion': sunAndLionAdapter(sunAndLion),
          'sstp': sstpAdapter(sstp),
          'wireguard': wireGuardAdapter(wireguard),
          'wireguard-awg': wireGuardAwgAdapter(wireguardAwg), // 🆕
          'ffvpn': ffvpnAdapter(ffvpn),
          'lantern': lanternAdapter(lantern), // 🆕
          'npv': npvAdapter(npv), // 🆕
        };

  CoreUpdater? byId(String coreId) => _updaters[coreId];
}
