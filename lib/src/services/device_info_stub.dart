import 'device_info.dart';

class DeviceInfoServiceImpl implements DeviceInfoProvider {
  @override
  Future<DeviceData> collect() async {
    return const DeviceData(
      appName: 'unknown',
      packageName: 'unknown',
      appVersion: '0.0.0',
      sdkVersion: sdkVersion,
      platform: 'Unknown',
      osVersion: 'unknown',
      deviceModel: 'unknown',
      screenWidth: 0,
      screenHeight: 0,
      language: 'en',
    );
  }
}

DeviceInfoProvider createDeviceInfoService() => DeviceInfoServiceImpl();
