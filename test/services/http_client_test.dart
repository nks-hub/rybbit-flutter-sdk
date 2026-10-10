import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rybbit_flutter_sdk/src/models/event_type.dart';
import 'package:rybbit_flutter_sdk/src/models/track_payload.dart';
import 'package:rybbit_flutter_sdk/src/models/identify_payload.dart';
import 'package:rybbit_flutter_sdk/src/services/http_client.dart';

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

    test('retries without the mobile fields when the server rejects them', () async {
      final bodies = <Map<String, dynamic>>[];
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        bodies.add(body);
        // An upstream Rybbit validates strictly and refuses unknown fields.
        if (body.containsKey('app_version') || body.containsKey('device_model')) {
          return http.Response('{"error":"Unrecognized key"}', 400);
        }
        return http.Response('{"success":true}', 200);
      });
      final client = RybbitHttpClient(
        host: 'https://upstream.example.com',
        client: mockClient,
      );

      final payload = TrackPayload(
        type: EventType.pageview,
        siteId: 'test-site',
        pathname: '/home',
        appVersion: '1.2.3',
        deviceModel: 'Pixel 8',
      );

      expect(await client.sendEvent(payload), true);
      expect(bodies.length, 2);
      expect(bodies[0]['app_version'], '1.2.3');
      expect(bodies[1].containsKey('app_version'), false);
      expect(bodies[1].containsKey('device_model'), false);
      expect(bodies[1]['pathname'], '/home');
      expect(client.serverRejectsNativeFields, true);

      // Once the server has said no, later events go out stripped the first time.
      expect(await client.sendEvent(payload), true);
      expect(bodies.length, 3);
      expect(bodies[2].containsKey('app_version'), false);
    });

    test('keeps the mobile fields on a server that accepts them', () async {
      final bodies = <Map<String, dynamic>>[];
      final mockClient = MockClient((request) async {
        bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response('{"success":true}', 200);
      });
      final client = RybbitHttpClient(
        host: 'https://ours.example.com',
        client: mockClient,
      );

      await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: 'test-site',
        appVersion: '1.2.3',
        deviceModel: 'Pixel 8',
      ));

      expect(bodies.length, 1);
      expect(bodies[0]['app_version'], '1.2.3');
      expect(bodies[0]['device_model'], 'Pixel 8');
      expect(client.serverRejectsNativeFields, false);
    });

    test('a 400 that is not about the mobile fields is not retried', () async {
      var calls = 0;
      final mockClient = MockClient((_) async {
        calls++;
        return http.Response('{"error":"bad"}', 400);
      });
      final client = RybbitHttpClient(
        host: 'https://test.example.com',
        client: mockClient,
      );

      final result = await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: 'test-site',
      ));

      expect(result, false);
      expect(calls, 1);
      expect(client.serverRejectsNativeFields, false);
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
