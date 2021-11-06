import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:reaxios/system/AppInfoStore.dart';

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
      applicationName: app.appName,
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
              TextSpan(
                  style: textStyle,
                  text:
                      "Un semplice frontend per il Registro Elettronico Axios."),
              TextSpan(text: "\n\n"),
              TextSpan(
                  style: textStyle,
                  text: "Un ringraziamento speciale per i codici "
                      "di decifratura e di accesso, nonché per un "
                      "aiuto sostanziale nella comprensione del sistema, "
                      "va a "),
              TextSpan(
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  text: "Simoman3"),
              TextSpan(text: "."),
            ],
          ),
        ),
      ],
    );
  }
}
