import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/m3/drawer.dart';

import '../../system/AppInfoStore.dart';
import '../../utils/utils.dart';

class RegistroAboutListItem extends StatelessWidget {
  const RegistroAboutListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyText2!;

    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    final appName =
        kIsWeb ? context.loc.translate("about.appName") : app.appName;

    return M3DrawerListTile(
      icon: Icon(Icons.info),
      title: Text(context.materialLocale.aboutListTileTitle(appName)),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: appName,
          applicationIcon: Image(
            width: 64,
            height: 64,
            image: AssetImage("assets/icon.png"),
          ),
          applicationLegalese: "\u{a9} 2021 Francesco Arieti",
          applicationVersion: app.version,
          children: [
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      style: textStyle,
                      text: context.loc.translate("about.synopsis")),
                  TextSpan(text: "\n\n"),
                  TextSpan(
                      style: textStyle,
                      text: context.loc
                          .translate("about.longDescription")
                          .split("###")[0]),
                  TextSpan(
                      style: textStyle.copyWith(fontWeight: FontWeight.bold),
                      text: "Simoman3"),
                  TextSpan(
                      style: textStyle,
                      text: context.loc
                          .translate("about.longDescription")
                          .split("###")[1]),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
