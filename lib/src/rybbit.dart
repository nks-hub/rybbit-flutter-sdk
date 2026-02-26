import 'dart:async';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config.dart';
import 'models/event_type.dart';
import 'models/track_payload.dart';
import 'models/identify_payload.dart';
import 'services/http_client.dart';
import 'services/device_info.dart';
import 'services/queue.dart';
import 'services/offline_store.dart';
import 'services/session.dart';
import 'services/lifecycle.dart';
import 'services/logger.dart';
import 'services/error_handler.dart';
import 'services/icon_uploader.dart';

enum RybbitState { idle, initializing, ready, disposed }

class Rybbit {
  Rybbit._();

  static Rybbit? _instance;
  static Rybbit get instance {
    if (_instance == null) {
      throw RybbitInitException('Rybbit.init() must be called first');
    }
    return _instance!;
  }

  static bool get isInitialized =>
      _instance != null && _instance!._state == RybbitState.ready;

  late RybbitConfig _config;
  late RybbitLogger _logger;
  late RybbitTransport _transport;
  late DeviceData _deviceData;
  late SessionTracker _session;
  late EventQueue _preInitQueue;
  OfflineEventStore? _offlineStore;
  RybbitLifecycleObserver? _lifecycleObserver;
  RybbitErrorHandler? _errorHandler;
  Timer? _flushTimer;
  final List<TrackPayload> _buffer = [];
  String? _userId;
  final Map<String, dynamic> _globalProperties = {};
  RybbitState _state = RybbitState.idle;
  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;

  RybbitState get state => _state;

