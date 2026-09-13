import 'package:flutter/material.dart';
import '../../services/process_service.dart';
import 'snackbar_mixin.dart';

/// منطق dispatch کردن SnackBarها بر اساس وضعیت ProcessService.
void dispatchPendingSnackBars(
  BuildContext context,
  ProcessService processService,
  SnackBarMixin mixin,
) {
  // Binary missing
  final binaryMissing = processService.pendingBinaryMissingMessage;
  if (binaryMissing != null && binaryMissing != mixin.lastShownBinaryMissing) {
    mixin.lastShownBinaryMissing = binaryMissing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showBinaryMissingSnackBar(binaryMissing);
        processService.clearBinaryMissingMessage();
      }
    });
  }
  if (binaryMissing == null) mixin.lastShownBinaryMissing = null;

  // Port conflict
  final portConflict = processService.pendingPortConflictMessage;
  if (portConflict != null && portConflict != mixin.lastShownPortConflict) {
    mixin.lastShownPortConflict = portConflict;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showPortConflictSnackBar(portConflict);
        processService.clearPortConflictMessage();
      }
    });
  }
  if (portConflict == null) mixin.lastShownPortConflict = null;

  // Psiphon protocol
  final pending = processService.pendingProtocolNotification;
  final pendingBinary = processService.pendingProtocolBinary;
  if (pending != null && pending != mixin.lastShownProtocol) {
    mixin.lastShownProtocol = pending;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showProtocolSnackBar(pending, pendingBinary);
        processService.clearPendingProtocolNotification();
      }
    });
  }
  if (!processService.isPsiphonConnected) mixin.lastShownProtocol = null;

  // Aether protocol
  final pendingAether = processService.pendingAetherProtocolNotification;
  if (pendingAether != null && pendingAether != mixin.lastShownAetherProtocol) {
    mixin.lastShownAetherProtocol = pendingAether;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showAetherProtocolSnackBar(pendingAether);
        processService.clearPendingAetherProtocolNotification();
      }
    });
  }
  if (!processService.isAetherRunning) {
    mixin.lastShownAetherProtocol = null;
  }

  // Tor transport
  final pendingTor = processService.pendingTorNotification;
  final pendingTorDetail = processService.pendingTorTransportDetail;
  if (pendingTor != null && pendingTor != mixin.lastShownTorTransport) {
    mixin.lastShownTorTransport = pendingTor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showTorTransportSnackBar(pendingTor, pendingTorDetail ?? '');
        processService.clearPendingTorNotification();
      }
    });
  }
  if (!processService.isTorConnected) mixin.lastShownTorTransport = null;

  // ─── SSTP ───
  final pendingSstp = processService.pendingSstpNotification;
  if (pendingSstp != null && pendingSstp != mixin.lastShownSstpServer) {
    mixin.lastShownSstpServer = pendingSstp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        mixin.showSstpConnectedSnackBar(pendingSstp);
        processService.clearPendingSstpNotification();
      }
    });
  }
  if (!processService.isSstpConnected) mixin.lastShownSstpServer = null;
}
