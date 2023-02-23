import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axios_api/Axios.dart';
import 'package:axios_api/entities/Assignment/Assignment.dart';
import 'package:axios_api/entities/Student/Student.dart';
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../components/LowLevel/MaybeMasterDetail.dart';
import '../../components/LowLevel/m3/divider.dart';

class AssignmentsPane extends StatefulWidget {
  AssignmentsPane({
    Key? key,
    required this.session,
    required this.openMainDrawer,
  }) : super(key: key);

  final Axios session;
  final Function() openMainDrawer;

  @override
  _AssignmentsPaneState createState() => _AssignmentsPaneState();
}

class _AssignmentsPaneState extends State<AssignmentsPane> {
  final ScrollController _mainController = ScrollController();
  String selectedSubject = "";

  List<Assignment> filterAssignments(List<Assignment> assignments) {
    if (selectedSubject == "") {
      return assignments;
    } else {
      return assignments
          .where((assignment) => assignment.subject == selectedSubject)
          .toList();
    }
  }

  Map<String, List<Assignment>> splitAssignments(List<Assignment> assignments) {
    return assignments.fold(new Map(), (map, assmt) {
      final date = context.dateToString(assmt.date, includeDayOfWeek: true);
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
        text: context.loc.translate("main.noPermission"),
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    final cubit = context.watch<AppCubit>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.loc.translate("drawer.assignments")),
        leading: MaybeMasterDetail.of(context)!.isShowingMaster
            ? null
            : Builder(builder: (context) {
                return IconButton(
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                  onPressed: widget.openMainDrawer,
                  icon: Icon(Icons.menu),
                );
              }),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: Scaffold.of(context).openEndDrawer,
                icon: Icon(Icons.topic),
              );
            },
          )
        ],
      ),
      body: buildOk(context, cubit.assignments.reversed.toList()),
      endDrawer: _getEndDrawer(cubit.assignments.reversed.toList()),
    );
  }

  List<String> getSubjects(List<Assignment> assignments) {
    return [""] +
        (assignments.fold<List<String>>(
          <String>[],
          (list, assignment) {
            if (!list.contains(assignment.subject))
              list.add(assignment.subject);
            return list;
          },
        )..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));
  }

  final ScrollController _endDrawerController = ScrollController();

  Widget _getEndDrawer(List<Assignment> assignments) {
    final subjects = getSubjects(assignments);
    bool hasAny(Assignment assignment) =>
        (assignment.date.isAfter(DateTime.now()) ||
            assignment.date.isSameDay(DateTime.now()));
    return Drawer(
      child: CustomScrollView(
        controller: _endDrawerController,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              leading: GradientCircleAvatar(
                color: assignments.any(hasAny)
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[700]!,
                child: Icon(
                  Icons.all_out_outlined,
                ),
              ),
              title: Text(context.loc.translate("assignments.allSubjects")),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedSubject = "";
                  _mainController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                });
              },
            ),
          ),
          SliverToBoxAdapter(
            child: M3Divider(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final subject = subjects[index + 1];

                return ListTile(
                  leading: GradientCircleAvatar(
                    color: hasAny(assignments.firstWhere(
                            (assignment) => assignment.subject == subject))
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey[700]!,
                    child: Icon(
                      Utils.getBestIconForSubject(subject, Icons.book),
                    ),
                  ),
                  title: Text(subject),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      selectedSubject = subject;
                      _mainController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    });
                  },
                );
              },
              childCount: subjects.length - 1,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOk(BuildContext context, List<Assignment> assignments) {
    final map = splitAssignments(filterAssignments(assignments));
    final entries = map.entries.toList();

    if (assignments.isEmpty) {
      return EmptyUI(
        icon: Icons.book_outlined,
        text: context.loc.translate("assignments.empty"),
      );
    }

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<AppCubit>().loadAssignments(force: true);
          },
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (_a, _b) => M3Divider(),
            controller: _mainController,
            itemBuilder: (context, i) {
              return StickyHeader(
                header: Center(
                  child: MaxWidthContainer(
                    child: Container(
                      height: 50.0,
                      color: Theme.of(context).canvasColor,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        entries[i].key,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
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
                      return Center(
                        child: MaxWidthContainer(
                          child: AssignmentListItem(assignment: e),
                        ),
                      );
                    },
                    itemCount: entries[i].value.length,
                    shrinkWrap: true,
                  ),
                ),
              );
            },
            itemCount: entries.length,
          ),
        ),
      ),
    );
  }
}
