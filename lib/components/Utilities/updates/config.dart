import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'package:upgrader/upgrader.dart';

void initConfig() {
  // Upgrader().durationUntilAlertAgain = Duration(hours: 1);
}

Upgrader getAppcastConfig() {
  final upgrader = Upgrader(
    debugDisplayAlways: kDebugMode,
    debugLogging: kDebugMode,
    appcastConfig: _getConfig(),
    showIgnore: true,
  );

  return upgrader;
}

AppcastConfiguration? _getConfig() {
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
