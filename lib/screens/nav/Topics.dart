import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/ListItems/TopicListItem.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

class TopicsPane extends StatefulWidget {
  TopicsPane({
    Key? key,
    required this.session,
    required this.store,
  }) : super(key: key);

  final Axios session;
  final RegistroStore store;

  @override
  _TopicsPaneState createState() => _TopicsPaneState();
}

class _TopicsPaneState extends State<TopicsPane> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    initREData();
  }

  initREData() async {
    // await widget.session.login();
    // Future.wait([
    //   widget.session.login().then((_) {
    //     widget.session
    //         .getTopics()
    //         .then((a) => setState(() => topics = a.reversed.toList()));
    //   }),
    // ]).then((_) => setState(() => loading = false));
  }

  Map<String, List<Topic>> splitTopics(List<Topic> topics) {
    return topics.fold(new Map(), (map, assmt) {
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
    if (widget.session.student?.securityBits[SecurityBits.hideTopics] == "1") {
      return EmptyUI(
        text: context.locale.main.noPermission,
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return FutureBuilder<List<Topic>>(
      future: widget.store.topics,
      initialData: [],
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) return Text("${snapshot.error}");
        if (snapshot.hasData && snapshot.data!.isNotEmpty)
          return buildOk(context, snapshot.data!);

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildOk(BuildContext context, List<Topic> topics) {
    final map = splitTopics(topics);
    final entries = map.entries.toList().reversed.toList();

    if (topics.isEmpty) {
      return EmptyUI(
        icon: Icons.calendar_today_outlined,
        text: context.locale.topics.empty,
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
                  final e = (entries[i].value
                    ..sort((a, b) => a.lessonHour.compareTo(b.lessonHour)))[i1];
                  return TopicListItem(topic: e);
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
