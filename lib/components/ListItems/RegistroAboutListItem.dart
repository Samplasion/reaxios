import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../system/AppInfoStore.dart';
import '../../utils.dart';

class RegistroAboutListItem extends StatelessWidget {
  const RegistroAboutListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyText2!;

    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    return AboutListTile(
      icon: Icon(Icons.info),
      applicationName: kIsWeb ? "Registro" : app.appName,
      applicationIcon: Image(
        width: 48,
        height: 48,
        image: AssetImage("assets/icon.png"),
      ),
      applicationLegalese: "\u{a9} 2021 Francesco Arieti",
      applicationVersion: app.version,
      aboutBoxChildren: [
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(style: textStyle, text: context.locale.about.synopsis),
              TextSpan(text: "\n\n"),
              TextSpan(
                  style: textStyle,
                  text: context.locale.about.longDescription.split("###")[0]),
              TextSpan(
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  text: "Simoman3"),
              TextSpan(
                  style: textStyle,
                  text: context.locale.about.longDescription.split("###")[1]),
            ],
          ),
        ),
      ],
    );
  }
}
