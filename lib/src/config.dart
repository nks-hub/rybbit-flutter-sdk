class RybbitConfig {
  const RybbitConfig({
    required this.host,
    required this.siteId,
    this.debug = false,
    this.dryRun = false,
    this.autoTrackLifecycle = true,
    this.autoTrackErrors = true,
    this.autoUploadIcon = true,
    this.iconAssetPath,
    this.globalProperties = const {},
    this.maxOfflineEvents = 1000,
    this.offlineTtlDays = 7,
    this.maxRetries = 3,
    this.flushInterval = const Duration(seconds: 10),
    this.flushThreshold = 20,
  });

  final String host;
  final String siteId;
  final bool debug;
  final bool dryRun;
  final bool autoTrackLifecycle;
  final bool autoTrackErrors;

  /// When true, automatically uploads the app's launcher icon to Rybbit
  /// if the site doesn't have one yet.
  final bool autoUploadIcon;

  /// Custom asset path for the icon to upload. If null, uses the default
  /// Android/iOS launcher icon resolution logic.
  final String? iconAssetPath;

  final Map<String, dynamic> globalProperties;
  final int maxOfflineEvents;
  final int offlineTtlDays;
  final int maxRetries;
  final Duration flushInterval;
  final int flushThreshold;
}

class RybbitInitException implements Exception {
  RybbitInitException(this.message);
  final String message;

  @override
  String toString() => 'RybbitInitException: $message';
}
