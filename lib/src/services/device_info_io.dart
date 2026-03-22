import 'dart:io' show Platform;
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

    String platformName;
    String osVersion;
    String deviceModel;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      platformName = 'Android';
      osVersion = androidInfo.version.release;
      deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      platformName = 'iOS';
      osVersion = iosInfo.systemVersion;
      deviceModel = iosInfo.utsname.machine;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      platformName = 'macOS';
      osVersion = '${macInfo.majorVersion}.${macInfo.minorVersion}';
      deviceModel = macInfo.model;
    } else if (Platform.isWindows) {
      final winInfo = await deviceInfo.windowsInfo;
      platformName = 'Windows';
      osVersion = '${winInfo.majorVersion}.${winInfo.minorVersion}';
      deviceModel = winInfo.productName;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      platformName = 'Linux';
      osVersion = linuxInfo.versionId ?? 'unknown';
      deviceModel = linuxInfo.prettyName;
    } else {
      platformName = 'Unknown';
      osVersion = 'unknown';
      deviceModel = 'unknown';
    }

    final display = PlatformDispatcher.instance.views.first;
    final screenSize = display.physicalSize;

    return DeviceData(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      appVersion: packageInfo.version,
      sdkVersion: _sdkVersion,
      platform: platformName,
      osVersion: osVersion,
      deviceModel: deviceModel,
      screenWidth: screenSize.width.toInt(),
      screenHeight: screenSize.height.toInt(),
      language: PlatformDispatcher.instance.locale.toLanguageTag(),
    );
  }
}

DeviceInfoProvider createDeviceInfoService() => DeviceInfoServiceImpl();
