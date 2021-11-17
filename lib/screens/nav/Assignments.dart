import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

class AssignmentsPane extends StatefulWidget {
  AssignmentsPane({
    Key? key,
    required this.session,
    required this.store,
  }) : super(key: key);

  final Axios session;
  final RegistroStore store;

  @override
  _AssignmentsPaneState createState() => _AssignmentsPaneState();
}

class _AssignmentsPaneState extends State<AssignmentsPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Assignment>> splitAssignments(List<Assignment> assignments) {
    return assignments.fold(new Map(), (map, assmt) {
      final date = context.dateToString(assmt.date);
      if (!map.containsKey(date))
        map[date] = [assmt];
      else
        map[date]!.add(assmt);

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.student?.securityBits[SecurityBits.hideAssignments] ==
        "1") {
      return EmptyUI(
        text: context.locale.main.noPermission,
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return FutureBuilder<List<Assignment>>(
      future: widget.store.assignments,
      initialData: [],
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) return Text("${snapshot.error}");
        if (snapshot.hasData && snapshot.data!.isNotEmpty)
          return buildOk(context, snapshot.data!.reversed.toList());

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Assignment> assignments) {
    final map = splitAssignments(assignments);
    final entries = map.entries.toList();

    if (assignments.isEmpty) {
      return EmptyUI(
        icon: Icons.book_outlined,
        text: context.locale.assignments.empty,
      );
    }

    return Container(
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_a, _b) => Divider(),
        controller: controller,
        itemBuilder: (context, i) {
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Theme.of(context).canvasColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                entries[i].key,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            content: Padding(
              padding: i == entries.length - 1
                  ? EdgeInsets.only(bottom: 16)
                  : EdgeInsets.zero,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i1) {
                  final e = entries[i].value[i1];
                  return AssignmentListItem(assignment: e);
                },
                itemCount: entries[i].value.length,
                shrinkWrap: true,
              ),
            ),
          );
        },
        itemCount: entries.length,
      ),
    );
  }
}
