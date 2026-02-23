import 'package:flutter/material.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Grade/Grade.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/GradeView.dart';
import 'package:reaxios/utils/utils.dart';

class GradeListItem extends StatelessWidget {
  GradeListItem({
    Key? key,
    required this.grade,
    required this.rebuild,
    required this.session,
    this.onClick = false,
    this.radius = 15,
    this.elevation = 8,
  }) : super(key: key);

  final Grade grade;
  final bool onClick;
  final Axios session;
  final void Function() rebuild;
  final double radius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final desc = grade.comment.trim() != "" ? " - ${grade.comment}" : "";
    final leading = NotificationBadge(
      child: GradeAvatar(grade: grade),
      showBadge: !grade.seen,
      rightOffset: 5,
    );

    return CardListItem(
      leading: leading,
      title: grade.subject,
      subtitle: Text("${grade.teacher}$desc"),
      details: Text("${context.dateToString(grade.date)} – ${grade.kind}"),
      radius: radius,
      elevation: elevation,
      onClick: onClick
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return GradeView(
                    grade: grade,
                    session: session,
                    reload: rebuild,
                  );
                }),
              );
            }
          : null,
    );
  }
}
