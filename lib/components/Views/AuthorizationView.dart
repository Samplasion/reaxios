import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/ListItems/AuthorizationListItem.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:reaxios/main.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';

class AuthorizationView extends StatelessWidget {
  const AuthorizationView({
    Key? key,
    required this.authorization,
    required this.axios,
    this.reload,
  }) : super(key: key);

  final Authorization authorization;
  final Axios axios;
  final void Function()? reload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${authorization.kind}"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            constraints: BoxConstraints(maxWidth: kTabBreakpoint),
            child: Column(
              children: [
                Hero(
                  child: AuthorizationListItem(
                    authorization: authorization,
                    onClick: false,
                    session: axios,
                  ),
                  tag: authorization.toString(),
                ),
                ..._getMoreInfo(context),
                ..._getAccessories(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getMoreInfo(BuildContext context) {
    final store = Provider.of<RegistroStore>(context);
    final student = axios.student;
    final moreInfo = [
      if (authorization.justified)
        CardListItem(
          leading: CircleAvatar(
            child: Icon(Icons.person),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColor.contrastText,
          ),
          title: "Giustificata da",
          subtitle: Text(authorization.authorizedBy),
          details: Text(dateToString(authorization.authorizedDate)),
        ),
    ];
    if (moreInfo.isEmpty)
      return [];
    else
      return [Divider(), ...moreInfo];
  }

  List<Widget> _getAccessories(BuildContext context) {
    final store = Provider.of<RegistroStore>(context);
    // final justifiable = axios.student?.securityBits[SecurityBits.canAuthorizeAuthorization] == "1";
    final justifiable = true;
    final accessories = [
      if (justifiable && !authorization.justified)
        ElevatedButton(
          onPressed: () {
            authorization.justify().then((justified) {
              if (justified) {
                store.fetchAuthorizations(axios, true);
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
    ];

    if (accessories.isEmpty)
      return [];
    else
      return [
        Divider(),
        ...accessories,
      ];
  }
}
