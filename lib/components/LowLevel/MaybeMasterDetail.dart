import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import '../../main.dart';

class MaybeMasterDetail extends StatelessWidget {
  MaybeMasterDetail({
    Key? key,
    this.master,
    required this.detail,
    this.title = "",
  }) : super(key: key);

  final Widget? master;
  final Widget detail;
  final String title;

  @override
  Widget build(BuildContext context) {
    return detail;
    // final width = MediaQuery.of(context).size.width;
    // return width > kTabBreakpoint
    //     ? Scaffold(
    //         body: Row(
    //           children: [
    //             Expanded(
    //               child: master ?? Container(),
    //               flex: 30,
    //             ),
    //             VerticalDivider(
    //               indent: 0,
    //               endIndent: 0,
    //               width: 1,
    //               thickness: 1,
    //             ),
    //             Expanded(child: detail, flex: 70),
    //           ],
    //         ),
    //       )
    //     : detail;
  }
}
