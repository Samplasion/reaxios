import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:upgrader/upgrader.dart';

import '../../../enums/UpdateNagMode.dart';
import '../../../timetable/structures/Settings.dart';
import '../BigCard.dart';
import 'config.dart';

/// A widget to display the upgrade card.
class _UpgradeCard extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Upgrader upgrader;

  _UpgradeCard({
    // ignore: unused_element
    this.margin = const EdgeInsets.all(1),
    required this.upgrader,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final state = upgrader.state;

    // if (state.debugLogging) {
    //   Logger.d('UpgradeCard: build UpgradeCard');
    // }

    // return FutureBuilder(
    //   future: upgrader.initialize(),
    //   builder: (BuildContext context, AsyncSnapshot<bool> processed) {
    //     if (processed.connectionState == ConnectionState.done &&
    //         processed.data != null &&
    //         processed.data!) {
    //       if (upgrader.shouldDisplayUpgrade()) {
    //         final title = state.messages!.message(UpgraderMessage.title);
    //         final message = state.versionInfo?.releaseNotes ?? "";
    //         final releaseNotes = upgrader.releaseNotes;
    //         final shouldDisplayReleaseNotes = upgrader.shouldDisplayUpgrade();

    //         Widget? notes;
    //         if (shouldDisplayReleaseNotes && releaseNotes != null) {
    //           notes = Padding(
    //             padding: const EdgeInsets.only(top: 15.0),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 const Text('Release Notes:',
    //                     style: TextStyle(fontWeight: FontWeight.bold)),
    //                 Text(
    //                   releaseNotes,
    //                   maxLines: 15,
    //                   overflow: TextOverflow.ellipsis,
    //                 ),
    //               ],
    //             ),
    //           );
    //         }

    //         return Center(
    //           child: MaxWidthContainer(
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 16),
    //               child: BigCard(
    //                 innerPadding: 4,
    //                 body: AlertStyleWidget(
    //                   title: Text(title ?? ''),
    //                   content: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       Text(message),
    //                       Padding(
    //                         padding: const EdgeInsets.only(top: 15.0),
    //                         child: Text(
    //                           state.messages?.message(UpgraderMessage.prompt) ??
    //                               '',
    //                         ),
    //                       ),
    //                       if (notes != null) notes,
    //                     ],
    //                   ),
    //                   actions: <Widget>[
    //                     TextButton(
    //                       child: Text(
    //                         upgrader.messages.message(
    //                                 UpgraderMessage.buttonTitleIgnore) ??
    //                             '',
    //                       ),
    //                       onPressed: () {
    //                         // Save the date/time as the last time alerted.
    //                         upgrader.saveLastAlerted();

    //                         upgrader.onUserIgnored(context, false);
    //                         state.forceUpdateState();
    //                       },
    //                     ),
    //                     TextButton(
    //                       child: Text(
    //                         state.messages.message(
    //                                 UpgraderMessage.buttonTitleLater) ??
    //                             '',
    //                       ),
    //                       onPressed: () {
    //                         // Save the date/time as the last time alerted.
    //                         upgrader.saveLastAlerted();

    //                         state.onUserLater(context, false);
    //                         state.forceUpdateState();
    //                       },
    //                     ),
    //                     TextButton(
    //                       child: Text(
    //                         upgrader.messages.message(
    //                                 UpgraderMessage.buttonTitleUpdate) ??
    //                             '',
    //                       ),
    //                       onPressed: () {
    //                         // Save the date/time as the last time alerted.
    //                         upgrader.saveLastAlerted();

    //                         upgrader.onUserUpdated(context, false);
    //                         state.forceUpdateState();
    //                       },
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         );
    //       } else {
    //         if (upgrader.debugLogging) {
    //           Logger.d('UpgradeCard: will not display');
    //         }
    //       }
    //     }
    //     return const SizedBox(width: 0.0, height: 0.0);
    //   },
    // );

    return Container();
  }
}

class UpgradeCard extends StatelessWidget {
  const UpgradeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final settings = Provider.of<Settings>(context);
    // if (settings.getUpdateNagMode() != UpdateNagMode.banner) {
    //   Logger.d(
    //       'UpgradeCard: not showing because update nag mode is not banner');
    //   return Container();
    // }

    // Upgrader upgrader = getAppcastConfig();
    // if (upgrader.storeController.getUpgraderStore(upgrader.state.upgraderOS) == null) {
    //   Logger.w('UpgradeCard: no appcast configuration found');
    //   return Container();
    // }

    // return _UpgradeCard(
    //   upgrader: upgrader,
    // );
    return Container();
  }
}
