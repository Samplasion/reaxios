import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/entities/Meeting/Meeting.dart';

import '../../utils.dart';
import '../LowLevel/GradientCircleAvatar.dart';
import '../Utilities/ResourcefulCardListItem.dart';

class MeetingListItem extends StatelessWidget {
  const MeetingListItem({
    Key? key,
    required this.meeting,
    this.showBadge = true,
    this.showBooked = false,
    this.onClick = false,
  }) : super(key: key);

  final MeetingSchema meeting;
  final bool showBadge;
  final bool showBooked;
  final bool onClick;

  @override
  Widget build(BuildContext context) {
    return ResourcefulCardListItem(
      leading: GradientCircleAvatar(
        color: Utils.getColorFromString(meeting.teacher),
        child: Icon(Icons.event),
      ),
      title: meeting.subject,
      subtitle: Text(meeting.teacher),
      description: meeting.meetings.note.isNotEmpty
          ? Linkify(
              text: meeting.meetings.note,
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption!.color),
              onOpen: context.defaultLinkHandler,
            )
          : Container(),
      location: Text(meeting.meetings.location),
      date: Text(
        "${meeting.meetings.day} ${meeting.meetings.startTime} - ${meeting.meetings.endTime}",
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBooked)
            for (var date in meeting.meetings.dates)
              if (date.isBooked)
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text(date.date),
                  subtitle: date.mode.isNotEmpty ? Text(date.mode) : null,
                ),
          if (getBadge(context) != null) ...[
            getBadge(context)!,
          ],
        ],
      ),
      onClick: onClick
          ? () {
              // TODO: Open meeting time picker
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    context.loc.translate("teacherMeetings.unimplemented")),
              ));
            }
          : null,
    );
  }

  Widget? getBadge(BuildContext context) {
    if (!showBadge) {
      return null;
    }

    return meeting.meetings.dates.any((date) => date.hasSeats)
        ? Badge(
            toAnimate: false,
            shape: BadgeShape.square,
            badgeColor: Colors.green,
            // There's no stadium border, so this'll do
            borderRadius: BorderRadius.circular(9999),
            badgeContent: Text(
              context.loc.translate("teacherMeetings.seatsAvailable"),
              style: TextStyle(
                color: Colors.black,
                fontSize: Theme.of(context).textTheme.caption!.fontSize,
              ),
            ),
            elevation: 0,
          )
        : Badge(
            toAnimate: false,
            shape: BadgeShape.square,
            badgeColor: Colors.red,
            borderRadius: BorderRadius.circular(9999),
            badgeContent: Text(
              context.loc.translate("teacherMeetings.noSeatsAvailable"),
              style: TextStyle(
                color: Colors.white,
                fontSize: Theme.of(context).textTheme.caption!.fontSize,
              ),
            ),
            elevation: 0,
          );
  }
}
