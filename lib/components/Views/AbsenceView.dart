import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:axios_api/Axios.dart';
import 'package:axios_api/entities/Absence/Absence.dart';
import 'package:reaxios/components/ListItems/AbsenceListItem.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';

import '../../utils/consts.dart';
import '../LowLevel/m3/divider.dart';

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
        title: Text(context.loc.translate("absences.type${absence.kind}")),
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
    return [
      M3Divider(),
      if (absence.isJustifiable && !absence.isJustified)
        ElevatedButton(
          onPressed: () {
            final cubit = context.read<AppCubit>();
            absence.justify().then((justified) {
              if (justified) {
                cubit.loadAbsences(force: true);
                if (reload != null) reload!();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          context.loc.translate("absences.justifiedSnackbar"))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(context.loc.translate("absences.errorSnackbar")),
                  ),
                );
              }
            });
          },
          child: Text(context.loc.translate("absences.justifyButtonLabel")),
        ),
      if (absence.isJustifiable && absence.isJustified)
        Text(context.loc.translate("absences.alreadyJustified"))
    ];
  }
}
