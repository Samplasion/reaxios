import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/Utilities/updates/config.dart';
import 'package:reaxios/enums/UpdateNagMode.dart';
import 'package:upgrader/upgrader.dart';

import '../../../timetable/structures/Settings.dart';

class UpdateScope extends StatelessWidget {
  final Widget child;

  const UpdateScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;

    final settings = Provider.of<Settings>(context);
    if (settings.getUpdateNagMode() != UpdateNagMode.alert) return child;

    AppcastConfiguration? cfg = getAppcastConfig();
    if (cfg == null) {
      return child;
    }

    return UpgradeAlert(
      appcastConfig: cfg,
      child: child,
      showIgnore: true,
    );
  }
}
