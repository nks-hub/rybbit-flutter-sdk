import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/src/models/event_type.dart';
import 'package:rybbit_flutter/src/models/track_payload.dart';
import 'package:rybbit_flutter/src/services/queue.dart';

void main() {
  group('EventQueue', () {
    test('enqueue and drain returns events in order', () {
      final queue = EventQueue();
      queue.enqueue(TrackPayload(
          type: EventType.pageview, siteId: 's1', pathname: '/a'));
      queue.enqueue(TrackPayload(
          type: EventType.pageview, siteId: 's1', pathname: '/b'));
      final events = queue.drain();
      expect(events.length, 2);
      expect(events[0].payload.pathname, '/a');
      expect(events[1].payload.pathname, '/b');
      expect(queue.isEmpty, true);
    });

    test('drops oldest when max size reached', () {
      final queue = EventQueue(maxSize: 2);
      queue.enqueue(TrackPayload(
          type: EventType.pageview, siteId: 's', pathname: '/1'));
      queue.enqueue(TrackPayload(
          type: EventType.pageview, siteId: 's', pathname: '/2'));
      queue.enqueue(TrackPayload(
          type: EventType.pageview, siteId: 's', pathname: '/3'));
      expect(queue.size, 2);
      final events = queue.drain();
      expect(events[0].payload.pathname, '/2');
      expect(events[1].payload.pathname, '/3');
    });

    test('drain empties the queue', () {
      final queue = EventQueue();
      queue.enqueue(
          TrackPayload(type: EventType.pageview, siteId: 's'));
      queue.drain();
      expect(queue.isEmpty, true);
      expect(queue.drain(), isEmpty);
    });

    test('clear removes all events', () {
      final queue = EventQueue();
      queue.enqueue(
          TrackPayload(type: EventType.pageview, siteId: 's'));
      queue.clear();
      expect(queue.isEmpty, true);
    });
  });
}
