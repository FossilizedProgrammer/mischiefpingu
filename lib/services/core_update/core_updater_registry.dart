// lib/services/core_update/core_updater_registry.dart
//
// ═══════════════════════════════════════════════════════════════
//  CoreUpdaterRegistry — نگاشت coreId → CoreUpdater
//  (تفکیک شده از core_update_service.dart)
//
//  ⚠️ نکته: adapterها interface مشترک CoreUpdater رو با امضای
//  یکسان پیاده می‌کنن، ولی هر updater داخلی امضای خودش رو داره.
//  اینجا فقط ترجمه انجام می‌شه.
// ═══════════════════════════════════════════════════════════════
library;

import '../core_update_models.dart';
import 'core_update_aether.dart';
import 'core_update_psiphon.dart';
import 'core_update_sstp.dart';
import 'core_update_sunandlion.dart';
import 'core_update_tor.dart';
import 'core_updater.dart';

// ═══════════════════════════════════════════════════════════════
//  Aether
// ═══════════════════════════════════════════════════════════════
class _AetherAdapter implements CoreUpdater {
  final AetherUpdater inner;
  _AetherAdapter(this.inner);

  @override
  String get coreId => 'aether';

  @override
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  }) =>
      inner.check(proxy, installed: installed);

  @override
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      inner.update(
        info,
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}

// ═══════════════════════════════════════════════════════════════
//  Tor
// ═══════════════════════════════════════════════════════════════
class _TorAdapter implements CoreUpdater {
  final TorUpdater inner;
  _TorAdapter(this.inner);

  @override
  String get coreId => 'tor';

  @override
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  }) =>
      inner.check(proxy, installed: installed);

  @override
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      inner.update(
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}

// ═══════════════════════════════════════════════════════════════
//  Psiphon
// ═══════════════════════════════════════════════════════════════
class _PsiphonAdapter implements CoreUpdater {
  final PsiphonUpdater inner;
  _PsiphonAdapter(this.inner);

  @override
  String get coreId => 'psiphon';

  @override
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  }) =>
      inner.check(
        proxy,
        installed: installed,
        psiphonBinSha: psiphonBinSha,
      );

  @override
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      inner.update(
        info,
        installed: installed,
        proxy: proxy,
        psiphonBinSha: psiphonBinSha,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}

// ═══════════════════════════════════════════════════════════════
//  SunAndLion
// ═══════════════════════════════════════════════════════════════
class _SunAndLionAdapter implements CoreUpdater {
  final SunAndLionUpdater inner;
  _SunAndLionAdapter(this.inner);

  @override
  String get coreId => 'sunandlion';

  @override
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  }) =>
      inner.check(proxy, installed: installed);

  @override
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      inner.update(
        info,
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}

// ═══════════════════════════════════════════════════════════════
//  SSTP
// ═══════════════════════════════════════════════════════════════
class _SstpAdapter implements CoreUpdater {
  final SstpProxyUpdater inner;
  _SstpAdapter(this.inner);

  @override
  String get coreId => 'sstp';

  @override
  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    String psiphonBinSha = '',
  }) =>
      inner.check(proxy, installed: installed);

  @override
  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    String psiphonBinSha = '',
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      inner.update(
        info,
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}

// ═══════════════════════════════════════════════════════════════
//  Registry
// ═══════════════════════════════════════════════════════════════
class CoreUpdaterRegistry {
  final Map<String, CoreUpdater> _updaters;

  CoreUpdaterRegistry({
    required AetherUpdater aether,
    required TorUpdater tor,
    required PsiphonUpdater psiphon,
    required SunAndLionUpdater sunAndLion,
    required SstpProxyUpdater sstp,
  }) : _updaters = {
          'aether': _AetherAdapter(aether),
          'tor': _TorAdapter(tor),
          'psiphon': _PsiphonAdapter(psiphon),
          'sunandlion': _SunAndLionAdapter(sunAndLion),
          'sstp': _SstpAdapter(sstp),
        };

  CoreUpdater? byId(String coreId) => _updaters[coreId];
}
