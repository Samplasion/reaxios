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
    this.margin = const EdgeInsets.all(1.0),
    Key? key,
    AppcastConfiguration? appcastConfig,
    UpgraderMessages? messages,
    bool? debugAlwaysUpgrade,
    bool? debugDisplayOnce,
    bool? debugLogging,
    Duration? durationToAlertAgain,
    BoolCallback? onIgnore,
    BoolCallback? onLater,
    BoolCallback? onUpdate,
    http.Client? client,
    bool? showIgnore,
    bool? showLater,
    bool? showReleaseNotes,
    String? countryCode,
    String? minAppVersion,
  }) : super(
          key: key,
          appcastConfig: appcastConfig,
          messages: messages,
          debugDisplayAlways: debugAlwaysUpgrade,
          debugDisplayOnce: debugDisplayOnce,
          debugLogging: debugLogging,
          durationToAlertAgain: durationToAlertAgain,
          onIgnore: onIgnore,
          onLater: onLater,
          onUpdate: onUpdate,
          client: client,
          showIgnore: showIgnore,
          showLater: showLater,
          showReleaseNotes: showReleaseNotes,
          countryCode: countryCode,
          minAppVersion: minAppVersion,
        );

  @override
  Widget build(BuildContext context, UpgradeBaseState state) {
    if (Upgrader().debugLogging) {
      print('UpgradeCard: build UpgradeCard');
    }

    return FutureBuilder(
      future: state.initialized,
      builder: (BuildContext context, AsyncSnapshot<bool> processed) {
        if (processed.connectionState == ConnectionState.done &&
            processed.data != null &&
            processed.data!) {
          assert(Upgrader().messages != null);
          if (Upgrader().shouldDisplayUpgrade()) {
            final title = Upgrader().messages!.message(UpgraderMessage.title);
            final message = Upgrader().message();
            final releaseNotes = Upgrader().releaseNotes;
            final shouldDisplayReleaseNotes =
                Upgrader().shouldDisplayReleaseNotes();

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
                              Upgrader()
                                      .messages!
                                      .message(UpgraderMessage.prompt) ??
                                  '',
                            ),
                          ),
                          if (notes != null) notes,
                        ],
                      ),
                      actions: <Widget>[
                        if (Upgrader().showIgnore)
                          TextButton(
                            child: Text(
                              Upgrader().messages!.message(
                                      UpgraderMessage.buttonTitleIgnore) ??
                                  '',
                            ),
                            onPressed: () {
                              // Save the date/time as the last time alerted.
                              Upgrader().saveLastAlerted();

                              Upgrader().onUserIgnored(context, false);
                              state.forceUpdateState();
                            },
                          ),
                        if (Upgrader().showLater)
                          TextButton(
                            child: Text(
                              Upgrader().messages!.message(
                                      UpgraderMessage.buttonTitleLater) ??
                                  '',
                            ),
                            onPressed: () {
                              // Save the date/time as the last time alerted.
                              Upgrader().saveLastAlerted();

                              Upgrader().onUserLater(context, false);
                              state.forceUpdateState();
                            },
                          ),
                        TextButton(
                          child: Text(
                            Upgrader().messages!.message(
                                    UpgraderMessage.buttonTitleUpdate) ??
                                '',
                          ),
                          onPressed: () {
                            // Save the date/time as the last time alerted.
                            Upgrader().saveLastAlerted();

                            Upgrader().onUserUpdated(context, false);
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
            if (Upgrader().debugLogging) {
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

    AppcastConfiguration? cfg = getAppcastConfig();

    if (cfg == null) {
      debugPrint('UpgradeCard: no appcast configuration found');
      return Container();
    }

    return _UpgradeCard(
      appcastConfig: cfg,
      showIgnore: false,
    );
  }
}
