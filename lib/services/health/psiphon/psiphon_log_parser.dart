part of '../psiphon_health_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  PsiphonLogParser — parse کردن خطوط JSON لاگ Psiphon.
///
///  این کلاس مستقیماً روی state والد (PsiphonHealthSource) کار
///  می‌کند تا نیازی به getter/setter اضافی نباشد.
/// ═══════════════════════════════════════════════════════════════
class PsiphonLogParser {
  final PsiphonHealthSource source;

  const PsiphonLogParser({required this.source});

  // ─── الگوهای regex ───
  static final _noticeTypeRe = RegExp(r'"noticeType"\s*:\s*"([^"]+)"');
  static final _protocolRe = RegExp(r'"protocol"\s*:\s*"([^"]+)"');
  static final _dialLatencyRe = RegExp(r'"dialLatencyMs"\s*:\s*(\d+)');
  static final _upstreamBytesRe = RegExp(r'"upstreamBytes"\s*:\s*(\d+)');
  static final _downstreamBytesRe = RegExp(r'"downstreamBytes"\s*:\s*(\d+)');

  void feed(String line) {
    final noticeMatch = _noticeTypeRe.firstMatch(line);
    if (noticeMatch == null) return;
    final noticeType = noticeMatch.group(1) ?? '';

    switch (noticeType) {
      case 'ActiveTunnel':
        _handleActiveTunnel(line);
        break;
      case 'TunnelConnected':
        _handleTunnelConnected(line);
        break;
      case 'TunnelFailed':
        _handleTunnelFailed();
        break;
      case 'BytesTransferred':
        _handleBytesTransferred(line);
        break;
      default:
        break;
    }
  }

  void _handleActiveTunnel(String line) {
    final protocolMatch = _protocolRe.firstMatch(line);
    if (protocolMatch != null) {
      source.currentProtocol = protocolMatch.group(1);
    }
    source.successCount++;
    source.totalSamples++;
    source.consecutiveFailures = 0;
    source.currentLatencyMs = source.lastDialLatencyMs > 0
        ? source.lastDialLatencyMs
        : source.currentLatencyMs;
  }

  void _handleTunnelConnected(String line) {
    final dialMatch = _dialLatencyRe.firstMatch(line);
    if (dialMatch != null) {
      source.lastDialLatencyMs = int.tryParse(dialMatch.group(1) ?? '0') ?? 0;
    }
    final protocolMatch = _protocolRe.firstMatch(line);
    if (protocolMatch != null) {
      source.currentProtocol = protocolMatch.group(1);
    }
  }

  void _handleTunnelFailed() {
    source.consecutiveFailures++;
    source.totalFailures++;
    source.totalSamples++;
  }

  void _handleBytesTransferred(String line) {
    final upMatch = _upstreamBytesRe.firstMatch(line);
    final downMatch = _downstreamBytesRe.firstMatch(line);
    if (upMatch != null) {
      source.lastUpstreamBytes = int.tryParse(upMatch.group(1) ?? '0') ?? 0;
    }
    if (downMatch != null) {
      source.lastDownstreamBytes = int.tryParse(downMatch.group(1) ?? '0') ?? 0;
    }
  }
}
