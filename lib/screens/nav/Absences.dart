import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Absence/Absence.dart';
import 'package:axios_api/entities/Student/Student.dart';
import 'package:reaxios/components/ListItems/AbsenceListItem.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
// import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

class AbsencesPane extends StatefulWidget {
  AbsencesPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _AbsencesPaneState createState() => _AbsencesPaneState();
}

class _AbsencesPaneState extends State<AbsencesPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Absence>> splitAbsences(List<Absence> absences) {
    return absences.fold(new Map(), (map, note) {
      final date = note.period;
      if (!map.containsKey(date))
        map[date] = [note];
      else
        map[date]!.add(note);

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.student?.securityBits[SecurityBits.hideAbsences] ==
        "1") {
      return EmptyUI(
        text: context.loc.translate("absences.noPermission"),
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return buildOk(context, state.absences ?? []);
      },
    );
  }

  Widget buildOk(BuildContext context, List<Absence> absences) {
    if (absences.isEmpty) {
      return EmptyUI(
        icon: Icons.no_accounts_outlined,
        text: context.loc.translate("absences.empty"),
      );
    }

    final map = splitAbsences(absences);
    final entries = map.entries;

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Center(
          child: MaxWidthContainer(
            child: Alert(
              title: context.loc.translate("absences.sectionAlertTitle"),
              color: Colors.orange,
              text: MarkdownBody(
                  data: context.loc.translate("absences.sectionAlertBody")),
            ),
          ),
        ).padding(horizontal: 16, top: 16),
      ),
      for (final MapEntry<String, List<Absence>> entry in entries) ...[
        SliverStickyHeader(
          header: Container(
            height: 50.0,
            color: Theme.of(context).canvasColor,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Center(
              child: MaxWidthContainer(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Hero(
                tag: entry.value[i].toString(),
                child: Center(
                  child: MaxWidthContainer(
                    child: AbsenceListItem(
                      absence: entry.value[i],
                      session: widget.session,
                    ),
                  ),
                ),
              ).paddingDirectional(horizontal: 16),
              childCount: entry.value.length,
            ),
          ),
        )
      ],
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AppCubit>().loadAbsences(force: true);
      },
      child: CustomScrollView(controller: controller, slivers: slivers),
    );
  }
}
