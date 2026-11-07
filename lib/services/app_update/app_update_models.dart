library;

class AppUpdateSource {
  final String owner;
  final String repo;

  /// نسخه فعلی برنامه — از pubspec.
  final String currentVersion;

  /// فایل asset مورد انتظار برای پلتفرم فعلی.
  /// اگر null باشد، اولین asset با پسوند آرشیو انتخاب می‌شود.
  final String? preferredAssetPattern;

  const AppUpdateSource({
    required this.owner,
    required this.repo,
    required this.currentVersion,
    this.preferredAssetPattern,
  });
}

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String downloadUrl;
  final String releaseNotes;
  final int downloadSizeBytes;
  final String assetName;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.downloadSizeBytes,
    required this.assetName,
  });

  static const AppUpdateInfo none = AppUpdateInfo(
    currentVersion: '',
    latestVersion: '',
    hasUpdate: false,
    downloadUrl: '',
    releaseNotes: '',
    downloadSizeBytes: 0,
    assetName: '',
  );
}
