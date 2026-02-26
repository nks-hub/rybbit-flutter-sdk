import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/track_payload.dart';

class OfflineEvent {
  OfflineEvent({required this.payload, required this.timestamp, this.retryCount = 0});

  factory OfflineEvent.fromJson(Map<String, dynamic> json) => OfflineEvent(
    payload: TrackPayload.fromJson((json['payload'] as Map).cast<String, dynamic>()),
    timestamp: DateTime.parse(json['timestamp'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
  );

  final TrackPayload payload;
  final DateTime timestamp;
  int retryCount;

  Map<String, dynamic> toJson() => {
    'payload': payload.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };
}

abstract class OfflineEventStore {
  Future<void> init();
  Future<void> add(TrackPayload payload);
  Future<List<OfflineEvent>> getAll();
  Future<void> remove(int index);
  Future<void> clear();
  Future<int> get count;
  Future<void> close();
}

class HiveOfflineStore implements OfflineEventStore {
  HiveOfflineStore({
    this.maxEvents = 1000,
    this.ttlDays = 7,
    this.maxRetries = 3,
    this.boxName = 'rybbit_offline_events',
  });

  final int maxEvents;
  final int ttlDays;
  final int maxRetries;
  final String boxName;
  late Box<String> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  @override
  Future<void> add(TrackPayload payload) async {
    while (_box.length >= maxEvents) {
      await _box.deleteAt(0);
    }
    final event = OfflineEvent(payload: payload, timestamp: DateTime.now());
    await _box.add(jsonEncode(event.toJson()));
  }

  @override
  Future<List<OfflineEvent>> getAll() async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: ttlDays));
    final events = <OfflineEvent>[];
    final keysToRemove = <dynamic>[];

    for (var i = 0; i < _box.length; i++) {
      final raw = _box.getAt(i);
      if (raw == null) continue;
      final event = OfflineEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (event.timestamp.isBefore(cutoff) || event.retryCount >= maxRetries) {
        keysToRemove.add(_box.keyAt(i));
      } else {
        events.add(event);
      }
    }
    for (final key in keysToRemove) {
      await _box.delete(key);
    }
    return events;
  }

  @override
  Future<void> remove(int index) async {
    if (index >= 0 && index < _box.length) {
      await _box.deleteAt(index);
    }
  }

  @override
  Future<void> clear() async => await _box.clear();

  @override
  Future<int> get count async => _box.length;

  @override
  Future<void> close() async => await _box.close();
}
