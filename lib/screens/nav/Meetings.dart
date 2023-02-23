import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/ListItems/MeetingListItem.dart';
import 'package:reaxios/components/Views/book_meeting.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:axios_api/Axios.dart';
import 'package:axios_api/entities/Meeting/Meeting.dart';
import '../../components/LowLevel/Empty.dart';
import '../../components/LowLevel/GradientCircleAvatar.dart';
import '../../components/Utilities/ResourcefulCardListItem.dart';
import '../../utils/utils.dart';

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
  ScrollController _scrollController = ScrollController();
  List<MeetingSchema> _meetingSchemas = [];

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _meetingSchemas.isEmpty
          ? SingleChildScrollView(
              child: EmptyUI(
              icon: Icons.error_outline,
              text: context.loc.translate("teacherMeetings.noData"),
            )).center()
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final bookedMeetings = _meetingSchemas
        .where((m) => m.meetings.dates.any((date) => date.isBooked));
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
            text: context.loc.translate("teacherMeetings.noBookedMeetings"),
          ),
          SizedBox(height: 20),
          newMeetingButton,
        ],
      );
    }
  }

  Widget get newMeetingButton {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Provider.value(
            value: widget.session,
            child: BookMeetingView(),
          );
        }));
      },
      child: Text(context.loc.translate("teacherMeetings.bookMeeting")),
    );
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<AppCubit>();
    await cubit.loadMeetings(force: true);
    final schemas = cubit.state.meetings;
    if (schemas != null)
      setState(() {
        _meetingSchemas = schemas;
      });
  }
}
