/// Configuration for the Rybbit SDK, passed to [Rybbit.init].
class RybbitConfig {
  const RybbitConfig({
    required this.host,
    required this.siteId,
    this.debug = false,
    this.dryRun = false,
    this.autoTrackLifecycle = true,
    this.autoTrackErrors = true,
    this.autoUploadIcon = false,
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

  /// When true, tries to upload the app's launcher icon to Rybbit if the site
  /// doesn't have one yet.
  ///
  /// Off by default, because the upload endpoint requires an authenticated site
  /// admin and a shipped app has no such session — the request comes back 403.
  /// Only worth enabling for internal builds running against an instance where
  /// the endpoint is reachable without auth. Otherwise upload the icon from
  /// Site Settings instead.
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

/// Thrown when [Rybbit.instance] is accessed before [Rybbit.init].
class RybbitInitException implements Exception {
  RybbitInitException(this.message);
  final String message;

  @override
  String toString() => 'RybbitInitException: $message';
}
