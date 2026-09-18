library;

/// Result of a version check for one bundled network core.
class CoreUpdateInfo {
  final String coreId;
  final String displayName;
  final String installedVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String downloadUrl;
  final String releaseNotes;
  final int downloadSizeBytes;
  final String latestCommit;

  const CoreUpdateInfo({
    required this.coreId,
    required this.displayName,
    required this.installedVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.downloadSizeBytes,
    this.latestCommit = '',
  });
}

/// A downloaded update waiting to be applied on next startup
/// (used when the old binary is still running).
class PendingCoreUpdate {
  final String coreId;
  final String stagingPath;
  final String destPath;
  final String version;
  final DateTime createdAt;

  const PendingCoreUpdate({
    required this.coreId,
    required this.stagingPath,
    required this.destPath,
    required this.version,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'coreId': coreId,
    'stagingPath': stagingPath,
    'destPath': destPath,
    'version': version,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PendingCoreUpdate.fromJson(Map<String, dynamic> json) =>
      PendingCoreUpdate(
        coreId: json['coreId'] as String,
        stagingPath: json['stagingPath'] as String,
        destPath: json['destPath'] as String,
        version: json['version'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
