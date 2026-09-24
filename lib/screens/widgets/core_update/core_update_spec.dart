// lib/screens/widgets/core_update/core_update_spec.dart

library;

enum CoreKind {
  aether,
  tor,
  psiphon,
  sunandlion,
  sstp,
  wireguard,
  wireguardAwg, // 🆕
}

class CoreUpdateSpec {
  final CoreKind kind;
  final String displayName;
  final String? note;
  final String? updateLabelWhenMissing;

  const CoreUpdateSpec({
    required this.kind,
    required this.displayName,
    this.note,
    this.updateLabelWhenMissing,
  });
}

const List<CoreUpdateSpec> coreUpdateSpecs = [
  CoreUpdateSpec(kind: CoreKind.aether, displayName: 'Aether'),
  CoreUpdateSpec(kind: CoreKind.tor, displayName: 'Tor'),
  CoreUpdateSpec(
    kind: CoreKind.psiphon,
    displayName: 'Psiphon (official)',
    note: 'Official binary from Psiphon-Labs.',
  ),
  CoreUpdateSpec(
    kind: CoreKind.sunandlion,
    displayName: 'SunAndLion Psiphon Core',
    note: 'Unofficial Psiphon fork by ssmirr — required for fronting mode.',
  ),
  CoreUpdateSpec(
    kind: CoreKind.sstp,
    displayName: 'SSTP Proxy',
    note: 'SSTP client from FossilizedProgrammer/sstp-proxy.',
  ),
  CoreUpdateSpec(
    kind: CoreKind.wireguard,
    displayName: 'WireGuard (wireproxy)',
    note: 'Userspace WireGuard client from windtf/wireproxy.',
  ),
  // 🆕 هستهٔ دوم WireGuard
  CoreUpdateSpec(
    kind: CoreKind.wireguardAwg,
    displayName: 'WireGuard Amnezia (wireproxy-awg)',
    note: 'AmneziaWG userspace client from artem-russkikh/wireproxy-awg. '
        'Required for the "Amnezia" core type.',
  ),
];
