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
    storeController: _getConfig(),
    // showIgnore: true,
  );

  return upgrader;
}

UpgraderStoreController? _getConfig() {
  return UpgraderStoreController(
    onAndroid: () => UpgraderAppcastStore(
        appcastURL: 'https://samplasion.github.io/reaxios/appcast.xml'),
    onMacOS: () => UpgraderAppcastStore(
        appcastURL: 'https://samplasion.github.io/reaxios/appcast_mac.xml'),
  );
}
