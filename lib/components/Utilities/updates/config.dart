import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'package:upgrader/upgrader.dart';

AppcastConfiguration? getAppcastConfig() {
  if (kDebugMode) {
    Upgrader().debugDisplayAlways = true;
    Upgrader().debugLogging = true;
  }
  if (Platform.isAndroid) {
    final appcastURL = 'https://samplasion.github.io/reaxios/appcast.xml';
    return AppcastConfiguration(
      url: appcastURL,
      supportedOS: ['android'],
    );
  } else if (Platform.isIOS) {
    final appcastURL = 'https://samplasion.github.io/reaxios/appcast_mac.xml';
    return AppcastConfiguration(
      url: appcastURL,
      supportedOS: ['macos'],
    );
  }
  return null;
}
