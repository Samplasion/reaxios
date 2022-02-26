import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpdateScope extends StatelessWidget {
  final Widget child;

  const UpdateScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;

    AppcastConfiguration cfg;
    if (Platform.isAndroid) {
      final appcastURL = 'https://samplasion.github.io/reaxios/appcast.xml';
      cfg = AppcastConfiguration(
        url: appcastURL,
        supportedOS: ['android'],
      );
    } else if (Platform.isIOS) {
      final appcastURL = 'https://samplasion.github.io/reaxios/appcast_mac.xml';
      cfg = AppcastConfiguration(
        url: appcastURL,
        supportedOS: ['macos'],
      );
    } else {
      return child;
    }

    return UpgradeAlert(
      appcastConfig: cfg,
      child: child,
    );
  }
}