  static Future<void> init({
    required String host,
    required String siteId,
    bool debug = false,
    bool dryRun = false,
    bool autoTrackLifecycle = true,
    bool autoTrackErrors = true,
    bool autoUploadIcon = true,
    String? iconAssetPath,
    String? userAgent,
    Map<String, dynamic> globalProperties = const {},
    int maxOfflineEvents = 1000,
    int offlineTtlDays = 7,
    int maxRetries = 3,
    Duration flushInterval = const Duration(seconds: 10),
    int flushThreshold = 20,
    // For testing: injectable dependencies
    RybbitTransport? transport,
    DeviceInfoProvider? deviceInfoProvider,
    OfflineEventStore? offlineStore,
  }) async {
    if (_instance != null && _instance!._state == RybbitState.ready) {
      return;
    }

    final rybbit = Rybbit._();
    _instance = rybbit;
    rybbit._state = RybbitState.initializing;

    rybbit._config = RybbitConfig(
      host: host,
      siteId: siteId,
      debug: debug,
      dryRun: dryRun,
      autoTrackLifecycle: autoTrackLifecycle,
      autoTrackErrors: autoTrackErrors,
      autoUploadIcon: autoUploadIcon,
      iconAssetPath: iconAssetPath,
      globalProperties: globalProperties,
      maxOfflineEvents: maxOfflineEvents,
      offlineTtlDays: offlineTtlDays,
      maxRetries: maxRetries,
      flushInterval: flushInterval,
      flushThreshold: flushThreshold,
    );

    rybbit._logger = RybbitLogger(debug: debug, dryRun: dryRun);
    rybbit._logger.log('Initializing SDK for site: $siteId');
    rybbit._preInitQueue = EventQueue();
    rybbit._globalProperties.addAll(globalProperties);
    rybbit._session = SessionTracker();
    final httpClient = RybbitHttpClient(host: host)..debug = debug;
    rybbit._transport = transport ?? httpClient;

    final provider = deviceInfoProvider ?? DeviceInfoService();
    var deviceData = await provider.collect();
    if (userAgent != null) {
      deviceData = deviceData.withUserAgent(userAgent);
    }
    rybbit._deviceData = deviceData;
    rybbit._logger.log('Device: ${rybbit._deviceData.userAgent}');

    if (!dryRun) {
      if (offlineStore != null) {
        rybbit._offlineStore = offlineStore;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        Hive.init(appDir.path);
        rybbit._offlineStore = HiveOfflineStore(
          maxEvents: maxOfflineEvents,
          ttlDays: offlineTtlDays,
          maxRetries: maxRetries,
        );
      }
      await rybbit._offlineStore!.init();

      final connectivity = Connectivity();
      rybbit._connectivitySubscription =
          connectivity.onConnectivityChanged.listen((results) {
        final wasOnline = rybbit._isOnline;
        rybbit._isOnline = results.any((r) => r != ConnectivityResult.none);
        if (!wasOnline && rybbit._isOnline) {
          rybbit._logger.log('Connectivity restored, draining offline store');
          rybbit._drainOfflineStore();
        }
      });
    }

    rybbit._flushTimer = Timer.periodic(
      rybbit._config.flushInterval,
      (_) => rybbit._flushBuffer(),
    );

    rybbit._state = RybbitState.ready;

    final queued = rybbit._preInitQueue.drain();
    for (final item in queued) {
      rybbit._enqueue(item.payload);
    }

    if (autoTrackLifecycle) {
      rybbit._lifecycleObserver = RybbitLifecycleObserver(
        onLifecycleEvent: (eventName) => rybbit.event(eventName),
        onFlushRequested: () => rybbit._flushBuffer(),
      );
      rybbit._lifecycleObserver!.register();
      rybbit.event('app_open');
    }

    if (autoTrackErrors) {
      rybbit._errorHandler = RybbitErrorHandler(
        onError: (error, stackTrace) => rybbit.trackError(error, stackTrace),
      );
      rybbit._errorHandler!.install();
      rybbit._logger.log('Auto error tracking enabled');
    }

    if (autoUploadIcon && !dryRun) {
      // Fire-and-forget: don't block init on icon upload
      IconUploader(
        transport: rybbit._transport,
        logger: rybbit._logger,
        siteId: siteId,
        iconAssetPath: iconAssetPath,
      ).uploadIfMissing();
    }

    rybbit._logger.log('SDK ready');
  }

  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
    }
    _instance = null;
  }

  /// Wraps the app startup with [runZonedGuarded] for comprehensive error
  /// capture. Catches errors that occur outside Flutter's error handlers.
  ///
  /// Usage:
  /// ```dart
  /// void main() {
  ///   Rybbit.runApp(() async {
  ///     WidgetsFlutterBinding.ensureInitialized();
  ///     await Rybbit.init(host: 'https://...', siteId: '1');
  ///     runApp(const MyApp());
  ///   });
  /// }
  /// ```
  static void runApp(Future<void> Function() appRunner) {
    runZonedGuarded(
      () async {
        await appRunner();
      },
      (error, stackTrace) {
        if (_instance != null && _instance!._state == RybbitState.ready) {
          _instance!.trackError(error, stackTrace);
        }
      },
    );
  }

  // --- Core Tracking ---

  void screenView(String pathname, {String? title}) {
    _session.navigateTo(pathname, title: title);
    final payload = _buildPayload(
      type: EventType.pageview,
      pathname: pathname,
      pageTitle: title,
    );
    _track(payload);
    _logger.log('screenView: $pathname');
  }

  void event(String name, {Map<String, dynamic>? properties}) {
    final merged = _mergeProperties(properties);
    final payload = _buildPayload(
      type: EventType.customEvent,
      eventName: name,
      properties: merged.isNotEmpty ? merged : null,
    );
    _track(payload);
    _logger.log('event: $name', properties);
  }

  void trackError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final errorStr = error.toString();
    final props = <String, dynamic>{
      'message': errorStr.length > 500 ? errorStr.substring(0, 500) : errorStr,
    };
    if (stackTrace != null) {
      final stackStr = stackTrace.toString();
      props['stack'] =
          stackStr.length > 2000 ? stackStr.substring(0, 2000) : stackStr;
    }
    if (context != null) props.addAll(context);

    final payload = _buildPayload(
      type: EventType.error,
      eventName: error.runtimeType.toString(),
      properties: props,
    );
    _track(payload);
    _logger.log('trackError: ${error.runtimeType}');
  }

  // --- User Identity ---

  void identify(String userId, {Map<String, dynamic>? traits}) {
    _userId = userId;
    _logger.log('identify: $userId');
    if (_config.dryRun) return;

    _transport.sendIdentify(IdentifyPayload(
      siteId: _config.siteId,
      userId: userId,
      traits: traits,
      isNewIdentify: true,
    ));
  }

  void setTraits(Map<String, dynamic> traits) {
    if (_userId == null) {
      _logger.warn('setTraits called without identify()');
      return;
    }
    if (_config.dryRun) return;

    _transport.sendIdentify(IdentifyPayload(
      siteId: _config.siteId,
      userId: _userId!,
      traits: traits,
      isNewIdentify: false,
    ));
  }

  void clearUserId() {
    _userId = null;
    _logger.log('clearUserId');
  }

  String? getUserId() => _userId;

  // --- Global Properties ---

  void setGlobalProperty(String key, dynamic value) {
    _globalProperties[key] = value;
  }

  void removeGlobalProperty(String key) {
    _globalProperties.remove(key);
  }

  // --- Private ---

  TrackPayload _buildPayload({
    required EventType type,
    String? pathname,
    String? pageTitle,
    String? eventName,
    Map<String, dynamic>? properties,
  }) {
    return TrackPayload(
      type: type,
      siteId: _config.siteId,
      hostname: _deviceData.appName.isNotEmpty ? _deviceData.appName : _deviceData.packageName,
      pathname: pathname ?? _session.currentScreen ?? '/',
      screenWidth: _deviceData.screenWidth,
      screenHeight: _deviceData.screenHeight,
      language: _deviceData.language,
      pageTitle: pageTitle ?? _session.currentTitle,
      referrer: _session.referrer,
      userId: _userId,
      userAgent: _deviceData.userAgent,
      eventName: eventName,
      properties: properties,
      appVersion: _deviceData.appVersion,
      deviceModel: _deviceData.deviceModel,
    );
  }

  Map<String, dynamic> _mergeProperties(Map<String, dynamic>? eventProps) {
    final merged = <String, dynamic>{..._globalProperties};
    if (eventProps != null) merged.addAll(eventProps);
    return merged;
  }

  void _track(TrackPayload payload) {
    if (_state != RybbitState.ready) {
      _preInitQueue.enqueue(payload);
      return;
    }
    _enqueue(payload);
  }

  void _enqueue(TrackPayload payload) {
    if (_config.dryRun) {
      _logger.log(
          '[DRY-RUN] Would send: ${payload.type.value}', payload.toJson());
      return;
    }
    _buffer.add(payload);
    if (_buffer.length >= _config.flushThreshold) {
      _flushBuffer();
    }
  }

  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty) return;
    final batch = List<TrackPayload>.from(_buffer);
    _buffer.clear();

    for (final payload in batch) {
      if (_isOnline) {
        final success = await _transport.sendEvent(payload);
        if (!success && _offlineStore != null) {
          await _offlineStore!.add(payload);
          _logger.warn('Event failed, moved to offline store');
        }
      } else if (_offlineStore != null) {
        await _offlineStore!.add(payload);
        _logger.log('Offline, event stored locally');
      }
    }
  }

  Future<void> _drainOfflineStore() async {
    if (_offlineStore == null) return;
    final events = await _offlineStore!.getAll();
    if (events.isEmpty) return;
    _logger.log('Draining ${events.length} offline events');

    await _offlineStore!.clear();
    for (final event in events) {
      final success = await _transport.sendEvent(event.payload);
      if (!success) {
        event.retryCount++;
        if (event.retryCount < _config.maxRetries) {
          await _offlineStore!.add(event.payload);
        } else {
          _logger.warn('Event discarded after ${_config.maxRetries} retries');
        }
      }
    }
  }

  Future<void> dispose() async {
    _state = RybbitState.disposed;
    _flushTimer?.cancel();
    _lifecycleObserver?.unregister();
    _errorHandler?.uninstall();
    _connectivitySubscription?.cancel();
    await _flushBuffer();
    if (_offlineStore != null) {
      await _offlineStore!.close();
    }
    _logger.log('SDK disposed');
  }
}
