import 'package:device_info_plus/device_info_plus.dart';

late AndroidDeviceInfo androidInfo;

Future fetchDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  androidInfo = await deviceInfo.androidInfo;
}
