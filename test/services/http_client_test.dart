import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rybbit_flutter/src/models/event_type.dart';
import 'package:rybbit_flutter/src/models/track_payload.dart';
import 'package:rybbit_flutter/src/models/identify_payload.dart';
import 'package:rybbit_flutter/src/services/http_client.dart';

void main() {
  group('RybbitHttpClient', () {
    test('sendEvent posts to /api/track and returns true on 200', () async {
      Map<String, dynamic>? capturedBody;
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/track');
        expect(request.method, 'POST');
        expect(request.headers['content-type'], 'application/json');
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"success":true}', 200);
      });
      final client = RybbitHttpClient(
        host: 'https://test.example.com',
        client: mockClient,
      );
      final result = await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: 'test-site',
        hostname: 'com.example',
        pathname: '/home',
      ));
      expect(result, true);
      expect(capturedBody!['type'], 'pageview');
      expect(capturedBody!['site_id'], 'test-site');
    });

    test('sendEvent returns false on non-200', () async {
      final mockClient =
          MockClient((_) async => http.Response('error', 404));
      final client = RybbitHttpClient(
        host: 'https://test.example.com',
        client: mockClient,
      );
      final result = await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: 'test',
      ));
      expect(result, false);
    });

    test('sendEvent returns false on network error', () async {
      final mockClient =
          MockClient((_) async => throw Exception('No internet'));
      final client = RybbitHttpClient(
        host: 'https://test.example.com',
        client: mockClient,
      );
      final result = await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: 'test',
      ));
      expect(result, false);
    });

    test('sendIdentify posts to /api/identify', () async {
      Map<String, dynamic>? capturedBody;
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/identify');
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"success":true}', 200);
      });
      final client = RybbitHttpClient(
        host: 'https://test.example.com',
        client: mockClient,
      );
      final result = await client.sendIdentify(IdentifyPayload(
        siteId: 'test',
        userId: 'user-1',
        traits: {'plan': 'pro'},
      ));
      expect(result, true);
      expect(capturedBody!['user_id'], 'user-1');
      expect(capturedBody!['traits'], {'plan': 'pro'});
    });
  });
}
