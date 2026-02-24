import '../models/track_payload.dart';

class QueuedEvent {
  QueuedEvent({required this.payload, required this.timestamp});
  final TrackPayload payload;
  final DateTime timestamp;
}

class EventQueue {
  EventQueue({this.maxSize = 100});
  final int maxSize;
  final List<QueuedEvent> _queue = [];

  int get size => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  void enqueue(TrackPayload payload) {
    if (_queue.length >= maxSize) {
      _queue.removeAt(0);
    }
    _queue.add(QueuedEvent(payload: payload, timestamp: DateTime.now()));
  }

  List<QueuedEvent> drain() {
    final events = List<QueuedEvent>.from(_queue);
    _queue.clear();
    return events;
  }

  void clear() => _queue.clear();
}
