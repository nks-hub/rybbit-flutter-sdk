import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/src/models/event_type.dart';
import 'package:rybbit_flutter_sdk/src/models/track_payload.dart';
import 'package:rybbit_flutter_sdk/src/services/http_client.dart';

/// Runs against a real Rybbit. Point RYBBIT_HOST/RYBBIT_SITE_ID at a plain
/// upstream build to prove the SDK still reports to it:
///   flutter test test/live --dart-define=RYBBIT_HOST=... --dart-define=RYBBIT_SITE_ID=...
const host = String.fromEnvironment('RYBBIT_HOST');
const siteId = String.fromEnvironment('RYBBIT_SITE_ID');

void main() {
  group('live upstream server', () {

    test('an event with the mobile fields still lands', () async {
      final client = RybbitHttpClient(host: host)..debug = true;

      final sent = await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: siteId,
        hostname: 'com.example.uptest',
        pathname: '/sdk-live-first',
        anonymousId: 'sdk-live-anon',
        userAgent: 'UpTestApp/9.9.9 (com.example.uptest; Android 14; Pixel 8) RybbitFlutter/live',
        appVersion: '9.9.9',
        deviceModel: 'Pixel 8',
      ));

      expect(sent, true, reason: 'the retry without the mobile fields should land');
    });

    test('later events skip the fields the server refused', () async {
      final client = RybbitHttpClient(host: host)..debug = true;

      await client.sendEvent(TrackPayload(
        type: EventType.pageview,
        siteId: siteId,
        pathname: '/sdk-live-probe',
        anonymousId: 'sdk-live-anon',
        appVersion: '9.9.9',
        deviceModel: 'Pixel 8',
      ));
      final rejected = client.serverRejectsNativeFields;

      final second = await client.sendEvent(TrackPayload(
        type: EventType.customEvent,
        siteId: siteId,
        pathname: '/sdk-live-second',
        eventName: 'sdk_live_event',
        anonymousId: 'sdk-live-anon',
        appVersion: '9.9.9',
        deviceModel: 'Pixel 8',
      ));

      expect(second, true);
      // On our own build nothing is refused and both events keep the fields.
      if (rejected) {
        expect(client.serverRejectsNativeFields, true);
      }
    });
  }, skip: host.isEmpty || siteId.isEmpty ? 'set RYBBIT_HOST and RYBBIT_SITE_ID to run' : null);
}
