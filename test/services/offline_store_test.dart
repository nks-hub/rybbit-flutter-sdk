import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rybbit_flutter_sdk/src/models/event_type.dart';
import 'package:rybbit_flutter_sdk/src/models/track_payload.dart';
import 'package:rybbit_flutter_sdk/src/services/offline_store.dart';

void main() {
  late HiveOfflineStore store;

  setUp(() async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    Hive.init('.test_hive_$ts');
    store = HiveOfflineStore(maxEvents: 5, ttlDays: 7, maxRetries: 3, boxName: 'test_$ts');
    await store.init();
  });

  tearDown(() async {
    await store.clear();
    await store.close();
  });

  group('HiveOfflineStore', () {
    test('add and getAll round-trips event', () async {
      await store.add(TrackPayload(type: EventType.pageview, siteId: 'test', pathname: '/home'));
      final events = await store.getAll();
      expect(events.length, 1);
      expect(events[0].payload.pathname, '/home');
      expect(events[0].retryCount, 0);
    });

    test('enforces maxEvents', () async {
      for (var i = 0; i < 7; i++) {
        await store.add(TrackPayload(type: EventType.pageview, siteId: 'test', pathname: '/$i'));
      }
      final count = await store.count;
      expect(count, 5);
      final events = await store.getAll();
      expect(events.first.payload.pathname, '/2');
      expect(events.last.payload.pathname, '/6');
    });

    test('clear removes all', () async {
      await store.add(TrackPayload(type: EventType.pageview, siteId: 't'));
      await store.add(TrackPayload(type: EventType.pageview, siteId: 't'));
      await store.clear();
      expect(await store.count, 0);
    });
  });
}
