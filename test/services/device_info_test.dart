import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/src/services/device_info.dart';

void main() {
  group('DeviceData', () {
    test('userAgent format is correct', () {
      final data = DeviceData(
        packageName: 'com.example.app',
        appVersion: '1.2.3',
        sdkVersion: '0.1.0',
        platform: 'Android',
        osVersion: '14',
        deviceModel: 'Samsung SM-S911B',
        screenWidth: 1080,
        screenHeight: 2400,
        language: 'cs-CZ',
      );
      expect(
        data.userAgent,
        'RybbitFlutter/0.1.0 (Android 14; Samsung SM-S911B)',
      );
    });

    test('all fields stored correctly', () {
      final data = DeviceData(
        packageName: 'cz.test',
        appVersion: '2.0.0',
        sdkVersion: '0.1.0',
        platform: 'iOS',
        osVersion: '17.2',
        deviceModel: 'iPhone15,3',
        screenWidth: 1179,
        screenHeight: 2556,
        language: 'en-US',
      );
      expect(data.packageName, 'cz.test');
      expect(data.screenWidth, 1179);
      expect(data.language, 'en-US');
    });
  });
}
