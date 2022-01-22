import 'package:flutter/material.dart';

@Deprecated("There is no master/detail view since version 0.2")
class MaybeMasterDetail extends StatelessWidget {
  @Deprecated("There is no master/detail view since version 0.2")
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
  }
}
