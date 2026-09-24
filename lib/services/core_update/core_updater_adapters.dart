library;

import '../core_update_models.dart';
import 'core_update_aether.dart';
import 'core_update_psiphon.dart';
import 'core_update_sstp.dart';
import 'core_update_sunandlion.dart';
import 'core_update_tor.dart';
import 'wireguard/wireguard_updater.dart';
import 'core_updater.dart';

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
      inner.check(proxy, installed: installed, psiphonBinSha: psiphonBinSha);

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

class _WireGuardAdapter implements CoreUpdater {
  final WireGuardUpdater inner;
  _WireGuardAdapter(this.inner);

  @override
  String get coreId => 'wireguard';

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
//  🆕 _WireGuardAwgAdapter — adapter برای WireGuardAmnezia
// ═══════════════════════════════════════════════════════════════
class _WireGuardAwgAdapter implements CoreUpdater {
  final WireGuardAwgUpdater inner;
  _WireGuardAwgAdapter(this.inner);

  @override
  String get coreId => 'wireguard-awg';

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
//  factory functions
// ═══════════════════════════════════════════════════════════════

CoreUpdater aetherAdapter(AetherUpdater inner) => _AetherAdapter(inner);
CoreUpdater torAdapter(TorUpdater inner) => _TorAdapter(inner);
CoreUpdater psiphonAdapter(PsiphonUpdater inner) => _PsiphonAdapter(inner);
CoreUpdater sunAndLionAdapter(SunAndLionUpdater inner) =>
    _SunAndLionAdapter(inner);
CoreUpdater sstpAdapter(SstpProxyUpdater inner) => _SstpAdapter(inner);
CoreUpdater wireGuardAdapter(WireGuardUpdater inner) =>
    _WireGuardAdapter(inner);

CoreUpdater wireGuardAwgAdapter(WireGuardAwgUpdater inner) =>
    _WireGuardAwgAdapter(inner);
