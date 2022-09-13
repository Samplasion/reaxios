import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:upgrader/upgrader.dart';

import '../../../enums/UpdateNagMode.dart';
import '../../../timetable/structures/Settings.dart';
import '../BigCard.dart';
import 'config.dart';

/// A widget to display the upgrade card.
class _UpgradeCard extends UpgradeBase {
  final EdgeInsetsGeometry margin;

  _UpgradeCard({
    // ignore: unused_element
    this.margin = const EdgeInsets.all(1),
    required Upgrader upgrader,
    Key? key,
  }) : super(
          upgrader,
          key: key,
        );

  @override
  Widget build(BuildContext context, UpgradeBaseState state) {
    if (upgrader.debugLogging) {
      print('UpgradeCard: build UpgradeCard');
    }

    return FutureBuilder(
      future: state.initialized,
      builder: (BuildContext context, AsyncSnapshot<bool> processed) {
        if (processed.connectionState == ConnectionState.done &&
            processed.data != null &&
            processed.data!) {
          if (upgrader.shouldDisplayUpgrade()) {
            final title = upgrader.messages.message(UpgraderMessage.title);
            final message = upgrader.message();
            final releaseNotes = upgrader.releaseNotes;
            final shouldDisplayReleaseNotes =
                upgrader.shouldDisplayReleaseNotes();

            Widget? notes;
            if (shouldDisplayReleaseNotes && releaseNotes != null) {
              notes = Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Release Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      releaseNotes,
                      maxLines: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: MaxWidthContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BigCard(
                    innerPadding: 4,
                    body: AlertStyleWidget(
                      title: Text(title ?? ''),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(message),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              upgrader.messages!
                                      .message(UpgraderMessage.prompt) ??
                                  '',
                            ),
                          ),
                          if (notes != null) notes,
                        ],
                      ),
                      actions: <Widget>[
                        if (upgrader.showIgnore)
                          TextButton(
                            child: Text(
                              upgrader.messages.message(
                                      UpgraderMessage.buttonTitleIgnore) ??
                                  '',
                            ),
                            onPressed: () {
                              // Save the date/time as the last time alerted.
                              upgrader.saveLastAlerted();

                              upgrader.onUserIgnored(context, false);
                              state.forceUpdateState();
                            },
                          ),
                        if (upgrader.showLater)
                          TextButton(
                            child: Text(
                              upgrader.messages.message(
                                      UpgraderMessage.buttonTitleLater) ??
                                  '',
                            ),
                            onPressed: () {
                              // Save the date/time as the last time alerted.
                              upgrader.saveLastAlerted();

                              upgrader.onUserLater(context, false);
                              state.forceUpdateState();
                            },
                          ),
                        TextButton(
                          child: Text(
                            upgrader.messages.message(
                                    UpgraderMessage.buttonTitleUpdate) ??
                                '',
                          ),
                          onPressed: () {
                            // Save the date/time as the last time alerted.
                            upgrader.saveLastAlerted();

                            upgrader.onUserUpdated(context, false);
                            state.forceUpdateState();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            if (upgrader.debugLogging) {
              print('UpgradeCard: will not display');
            }
          }
        }
        return const SizedBox(width: 0.0, height: 0.0);
      },
    );
  }
}

class UpgradeCard extends StatelessWidget {
  const UpgradeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    if (settings.getUpdateNagMode() != UpdateNagMode.banner) {
      debugPrint(
          'UpgradeCard: not showing because update nag mode is not banner');
      return Container();
    }

    Upgrader upgrader = getAppcastConfig();
    if (upgrader.appcastConfig == null) {
      debugPrint('UpgradeCard: no appcast configuration found');
      return Container();
    }

    return _UpgradeCard(
      upgrader: upgrader,
    );
  }
}
