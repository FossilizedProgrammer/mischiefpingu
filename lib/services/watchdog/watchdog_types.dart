library;

/// نتیجهٔ یک probe.
enum ProbeResult { alive, dead, skipped }

/// نتیجهٔ acquireRecoveryLease.
class RecoveryLeaseResult {
  final bool granted;
  final String? blockReason;
  final RecoveryLeaseHandle? lease;

  const RecoveryLeaseResult({
    required this.granted,
    this.blockReason,
    this.lease,
  });

  const RecoveryLeaseResult.denied(String reason)
      : granted = false,
        blockReason = reason,
        lease = null;

  void release() {
    lease?.release();
  }
}

abstract class RecoveryLeaseHandle {
  void release();
}
