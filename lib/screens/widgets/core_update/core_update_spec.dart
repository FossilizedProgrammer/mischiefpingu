library;

enum CoreKind { aether, tor, psiphon, sunandlion, sstp }

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
];
