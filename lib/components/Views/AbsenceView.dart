import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/components/ListItems/AbsenceListItem.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:reaxios/main.dart';
import 'package:reaxios/system/Store.dart';

class AbsenceView extends StatelessWidget {
  const AbsenceView({
    Key? key,
    required this.absence,
    required this.axios,
    this.reload,
  }) : super(key: key);

  final Absence absence;
  final Axios axios;
  final void Function()? reload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${absence.kind}"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            constraints: BoxConstraints(maxWidth: kTabBreakpoint),
            child: Column(
              children: [
                Hero(
                  child: AbsenceListItem(
                    absence: absence,
                    onClick: false,
                    session: axios,
                  ),
                  tag: absence.toString(),
                ),
                ..._getAccessories(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAccessories(BuildContext context) {
    final store = Provider.of<RegistroStore>(context);
    return [
      Divider(),
      if (absence.isJustifiable && !absence.isJustified)
        ElevatedButton(
          onPressed: () {
            absence.justify().then((justified) {
              if (justified) {
                store.fetchAbsences(axios, true);
                if (reload != null) reload!();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Giustificata.")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Si è verificato un errore. Riprova più tardi."),
                  ),
                );
              }
            });
          },
          child: Text("Giustifica"),
        ),
      if (absence.isJustifiable && absence.isJustified)
        Text("Già giustificata.")
    ];
  }
}
