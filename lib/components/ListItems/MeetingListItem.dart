import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:logger/logger.dart';
import 'package:axios_api/entities/Meeting/Meeting.dart';

import '../../utils/utils.dart';
import '../LowLevel/GradientCircleAvatar.dart';
import '../LowLevel/m3/divider.dart';
import '../Utilities/Alert.dart';
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
    final available = meeting.meetings.dates.any((date) => date.hasSeats);
    final scheme = Theme.of(context).colorScheme;
    return ResourcefulCardListItem(
      leading: GradientCircleAvatar(
        color: context.harmonize(
          color: Utils.getColorFromString(meeting.teacher),
        ),
        child: Icon(Icons.event),
      ),
      title: meeting.subject,
      subtitle: Text(meeting.teacher),
      description: meeting.meetings.note.isNotEmpty
          ? Linkify(
              text: meeting.meetings.note,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (getBadge(context) != null) getBadge(context)!,
              if (getLinkBadge(context) != null) getLinkBadge(context)!,
            ],
          ),
        ],
      ),
      onClick: onClick
          ? () {
              if (!available) {
                context.showSnackbarError(
                  context.loc.translate("teacherMeetings.thereAreNoSeats"),
                );
                return;
              }
              if (kDebugMode)
                showDialog(
                  context: context,
                  builder: (context) {
                    int? selected;
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return AlertDialog(
                          scrollable: true,
                          title: Text("teacherMeetings.chooseDayAndTime"),
                          content: Column(
                            children: [
                              M3Divider(),
                              for (int i = 0; i < 100; i++)
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: selected == i
                                        ? scheme.primary
                                        : scheme.surfaceVariant,
                                    foregroundColor: selected == i
                                        ? scheme.onPrimary
                                        : scheme.onSurfaceVariant,
                                    child: Icon(
                                      selected == i ? Icons.check : Icons.today,
                                    ),
                                  ),
                                  title: Text("$i"),
                                  onTap: () {
                                    Logger.d((selected == i).toString());
                                    setState(() {
                                      selected = i;
                                    });
                                  },
                                ),
                              M3Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              // TODO: Open meeting time picker
              context.showSnackbar(
                context.loc.translate("teacherMeetings.unimplemented"),
              );
            }
          : null,
    );
  }

  Widget? getLinkBadge(BuildContext context) {
    if (meeting.meetings.link.isEmpty) return null;

    final scheme = Theme.of(context).colorScheme;
    final color = AlertColor(
      scheme.tertiaryContainer,
      scheme.onTertiaryContainer,
    );

    return Chip(
      avatar: Icon(Icons.link, color: color.foreground),
      label: Text(
        context.loc.translate(
          "teacherMeetings.link",
        ),
        style: TextStyle(color: color.foreground),
      ),
      side: BorderSide(color: scheme.secondaryContainer),
      backgroundColor: color.background,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget? getBadge(BuildContext context) {
    if (!showBadge) {
      return null;
    }

    final scheme = Theme.of(context).colorScheme;
    final available = meeting.meetings.dates.any((date) => date.hasSeats);
    final color = AlertColor.fromMaterialColor(
      context,
      (available ? Colors.green : Colors.red).harmonizeWith(context),
    );
    final no = available ? "s" : "noS";
    final icon = available ? Icons.check : Icons.close;

    return Chip(
      avatar: Icon(icon, color: color.foreground),
      label: Text(
        context.loc.translate(
          "teacherMeetings.${no}eatsAvailable",
        ),
        style: TextStyle(color: color.foreground),
      ),
      side: BorderSide(color: scheme.secondaryContainer),
      backgroundColor: color.background,
      visualDensity: VisualDensity.compact,
    );
  }
}
