import 'device_info_stub.dart'
    if (dart.library.io) 'device_info_io.dart'
    if (dart.library.html) 'device_info_web.dart' as impl;

const String sdkVersion = '0.2.3';

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
    this.customUserAgent,
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
  final String? customUserAgent;

  /// RFC 7231 compliant User-Agent string.
  String get userAgent {
    if (customUserAgent != null) return customUserAgent!;
    final name = appName.isNotEmpty ? appName : packageName;
    return '$name/$appVersion ($packageName; $platform $osVersion; $deviceModel) RybbitFlutter/$sdkVersion';
  }

  DeviceData withUserAgent(String ua) => DeviceData(
        appName: appName,
        packageName: packageName,
        appVersion: appVersion,
        sdkVersion: sdkVersion,
        platform: platform,
        osVersion: osVersion,
        deviceModel: deviceModel,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        language: language,
        customUserAgent: ua,
      );
}

abstract class DeviceInfoProvider {
  Future<DeviceData> collect();
}

class DeviceInfoService implements DeviceInfoProvider {
  @override
  Future<DeviceData> collect() => impl.createDeviceInfoService().collect();
}
