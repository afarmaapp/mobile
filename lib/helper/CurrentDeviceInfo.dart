import 'dart:io';
import 'package:device_info/device_info.dart';

class CurrentDeviceInfo {
  static final CurrentDeviceInfo _manager = CurrentDeviceInfo._initializer();

  factory CurrentDeviceInfo() {
    return _manager;
  }

  CurrentDeviceInfo._initializer();

  Object? deviceInfo;

  Future<Object> getCurrentDeviceInfo() async {
    if (deviceInfo != null) return deviceInfo!;
    if (Platform.isAndroid) {
      deviceInfo = await DeviceInfoPlugin().androidInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await DeviceInfoPlugin().iosInfo;
    }
    return deviceInfo!;
  }
}
