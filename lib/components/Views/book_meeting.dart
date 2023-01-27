import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/components/ListItems/MeetingListItem.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';

class BookMeetingView extends StatefulWidget {
  BookMeetingView({Key? key}) : super(key: key);

  @override
  State<BookMeetingView> createState() => _BookMeetingViewState();
}

class _BookMeetingViewState extends State<BookMeetingView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AppCubit>();
    final meetings = cubit.meetings;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.translate("teacherMeetings.bookMeeting")),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MeetingListItem(
              meeting: meeting,
              showBooked: true,
              onClick: true,
            ),
          );
        },
        itemCount: meetings.length,
      ),
    );
  }
}
