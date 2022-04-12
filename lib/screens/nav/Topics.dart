import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/ListItems/TopicListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../components/LowLevel/MaybeMasterDetail.dart';

class TopicsPane extends StatefulWidget {
  TopicsPane({
    Key? key,
    required this.session,
    required this.openMainDrawer,
  }) : super(key: key);

  final Axios session;
  final Function() openMainDrawer;

  @override
  _TopicsPaneState createState() => _TopicsPaneState();
}

class _TopicsPaneState extends State<TopicsPane> {
  final ScrollController _mainController = ScrollController();
  String selectedSubject = "";

  List<Topic> filterTopics(List<Topic> topics) {
    if (selectedSubject == "") {
      return topics;
    } else {
      return topics.where((topic) => topic.subject == selectedSubject).toList();
    }
  }

  Map<String, List<Topic>> splitTopics(List<Topic> topics) {
    return topics.fold(new Map(), (map, assmt) {
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
    if (widget.session.student?.securityBits[SecurityBits.hideTopics] == "1") {
      return EmptyUI(
        text: context.locale.main.noPermission,
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return BlocBuilder<AppCubit, AppState>(
      bloc: context.watch<AppCubit>(),
      builder: (BuildContext context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: GradientAppBar(
            title: Text(context.locale.drawer.topics),
            leading: MaybeMasterDetail.of(context)!.isShowingMaster
                ? null
                : Builder(builder: (context) {
                    return IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
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
          body: buildOk(context, (state.topics ?? []).reversed.toList()),
          endDrawer: _getEndDrawer((state.topics ?? []).reversed.toList()),
        );
      },
    );
  }

  List<String> getSubjects(List<Topic> topics) {
    return [""] +
        (topics.fold<List<String>>(
          <String>[],
          (list, topic) {
            if (!list.contains(topic.subject)) list.add(topic.subject);
            return list;
          },
        )..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));
  }

  final ScrollController _endDrawerController = ScrollController();

  Widget _getEndDrawer(List<Topic> topics) {
    final subjects = getSubjects(topics);
    bool hasAny(Topic topic) => (topic.date.isAfter(DateTime.now()) ||
        topic.date.isSameDay(DateTime.now()));
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
                color: topics.any(hasAny)
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[700]!,
                child: Icon(
                  Icons.all_out_outlined,
                ),
              ),
              title: Text(context.locale.topics.allSubjects),
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
            child: Divider(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final subject = subjects[index + 1];

                return ListTile(
                  leading: GradientCircleAvatar(
                    color: hasAny(topics
                            .firstWhere((topic) => topic.subject == subject))
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

  Widget buildOk(BuildContext context, List<Topic> topics) {
    final map = splitTopics(filterTopics(topics));
    final entries = map.entries.toList();

    if (topics.isEmpty) {
      return EmptyUI(
        icon: Icons.calendar_today_outlined,
        text: context.locale.topics.empty,
      );
    }

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<AppCubit>().loadTopics(force: true);
          },
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (_a, _b) => Divider(),
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
                      final e = (entries[i].value
                        ..sort((a, b) =>
                            a.lessonHour.compareTo(b.lessonHour)))[i1];
                      return Center(
                        child: MaxWidthContainer(
                          child: TopicListItem(topic: e),
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
