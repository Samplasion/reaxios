import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'package:upgrader/upgrader.dart';

void initConfig() {
  Upgrader().durationUntilAlertAgain = Duration(hours: 1);
}

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
  } else if (Platform.isMacOS) {
    final appcastURL = 'https://samplasion.github.io/reaxios/appcast_mac.xml';
    return AppcastConfiguration(
      url: appcastURL,
      supportedOS: ['macos'],
    );
  }
  return null;
}
