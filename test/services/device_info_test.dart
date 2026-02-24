import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/src/services/device_info.dart';

void main() {
  group('DeviceData userAgent', () {
    test('RFC 7231 format - Samsung Galaxy S23', () {
      final data = DeviceData(
        appName: 'MyApp',
        packageName: 'com.example.myapp',
        appVersion: '1.2.3',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'Samsung SM-S911B',
        screenWidth: 1080,
        screenHeight: 2340,
        language: 'cs-CZ',
      );
      expect(
        data.userAgent,
        'MyApp/1.2.3 (com.example.myapp; Android 14; Samsung SM-S911B) RybbitFlutter/0.2.0',
      );
    });

    test('RFC 7231 format - Google Pixel 8 Pro', () {
      final data = DeviceData(
        appName: 'Shopping',
        packageName: 'com.store.shopping',
        appVersion: '3.1.0',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '15',
        deviceModel: 'Google Pixel 8 Pro',
        screenWidth: 1344,
        screenHeight: 2992,
        language: 'en-US',
      );
      expect(
        data.userAgent,
        'Shopping/3.1.0 (com.store.shopping; Android 15; Google Pixel 8 Pro) RybbitFlutter/0.2.0',
      );
    });

    test('RFC 7231 format - iPhone 15 Pro Max', () {
      final data = DeviceData(
        appName: 'HealthKit',
        packageName: 'com.health.tracker',
        appVersion: '2.0.1',
        sdkVersion: '0.2.0',
        platform: 'iOS',
        osVersion: '18.1',
        deviceModel: 'iPhone16,2',
        screenWidth: 1290,
        screenHeight: 2796,
        language: 'en-GB',
      );
      expect(
        data.userAgent,
        'HealthKit/2.0.1 (com.health.tracker; iOS 18.1; iPhone16,2) RybbitFlutter/0.2.0',
      );
    });

    test('RFC 7231 format - iPad Pro', () {
      final data = DeviceData(
        appName: 'Notes',
        packageName: 'com.notes.app',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'iOS',
        osVersion: '17.5',
        deviceModel: 'iPad14,6',
        screenWidth: 2048,
        screenHeight: 2732,
        language: 'de-DE',
      );
      expect(
        data.userAgent,
        'Notes/1.0.0 (com.notes.app; iOS 17.5; iPad14,6) RybbitFlutter/0.2.0',
      );
    });

    test('RFC 7231 format - app name with dots', () {
      final data = DeviceData(
        appName: 'Chatujme.cz',
        packageName: 'com.lury.chatujmeapp',
        appVersion: '0.6.20',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'Google sdk_gphone64_x86_64',
        screenWidth: 1080,
        screenHeight: 2400,
        language: 'cs-CZ',
      );
      expect(
        data.userAgent,
        'Chatujme.cz/0.6.20 (com.lury.chatujmeapp; Android 14; Google sdk_gphone64_x86_64) RybbitFlutter/0.2.0',
      );
    });

    test('customUserAgent overrides default', () {
      final data = DeviceData(
        appName: 'MyApp',
        packageName: 'com.example.myapp',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'Samsung SM-S911B',
        screenWidth: 1080,
        screenHeight: 2340,
        language: 'cs-CZ',
        customUserAgent: 'Custom/1.0',
      );
      expect(data.userAgent, 'Custom/1.0');
    });

    test('withUserAgent returns copy with custom UA', () {
      final data = DeviceData(
        appName: 'MyApp',
        packageName: 'com.example.myapp',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'Samsung SM-S911B',
        screenWidth: 1080,
        screenHeight: 2340,
        language: 'cs-CZ',
      );
      final custom = data.withUserAgent('Override/2.0');
      expect(custom.userAgent, 'Override/2.0');
      expect(custom.appName, 'MyApp');
      expect(custom.screenWidth, 1080);
      // Original unchanged
      expect(data.customUserAgent, isNull);
    });

    test('falls back to packageName when appName is empty', () {
      final data = DeviceData(
        appName: '',
        packageName: 'com.example.myapp',
        appVersion: '1.0.0',
        sdkVersion: '0.2.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'TestDevice',
        screenWidth: 1080,
        screenHeight: 2340,
        language: 'en-US',
      );
      expect(data.userAgent, startsWith('com.example.myapp/'));
    });

    test('all fields stored correctly', () {
      final data = DeviceData(
        appName: 'TestApp',
        packageName: 'cz.test',
        appVersion: '2.0.0',
        sdkVersion: '0.2.0',
        platform: 'iOS',
        osVersion: '17.2',
        deviceModel: 'iPhone15,3',
        screenWidth: 1179,
        screenHeight: 2556,
        language: 'en-US',
      );
      expect(data.appName, 'TestApp');
      expect(data.packageName, 'cz.test');
      expect(data.screenWidth, 1179);
      expect(data.language, 'en-US');
    });
  });
}
