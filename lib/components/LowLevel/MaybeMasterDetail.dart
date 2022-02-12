import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/ConditionalChild.dart';
import 'package:reaxios/consts.dart';

const kDefaultMasterWidth = 320.0;

class MaybeMasterDetail extends StatefulWidget {
  MaybeMasterDetail({
    Key? key,
    this.master,
    required this.detail,
    this.title = "",
    this.masterWidth = kDefaultMasterWidth,
  }) : super(key: key);

  final Widget? master;
  final Widget detail;
  final String title;
  final double masterWidth;

  @override
  _MaybeMasterDetailState createState() => _MaybeMasterDetailState();

  static _MaybeMasterDetailState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MaybeMasterDetailState>();

  static bool shouldBeShowingMaster(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= kTabBreakpoint;
  }
}

class _MaybeMasterDetailState extends State<MaybeMasterDetail> {
  bool get isShowingMaster {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= kTabBreakpoint;
  }

  double get detailWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    if (!isShowingMaster) {
      return screenWidth;
    }
    return screenWidth - widget.masterWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.master != null && isShowingMaster) ...[
          SizedBox(
            width: widget.masterWidth,
            child: widget.master!,
          ),
          ConditionalChild(
            child: Material(
              child: VerticalDivider(
                thickness: 1,
                width: 1,
              ),
            ),
            show: MediaQuery.of(context).size.width >= kTabBreakpoint,
          ),
        ],
        Expanded(
          child: widget.detail,
        ),
      ],
    );
  }
}
