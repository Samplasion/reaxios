import 'package:flutter/material.dart';
import 'package:reaxios/utils/consts.dart';
import 'package:rxdart/rxdart.dart';

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

  static ValueStream<bool>? getShowingStream(BuildContext context) {
    return of(context)?._showMaster;
  }
}

class _MaybeMasterDetailState extends State<MaybeMasterDetail> {
  late final ValueStream<bool> _showMaster =
      Stream.periodic(Duration(milliseconds: 500), (_) {
    return isShowingMaster;
  }).distinct().shareValueSeeded(false);

  bool get isShowingMaster {
    try {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth >= kTabBreakpoint;
    } catch (e) {
      return false;
    }
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
        ],
        Builder(builder: (context) {
          return Expanded(
            child: widget.detail,
          );
        }),
      ],
    );
  }
}
