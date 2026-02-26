import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/rybbit_flutter_sdk.dart';

void main() {
  group('IdentifyPayload', () {
    test('toJson with traits', () {
      final payload = IdentifyPayload(
        siteId: 'site-123',
        userId: 'user-42',
        traits: {'name': 'John', 'plan': 'pro', 'age': 30},
      );

      final json = payload.toJson();

      expect(json['site_id'], 'site-123');
      expect(json['user_id'], 'user-42');
      expect(json['is_new_identify'], true);
      expect(json['traits'], isA<Map<String, dynamic>>());
      expect((json['traits'] as Map<String, dynamic>)['name'], 'John');
      expect((json['traits'] as Map<String, dynamic>)['plan'], 'pro');
      expect((json['traits'] as Map<String, dynamic>)['age'], 30);
    });

    test('toJson without traits omits traits key', () {
      final payload = IdentifyPayload(
        siteId: 'site-123',
        userId: 'user-42',
      );

      final json = payload.toJson();

      expect(json['site_id'], 'site-123');
      expect(json['user_id'], 'user-42');
      expect(json['is_new_identify'], true);
      expect(json.containsKey('traits'), isFalse);
    });

    test('toJson with is_new_identify false', () {
      final payload = IdentifyPayload(
        siteId: 'site-123',
        userId: 'user-42',
        isNewIdentify: false,
        traits: {'returning': true},
      );

      final json = payload.toJson();

      expect(json['site_id'], 'site-123');
      expect(json['user_id'], 'user-42');
      expect(json['is_new_identify'], false);
      expect(json.containsKey('traits'), isTrue);
      expect((json['traits'] as Map<String, dynamic>)['returning'], true);
    });
  });
}
