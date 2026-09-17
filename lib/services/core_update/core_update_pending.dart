library;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_process_utils.dart';
import 'pending/tor_bundle_deferred_applier.dart';
import 'pending/aether_pt_deferred_applier.dart';

/// مدیریت آپدیت‌های معلق (deferred) که در startup بعدی اعمال می‌شوند.
class CoreUpdatePendingManager {
  final void Function(String)? log;
  final CoreUpdateProcessUtils processUtils;

  late final TorBundleDeferredApplier _torApplier =
      TorBundleDeferredApplier(processUtils: processUtils, log: log);

  late final AetherPtDeferredApplier _aetherApplier =
      AetherPtDeferredApplier(processUtils: processUtils, log: log);

  CoreUpdatePendingManager({this.log, required this.processUtils});

  void _log(String m) => log?.call(m);

  static const String _pendingUpdatesFile = 'pending_core_updates.json';

  Future<String> _getPendingUpdatesPath() async {
    final dataDir = await AppDataService.getDataDir();
    return p.join(dataDir, _pendingUpdatesFile);
  }

  Future<List<PendingCoreUpdate>> loadAll() async {
    try {
      final path = await _getPendingUpdatesPath();
      final file = File(path);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final list = jsonDecode(content) as List;
      return list
          .map((e) => PendingCoreUpdate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('⚠ Failed to load pending updates: $e');
      return [];
    }
  }

  Future<void> _saveAll(List<PendingCoreUpdate> updates) async {
    try {
      final path = await _getPendingUpdatesPath();
      final file = File(path);
      final content = jsonEncode(updates.map((e) => e.toJson()).toList());
      await file.writeAsString(content);
    } catch (e) {
      _log('⚠ Failed to save pending updates: $e');
    }
  }

  Future<void> add(PendingCoreUpdate update) async {
    final updates = await loadAll();
    updates.removeWhere((u) => u.coreId == update.coreId);
    updates.add(update);
    await _saveAll(updates);
    _log(
        '→ Pending update queued for ${update.coreId} (will apply on next startup)');
  }

  Future<void> applyAll() async {
    final updates = await loadAll();
    if (updates.isEmpty) return;
    _log('→ Found ${updates.length} pending core update(s) to apply…');
    final remaining = <PendingCoreUpdate>[];
    for (final update in updates) {
      try {
        final stagingFile = File(update.stagingPath);
        if (!await stagingFile.exists()) {
          _log('⚠ Staging file missing for ${update.coreId}, skipping');
          continue;
        }
        final destFile = File(update.destPath);
        bool canReplace = true;
        if (await destFile.exists()) {
          final isRunning =
              await processUtils.isProcessRunning(p.basename(update.destPath));
          if (isRunning) {
            _log('→ ${update.coreId} still running, keeping pending');
            remaining.add(update);
            canReplace = false;
          }
        }
        if (canReplace) {
          _log('→ Applying pending update for ${update.coreId}…');
          if (update.coreId == 'tor') {
            await _torApplier.apply(update);
          } else if (update.coreId == 'aether') {
            await _aetherApplier.apply(update);
          } else {
            await processUtils.replaceBinary(
                update.stagingPath, update.destPath);
          }
          _log('★ ${update.coreId} updated to ${update.version} (deferred)');
          await processUtils.updateExecutableDirBinary(
              update.coreId, update.stagingPath);
        }
      } catch (e) {
        _log('✗ Failed to apply pending update for ${update.coreId}: $e');
        remaining.add(update);
      }
    }
    await _saveAll(remaining);
  }
}
