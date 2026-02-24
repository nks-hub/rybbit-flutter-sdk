import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/ga4_events.dart';
import 'package:rybbit_flutter/src/services/http_client.dart';
import 'package:rybbit_flutter/src/services/device_info.dart';
import 'package:rybbit_flutter/src/services/offline_store.dart';

class MockTransport implements RybbitTransport {
  final List<TrackPayload> sentEvents = [];
  final List<IdentifyPayload> sentIdentifies = [];

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    sentEvents.add(payload);
    return true;
  }

  @override
  Future<bool> sendIdentify(IdentifyPayload payload) async {
    sentIdentifies.add(payload);
    return true;
  }
}

class MockDeviceInfo implements DeviceInfoProvider {
  @override
  Future<DeviceData> collect() async => const DeviceData(
        appName: 'TestApp',
        packageName: 'com.test',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'Test',
        osVersion: '1.0',
        deviceModel: 'Test',
        screenWidth: 1080,
        screenHeight: 2400,
        language: 'en',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTransport transport;

  setUp(() async {
    await Rybbit.reset();
    transport = MockTransport();
    final ts = DateTime.now().millisecondsSinceEpoch;
    Hive.init('.test_hive_ga4_$ts');
    final store = HiveOfflineStore(boxName: 'ga4_test_$ts');
    await Rybbit.init(
      host: 'https://test.example.com',
      siteId: 'test',
      flushThreshold: 1,
      autoTrackLifecycle: false,
      transport: transport,
      deviceInfoProvider: MockDeviceInfo(),
      offlineStore: store,
    );
  });

  tearDown(() async => await Rybbit.reset());

  test('trackPurchase sends purchase event', () async {
    Rybbit.instance.trackPurchase(
      transactionId: 'tx-1',
      value: 99.0,
      currency: 'CZK',
    );
    await Future.delayed(const Duration(milliseconds: 50));
    final e = transport.sentEvents.first;
    expect(e.eventName, 'purchase');
    expect(e.properties!['transaction_id'], 'tx-1');
    expect(e.properties!['value'], 99.0);
    expect(e.properties!['currency'], 'CZK');
  });

  test('trackLogin sends login event', () async {
    Rybbit.instance.trackLogin(method: 'google');
    await Future.delayed(const Duration(milliseconds: 50));
    final e = transport.sentEvents.first;
    expect(e.eventName, 'login');
    expect(e.properties!['method'], 'google');
  });

  test('trackSearch sends search event', () async {
    Rybbit.instance.trackSearch(searchTerm: 'flutter', resultsCount: 42);
    await Future.delayed(const Duration(milliseconds: 50));
    final e = transport.sentEvents.first;
    expect(e.eventName, 'search');
    expect(e.properties!['search_term'], 'flutter');
    expect(e.properties!['results_count'], 42);
  });

  test('trackAddToCart sends add_to_cart event', () async {
    Rybbit.instance.trackAddToCart(
      itemId: 'sku-1',
      itemName: 'Widget',
      price: 29.0,
      quantity: 2,
    );
    await Future.delayed(const Duration(milliseconds: 50));
    final e = transport.sentEvents.first;
    expect(e.eventName, 'add_to_cart');
    expect(e.properties!['item_id'], 'sku-1');
    expect(e.properties!['quantity'], 2);
  });
}
