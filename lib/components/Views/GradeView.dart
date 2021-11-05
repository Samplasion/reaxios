import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:reaxios/main.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class GradeView extends StatelessWidget {
  const GradeView({
    Key? key,
    required this.grade,
    required this.session,
    required this.store,
    this.reload,
  }) : super(key: key);

  final Grade grade;
  final Axios session;
  final RegistroStore store;
  final void Function()? reload;

  @override
  Widget build(BuildContext context) {
    pad(n) => n < 10 ? "0$n" : n;
    final gradeIsValid = grade.grade != 0 && grade.weight != 0;
    final title = gradeIsValid
        ? "${grade.prettyGrade} in ${grade.subject}"
        : "Commento in ${grade.subject}";
    // print(grade.toJson());
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: kTabBreakpoint),
            child: Column(
              children: [
                Hero(
                  tag: grade.toString(),
                  child: GradeListItem(
                    grade: grade,
                    session: session,
                    rebuild: () {},
                  ),
                ),
                if (gradeIsValid) Divider(),
                if (gradeIsValid)
                  CardListItem(
                    leading: NotificationBadge(
                      child: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.indigo.contrastText,
                        child: Icon(Icons.linear_scale),
                      ),
                      showBadge: false,
                    ),
                    title: "Valore",
                    subtitle: Text.rich(GradeText(grade: grade.grade)),
                    details: Text("Peso: ${(grade.weight * 100).toInt()}%"),
                  ),
                Divider(),
                if (grade.seen)
                  CardListItem(
                    leading: NotificationBadge(
                      child: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(grade.seenBy?[0] ?? ""),
                      ),
                      showBadge: false,
                    ),
                    title: "Visto",
                    subtitle: Text(grade.seenBy ?? ""),
                    details: Text(dateToString(
                      grade.seenOn,
                      includeTime: true,
                      includeSeconds: true,
                    )),
                  ),
                if (!grade.seen)
                  ElevatedButton(
                    onPressed: () {
                      // session.markGradeAsRead(grade).then((_) {
                      //   store.fetchGrades(session);
                      //   setState(() {
                      //     seen = true;
                      //   });
                      // });
                      session.markGradeAsRead(grade).then((_) {
                        store.fetchGrades(session, true);
                        if (reload != null) reload!();
                        // print(reload);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Voto contrassegnato come visto."),
                          ),
                        );
                      });
                    },
                    child: Text("Segna come visto"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
