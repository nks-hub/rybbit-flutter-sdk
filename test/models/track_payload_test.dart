import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/rybbit_flutter_sdk.dart';

void main() {
  group('TrackPayload', () {
    test('toJson produces correct pageview payload with snake_case keys', () {
      final payload = TrackPayload(
        type: EventType.pageview,
        siteId: 'site-123',
        hostname: 'example.com',
        pathname: '/home',
        querystring: '?ref=abc',
        screenWidth: 1080,
        screenHeight: 1920,
        language: 'en-US',
        pageTitle: 'Home Page',
        referrer: 'https://google.com',
        userId: 'user-42',
        userAgent: 'Flutter/3.0',
      );

      final json = payload.toJson();

      expect(json['type'], 'pageview');
      expect(json['site_id'], 'site-123');
      expect(json['hostname'], 'example.com');
      expect(json['pathname'], '/home');
      expect(json['querystring'], '?ref=abc');
      expect(json['screenWidth'], 1080);
      expect(json['screenHeight'], 1920);
      expect(json['language'], 'en-US');
      expect(json['page_title'], 'Home Page');
      expect(json['referrer'], 'https://google.com');
      expect(json['user_id'], 'user-42');
      expect(json['user_agent'], 'Flutter/3.0');
    });

    test('toJson produces correct custom_event with JSON-stringified properties',
        () {
      final payload = TrackPayload(
        type: EventType.customEvent,
        siteId: 'site-123',
        eventName: 'signup',
        properties: {'plan': 'pro', 'trial': true},
      );

      final json = payload.toJson();

      expect(json['type'], 'custom_event');
      expect(json['event_name'], 'signup');
      expect(json['properties'], isA<String>());

      final decoded =
          jsonDecode(json['properties'] as String) as Map<String, dynamic>;
      expect(decoded['plan'], 'pro');
      expect(decoded['trial'], true);
    });

    test('toJson produces correct error payload', () {
      final payload = TrackPayload(
        type: EventType.error,
        siteId: 'site-123',
        eventName: 'NullPointerException',
        properties: {'stack': 'line 42', 'severity': 'critical'},
      );

      final json = payload.toJson();

      expect(json['type'], 'error');
      expect(json['site_id'], 'site-123');
      expect(json['event_name'], 'NullPointerException');
      expect(json['properties'], isA<String>());

      final decoded =
          jsonDecode(json['properties'] as String) as Map<String, dynamic>;
      expect(decoded['stack'], 'line 42');
      expect(decoded['severity'], 'critical');
    });

    test('toJson includes performance metrics when present, omits when null',
        () {
      final withMetrics = TrackPayload(
        type: EventType.performance,
        siteId: 'site-123',
        lcp: 2.5,
        cls: 0.1,
        inp: 200.0,
        fcp: 1.8,
        ttfb: 0.5,
      );

      final jsonWith = withMetrics.toJson();
      expect(jsonWith['lcp'], 2.5);
      expect(jsonWith['cls'], 0.1);
      expect(jsonWith['inp'], 200.0);
      expect(jsonWith['fcp'], 1.8);
      expect(jsonWith['ttfb'], 0.5);

      final withoutMetrics = TrackPayload(
        type: EventType.pageview,
        siteId: 'site-123',
      );

      final jsonWithout = withoutMetrics.toJson();
      expect(jsonWithout.containsKey('lcp'), isFalse);
      expect(jsonWithout.containsKey('cls'), isFalse);
      expect(jsonWithout.containsKey('inp'), isFalse);
      expect(jsonWithout.containsKey('fcp'), isFalse);
      expect(jsonWithout.containsKey('ttfb'), isFalse);
    });

    test('toJson omits null and empty optional fields', () {
      final payload = TrackPayload(
        type: EventType.pageview,
        siteId: 'site-123',
      );

      final json = payload.toJson();

      expect(json.length, 2);
      expect(json['type'], 'pageview');
      expect(json['site_id'], 'site-123');
      expect(json.containsKey('hostname'), isFalse);
      expect(json.containsKey('pathname'), isFalse);
      expect(json.containsKey('querystring'), isFalse);
      expect(json.containsKey('screenWidth'), isFalse);
      expect(json.containsKey('screenHeight'), isFalse);
      expect(json.containsKey('language'), isFalse);
      expect(json.containsKey('page_title'), isFalse);
      expect(json.containsKey('referrer'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('user_agent'), isFalse);
      expect(json.containsKey('event_name'), isFalse);
      expect(json.containsKey('properties'), isFalse);
    });

    test('roundtrip fromJson/toJson preserves data', () {
      final original = TrackPayload(
        type: EventType.customEvent,
        siteId: 'site-456',
        hostname: 'app.example.com',
        pathname: '/dashboard',
        querystring: '?tab=overview',
        screenWidth: 1440,
        screenHeight: 900,
        language: 'cs-CZ',
        pageTitle: 'Dashboard',
        referrer: 'https://example.com',
        userId: 'usr-99',
        userAgent: 'RybbitFlutter/1.0',
        eventName: 'page_loaded',
        properties: {'load_time': 1.5, 'cached': false},
        lcp: 2.1,
        cls: 0.05,
        inp: 150.0,
        fcp: 1.2,
        ttfb: 0.3,
      );

      final json = original.toJson();
      final restored = TrackPayload.fromJson(json);
      final restoredJson = restored.toJson();

      expect(restoredJson['type'], json['type']);
      expect(restoredJson['site_id'], json['site_id']);
      expect(restoredJson['hostname'], json['hostname']);
      expect(restoredJson['pathname'], json['pathname']);
      expect(restoredJson['querystring'], json['querystring']);
      expect(restoredJson['screenWidth'], json['screenWidth']);
      expect(restoredJson['screenHeight'], json['screenHeight']);
      expect(restoredJson['language'], json['language']);
      expect(restoredJson['page_title'], json['page_title']);
      expect(restoredJson['referrer'], json['referrer']);
      expect(restoredJson['user_id'], json['user_id']);
      expect(restoredJson['user_agent'], json['user_agent']);
      expect(restoredJson['event_name'], json['event_name']);
      expect(restoredJson['properties'], json['properties']);
      expect(restoredJson['lcp'], json['lcp']);
      expect(restoredJson['cls'], json['cls']);
      expect(restoredJson['inp'], json['inp']);
      expect(restoredJson['fcp'], json['fcp']);
      expect(restoredJson['ttfb'], json['ttfb']);
    });
  });
}
