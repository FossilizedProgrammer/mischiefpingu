library;

import 'core_update_aether.dart';
import 'core_update_psiphon.dart';
import 'core_update_sstp.dart';
import 'core_update_sunandlion.dart';
import 'core_update_tor.dart';
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
  }) : _updaters = {
         'aether': aetherAdapter(aether),
         'tor': torAdapter(tor),
         'psiphon': psiphonAdapter(psiphon),
         'sunandlion': sunAndLionAdapter(sunAndLion),
         'sstp': sstpAdapter(sstp),
       };

  CoreUpdater? byId(String coreId) => _updaters[coreId];
}
