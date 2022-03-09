import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/components/ListItems/MeetingListItem.dart';
import 'package:reaxios/system/Store.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../api/Axios.dart';
import '../../api/entities/Meeting/Meeting.dart';
import '../../components/LowLevel/Empty.dart';
import '../../components/LowLevel/GradientCircleAvatar.dart';
import '../../components/Utilities/ResourcefulCardListItem.dart';
import '../../utils.dart';

class MeetingsPane extends StatefulWidget {
  MeetingsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  State<MeetingsPane> createState() => _MeetingsPaneState();
}

class _MeetingsPaneState extends State<MeetingsPane> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  ScrollController _animationScrollController = ScrollController();
  ScrollController _scrollController = ScrollController();
  List<MeetingSchema> _meetingSchemas = [];

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      scrollController: _animationScrollController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _meetingSchemas.isEmpty
          ? SingleChildScrollView(
              child: EmptyUI(
              icon: Icons.error_outline,
              text: "context.locale.teacherMeetings.noData",
            )).center()
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final bookedMeetings = _meetingSchemas
        .where((m) => m.meetings.dates.any((date) => !date.isBooked));
    if (bookedMeetings.isNotEmpty) {
      return Container(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _meetingSchemas.length + 1,
          itemBuilder: (context, index) {
            if (index == _meetingSchemas.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: newMeetingButton,
              );
            }
            final meetingSchema = _meetingSchemas[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MeetingListItem(
                meeting: meetingSchema,
                showBadge: false,
                showBooked: true,
              ),
            );
          },
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyUI(
            icon: Icons.event,
            text: "context.locale.teacherMeetings.noBookedMeetings",
          ),
          SizedBox(height: 20),
          newMeetingButton,
        ],
      );
    }
  }

  Widget get newMeetingButton {
    return ElevatedButton(
      onPressed: () {},
      child: Text("context.locale.teacherMeetings.bookMeeting"),
    );
  }

  Future<void> _onRefresh() async {
    final store = Provider.of<RegistroStore>(context, listen: false);
    try {
      await store.fetchTeacherMeetings(widget.session, true);
      final schemas = await store.meetings;
      if (schemas != null)
        setState(() {
          _meetingSchemas = schemas;
        });
      else
        return _refreshController.refreshFailed();
    } catch (e) {
      return _refreshController.refreshFailed();
    }
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    final store = Provider.of<RegistroStore>(context, listen: false);
    try {
      await store.fetchTeacherMeetings(widget.session);
      final schemas = await store.meetings;
      if (schemas != null)
        setState(() {
          _meetingSchemas = schemas;
        });
      else
        return _refreshController.loadFailed();
    } catch (e) {
      return _refreshController.loadFailed();
    }
    _refreshController.loadComplete();
  }
}
