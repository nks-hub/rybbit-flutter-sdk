import 'dart:ui' show PlatformDispatcher;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'device_info.dart';

class DeviceInfoServiceImpl implements DeviceInfoProvider {
  static const String _sdkVersion = sdkVersion;

  @override
  Future<DeviceData> collect() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    final webInfo = await deviceInfo.webBrowserInfo;

    final display = PlatformDispatcher.instance.views.first;
    final screenSize = display.physicalSize;

    return DeviceData(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      appVersion: packageInfo.version,
      sdkVersion: _sdkVersion,
      platform: 'Web',
      osVersion: webInfo.platform ?? 'unknown',
      deviceModel: webInfo.browserName.name,
      screenWidth: screenSize.width.toInt(),
      screenHeight: screenSize.height.toInt(),
      language: PlatformDispatcher.instance.locale.toLanguageTag(),
    );
  }
}

DeviceInfoProvider createDeviceInfoService() => DeviceInfoServiceImpl();
