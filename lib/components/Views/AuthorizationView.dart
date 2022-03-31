import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/components/ListItems/AuthorizationListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';

import '../../consts.dart';

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
      appBar: GradientAppBar(
        title: Text(context.locale.authorizations
            .getByKey("type${authorization.rawKind}")),
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
          title: context.locale.authorizations.justifiedBy,
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
                cubit.loadAuthorizations();
                if (reload != null) reload!();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          context.locale.authorizations.justifiedSnackbar)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.locale.authorizations.errorSnackbar),
                  ),
                );
              }
            });
          },
          child: Text(context.locale.authorizations.justifyButtonLabel),
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
