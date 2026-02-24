import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceData {
  const DeviceData({
    required this.appName,
    required this.packageName,
    required this.appVersion,
    required this.sdkVersion,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.screenWidth,
    required this.screenHeight,
    required this.language,
  });

  final String appName;
  final String packageName;
  final String appVersion;
  final String sdkVersion;
  final String platform;
  final String osVersion;
  final String deviceModel;
  final int screenWidth;
  final int screenHeight;
  final String language;

  /// RFC 7231 §5.5.3 compliant User-Agent string.
  /// Format: AppName/AppVersion (packageName; Platform OSVersion; deviceModel) RybbitFlutter/SDKVersion
  String get userAgent =>
      '$appName/$appVersion ($packageName; $platform $osVersion; $deviceModel) RybbitFlutter/$sdkVersion';
}

abstract class DeviceInfoProvider {
  Future<DeviceData> collect();
}

class DeviceInfoService implements DeviceInfoProvider {
  static const String _sdkVersion = '0.2.0';

  @override
  Future<DeviceData> collect() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platformName;
    String osVersion;
    String deviceModel;

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      platformName = 'Web';
      osVersion = webInfo.platform ?? 'unknown';
      deviceModel = webInfo.browserName.name;
    } else if (Platform.isAndroid) {
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
