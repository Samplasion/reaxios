import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:axios_api/Axios.dart';
import 'package:axios_api/entities/Authorization/Authorization.dart';
import 'package:reaxios/components/ListItems/AuthorizationListItem.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';

import '../../utils/consts.dart';
import '../LowLevel/m3/divider.dart';

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
        title: Text(context.loc
            .translate("authorizations.type${authorization.rawKind}")),
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
    final moreInfo = [
      if (authorization.justified)
        CardListItem(
          leading: GradientCircleAvatar(
            child: Icon(Icons.person),
            color: Theme.of(context).primaryColor,
          ),
          title: context.loc.translate("authorizations.justifiedBy"),
          subtitle: Text(authorization.authorizedBy),
          details: Text(context.dateToString(authorization.authorizedDate)),
        ),
    ];
    if (moreInfo.isEmpty)
      return [];
    else
      return [Divider(), ...moreInfo];
  }

  List<Widget> _getAccessories(BuildContext context) {
    // final justifiable = axios.student?.securityBits[SecurityBits.canAuthorizeAuthorization] == "1";
    final justifiable = true;
    final accessories = [
      if (justifiable && !authorization.justified)
        ElevatedButton(
          onPressed: () {
            final cubit = context.read<AppCubit>();
            authorization.justify().then((justified) {
              if (justified) {
                cubit.loadAuthorizations(force: true);
                if (reload != null) reload!();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(context.loc
                          .translate("authorizations.justifiedSnackbar"))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        context.loc.translate("authorizations.errorSnackbar")),
                  ),
                );
              }
            });
          },
          child:
              Text(context.loc.translate("authorizations.justifyButtonLabel")),
        ),
    ];

    if (accessories.isEmpty)
      return [];
    else
      return [
        M3Divider(),
        ...accessories,
      ];
  }
}
