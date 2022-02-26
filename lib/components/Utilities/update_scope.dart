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
    final appcastURL = 'https://samplasion.github.io/reaxios/appcast.xml';
    final cfg = AppcastConfiguration(
      url: appcastURL,
      supportedOS: ['android'],
    );

    return UpgradeAlert(
      appcastConfig: cfg,
      child: child,
    );
  }
}
