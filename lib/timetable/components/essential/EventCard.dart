import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Event.dart';

class EventCard extends StatefulWidget {
  final Event? event;

  const EventCard({required this.event, Key? key}) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    debugPrint('initState');
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      debugPrint('timer');
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    debugPrint('dispose');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return Card(
        elevation: 20.0,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.9999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context)
                      .cardTheme
                      .color!
                      .toSlightGradient(context),
                ),
              ),
            ),
            Padding(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "No events for today",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your day is free.",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 20.0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.9999),
              gradient: LinearGradient(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                colors: widget.event!.color.toSlightGradient(context),
              ),
            ),
          ),
          if (widget.event!.start.toDateTime().isAfter(DateTime.now()))
            _buildNextEventCardContent(context)
          else
            _buildCurrentEventCardContent(context),
        ],
      ),
    );
  }

  Widget _buildNextEventCardContent(BuildContext context) {
    if (widget.event == null) {
      return Container();
    }

    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "${widget.event!.start}-${widget.event!.end}",
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
          Text(
            widget.event!.name,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
          SizedBox(height: 8),
          Text(
            "Starts in ${printDuration(widget.event!.start.toDateTime().difference(DateTime.now()), tersity: DurationTersity.minute, delimiter: ' and ')}",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
    );
  }

  Widget _buildCurrentEventCardContent(BuildContext context) {
    if (widget.event == null) {
      return Container();
    }

    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "${widget.event!.start}-${widget.event!.end}",
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
          Text(
            widget.event!.name,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
          SizedBox(height: 8),
          Text(
            "Ends in ${printDuration(widget.event!.end.toDateTime().difference(DateTime.now()), tersity: DurationTersity.minute, delimiter: ' and ')}",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: widget.event!.color.contrastColor,
                ),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
    );
  }
}
