import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/timetable/components/essential/GradientAppBar.dart';
import 'package:reaxios/timetable/components/essential/EventCard.dart';
import 'package:reaxios/timetable/components/essential/EventView.dart';
import 'package:reaxios/timetable/components/views/EventController.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';

// lang=en

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController _scrollController = ScrollController();
  late Timer _timer;

  Settings get settings => Provider.of<Settings>(context, listen: false);

  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
    debugPrint('dispose');
  }

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
  Widget build(BuildContext context) {
    final events = settings.getEvents();
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            delegate: _CardSliverDelegate(
              expandedHeight: 150,
              currentEvent: events.getCurrentOrNextEvent(),
              hideTitleWhenExpanded: false,
            ),
            pinned: true,
          ),
          SliverList(
            delegate: _getDelegate([
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16)
                    .copyWith(bottom: 16),
                child: Column(
                  children: [
                    if (events.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 24).copyWith(top: 8),
                        child: Card(
                            color: Theme.of(context).colorScheme.secondary,
                            elevation: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Welcome to Timetable!',
                                  ),
                                  subtitle: Text(
                                    'Create your first event to get started',
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  onTap: () =>
                                      EventController.of(context)!.goToTab(1),
                                ),
                              ],
                            )),
                      ),
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (events.getTodayEvents().isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "Next up",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(16).copyWith(top: 0),
                              child: Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: events
                                      .getTodayEvents()
                                      .map((event) => EventView(
                                            event,
                                            expandable: false,
                                          ))
                                      .toList(),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                clipBehavior: Clip.antiAlias,
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "Next up",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(16).copyWith(top: 0),
                              child: Text(
                                "Nothing. You're free!",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            )
                          ],
                          if (events.getTomorrowEvents().isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "Tomorrow",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(16).copyWith(top: 0),
                              child: Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: events
                                      .getTomorrowEvents()
                                      .map((event) => EventView(
                                            event,
                                            expandable: false,
                                          ))
                                      .toList(),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                clipBehavior: Clip.antiAlias,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  SliverChildDelegate _getDelegate(List<Widget> children) {
    return SliverChildBuilderDelegate(
      (context, index) => children[index],
      childCount: children.length,
    );
  }
}

class _CardSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final Event? currentEvent;

  _CardSliverDelegate({
    required this.expandedHeight,
    required this.currentEvent,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: [
          SizedBox(
            height: appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
            child: GradientAppBar(
              elevation: 4 - 4.0 * percent,
              title: Opacity(
                opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0,
                child: Text("Home"),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            top: cardTopPosition > 0 ? cardTopPosition : 0,
            bottom: 0.0,
            child: Opacity(
              opacity: percent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCard(BuildContext context) {
    return EventCard(event: currentEvent);
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
