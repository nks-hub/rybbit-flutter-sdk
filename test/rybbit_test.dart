import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/src/services/http_client.dart';
import 'package:rybbit_flutter/src/services/device_info.dart';
import 'package:rybbit_flutter/src/services/offline_store.dart';

class MockTransport implements RybbitTransport {
  final List<TrackPayload> sentEvents = [];
  final List<IdentifyPayload> sentIdentifies = [];
  bool shouldFail = false;

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    sentEvents.add(payload);
    return !shouldFail;
  }

  @override
  Future<bool> sendIdentify(IdentifyPayload payload) async {
    sentIdentifies.add(payload);
    return !shouldFail;
  }
}

class MockDeviceInfo implements DeviceInfoProvider {
  @override
  Future<DeviceData> collect() async => const DeviceData(
        appName: 'TestApp',
        packageName: 'com.test.app',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'Test',
        osVersion: '1.0',
        deviceModel: 'TestDevice',
        screenWidth: 1080,
        screenHeight: 2400,
        language: 'cs-CZ',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTransport mockTransport;
  late HiveOfflineStore offlineStore;

  setUp(() async {
    await Rybbit.reset();
    mockTransport = MockTransport();
    final ts = DateTime.now().millisecondsSinceEpoch;
    Hive.init('.test_hive_rybbit_$ts');
    offlineStore = HiveOfflineStore(boxName: 'rybbit_test_$ts');
  });

  tearDown(() async {
    await Rybbit.reset();
  });

  Future<void> initRybbit({
    bool dryRun = false,
    bool autoTrackLifecycle = false,
    bool autoTrackErrors = false,
  }) async {
    await Rybbit.init(
      host: 'https://test.example.com',
      siteId: 'test-site',
      debug: true,
      dryRun: dryRun,
      autoTrackLifecycle: autoTrackLifecycle,
      autoTrackErrors: autoTrackErrors,
      flushThreshold: 1,
      transport: mockTransport,
      deviceInfoProvider: MockDeviceInfo(),
      offlineStore: offlineStore,
    );
  }

  group('Rybbit init', () {
    test('throws if instance accessed before init', () {
      expect(() => Rybbit.instance, throwsA(isA<RybbitInitException>()));
    });

    test('initializes successfully', () async {
      await initRybbit();
      expect(Rybbit.isInitialized, true);
      expect(Rybbit.instance.state, RybbitState.ready);
    });

    test('second init is no-op', () async {
      await initRybbit();
      await initRybbit();
      expect(Rybbit.isInitialized, true);
    });
  });

  group('screenView', () {
    test('sends pageview with correct fields', () async {
      await initRybbit();
      Rybbit.instance.screenView('/home', title: 'Home');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(mockTransport.sentEvents.length, 1);
      final e = mockTransport.sentEvents.first;
      expect(e.type, EventType.pageview);
      expect(e.siteId, 'test-site');
      expect(e.hostname, 'TestApp');
      expect(e.pathname, '/home');
      expect(e.pageTitle, 'Home');
      expect(e.screenWidth, 1080);
      expect(e.language, 'cs-CZ');
      expect(e.userAgent, contains('RybbitFlutter'));
    });

    test('tracks referrer from previous screen', () async {
      await initRybbit();
      Rybbit.instance.screenView('/home', title: 'Home');
      await Future.delayed(const Duration(milliseconds: 50));
      Rybbit.instance.screenView('/settings', title: 'Settings');
      await Future.delayed(const Duration(milliseconds: 50));

      final second = mockTransport.sentEvents[1];
      expect(second.referrer, '/home');
    });
  });

  group('event', () {
    test('sends custom_event with properties', () async {
      await initRybbit();
      Rybbit.instance.event('purchase', properties: {'value': 99});
      await Future.delayed(const Duration(milliseconds: 50));

      final e = mockTransport.sentEvents.first;
      expect(e.type, EventType.customEvent);
      expect(e.eventName, 'purchase');
      expect(e.properties, {'value': 99});
    });

    test('merges global properties', () async {
      await initRybbit();
      Rybbit.instance.setGlobalProperty('env', 'test');
      Rybbit.instance.event('click', properties: {'button': 'cta'});
      await Future.delayed(const Duration(milliseconds: 50));

      final e = mockTransport.sentEvents.first;
      expect(e.properties!['env'], 'test');
      expect(e.properties!['button'], 'cta');
    });
  });

  group('trackError', () {
    test('sends error with type and message', () async {
      await initRybbit();
      try {
        throw const FormatException('bad input');
      } catch (e, st) {
        Rybbit.instance.trackError(e, st);
      }
      await Future.delayed(const Duration(milliseconds: 50));

      final e = mockTransport.sentEvents.first;
      expect(e.type, EventType.error);
      expect(e.eventName, 'FormatException');
      expect(e.properties!['message'], contains('bad input'));
      expect(e.properties!.containsKey('stack'), true);
    });
  });

  group('identify', () {
    test('sets userId and sends identify request', () async {
      await initRybbit();
      Rybbit.instance.identify('user-1', traits: {'plan': 'pro'});

      expect(Rybbit.instance.getUserId(), 'user-1');
      expect(mockTransport.sentIdentifies.length, 1);
      expect(mockTransport.sentIdentifies.first.userId, 'user-1');
    });

    test('userId included in subsequent events', () async {
      await initRybbit();
      Rybbit.instance.identify('user-1');
      Rybbit.instance.event('click');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(mockTransport.sentEvents.first.userId, 'user-1');
    });

    test('clearUserId removes userId', () async {
      await initRybbit();
      Rybbit.instance.identify('user-1');
      Rybbit.instance.clearUserId();
      expect(Rybbit.instance.getUserId(), isNull);
    });
  });

  group('dry-run', () {
    test('does not send events in dry-run mode', () async {
      await initRybbit(dryRun: true);
      Rybbit.instance.screenView('/home');
      Rybbit.instance.event('click');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(mockTransport.sentEvents, isEmpty);
    });
  });

  group('offline', () {
    test('stores events when transport fails', () async {
      await initRybbit();
      mockTransport.shouldFail = true;
      Rybbit.instance.event('click');
      await Future.delayed(const Duration(milliseconds: 100));

      final offlineCount = await offlineStore.count;
      expect(offlineCount, greaterThan(0));
    });
  });

  group('auto error tracking', () {
    test('captures FlutterError when autoTrackErrors is true', () async {
      await initRybbit(autoTrackErrors: true);

      // Clear any events captured during init (e.g. MissingPluginException from Hive in test env)
      mockTransport.sentEvents.clear();

      FlutterError.onError!(FlutterErrorDetails(
        exception: StateError('auto tracked error'),
        stack: StackTrace.current,
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      final errorEvents = mockTransport.sentEvents
          .where((e) => e.type == EventType.error && e.eventName == 'StateError')
          .toList();
      expect(errorEvents, hasLength(1));
      expect(
        errorEvents.first.properties!['message'],
        contains('auto tracked error'),
      );
    });

    test('does not capture errors when autoTrackErrors is false', () async {
      await initRybbit(autoTrackErrors: false);

      final previousHandler = FlutterError.onError;
      // No Rybbit handler should be installed
      FlutterError.onError!(FlutterErrorDetails(
        exception: StateError('should not track'),
        stack: StackTrace.current,
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      // Only manual errors should be tracked, not auto-captured
      expect(
        mockTransport.sentEvents.where((e) => e.type == EventType.error),
        isEmpty,
      );
    });

    test('uninstalls error handler on dispose', () async {
      await initRybbit(autoTrackErrors: true);
      final handlerDuringInit = FlutterError.onError;

      await Rybbit.reset();

      // After dispose, FlutterError.onError should be restored
      expect(FlutterError.onError, isNot(equals(handlerDuringInit)));
    });
  });
}
