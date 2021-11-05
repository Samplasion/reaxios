import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/components/ListItems/AbsenceListItem.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/ListItems/NoteListItem.dart';
import 'package:reaxios/system/Store.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

class AbsencesPane extends StatefulWidget {
  AbsencesPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _AbsencesPaneState createState() => _AbsencesPaneState();
}

class _AbsencesPaneState extends State<AbsencesPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Absence>> splitAbsences(List<Absence> absences) {
    return absences.fold(new Map(), (map, note) {
      final date = note.period;
      if (!map.containsKey(date))
        map[date] = [note];
      else
        map[date]!.add(note);

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    RegistroStore store = Provider.of<RegistroStore>(context);

    if (widget.session.student?.securityBits[SecurityBits.hideAbsences] ==
        "1") {
      return EmptyUI(
        text: "Non hai il permesso di visualizzare le assenze. "
            "Contatta la scuola per saperne di più.",
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return FutureBuilder<List<Absence>>(
      future: store.absences ?? Future.value([]),
      initialData: [],
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Text("${snapshot.error}");
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty)
          return buildOk(context, snapshot.data!);

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Absence> absences) {
    // absences = absences.where((n) => n.kind == NoteKind.Absence).toList();
    final map = splitAbsences(absences);
    final entries = map.entries.toList();

    if (absences.isEmpty) {
      return EmptyUI(
        icon: Icons.no_accounts_outlined,
        text: "Non hai assenze.",
      );
    }

    return Container(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            Alert(
              title: "Avviso",
              color: Colors.orange,
              text: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Se devi giustificare un’assenza, un’uscita "
                          "anticipata o un ritardo e non li trovi in questa "
                          "lista, prova a controllare se sono presenti nella ",
                    ),
                    TextSpan(
                      text: "sezione Autorizzazioni",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "."),
                  ],
                ),
              ),
            ).padding(horizontal: 16, top: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_a, _b) => Divider(),
              itemBuilder: (context, i) {
                return StickyHeader(
                  header: Container(
                    height: 50.0,
                    color: Theme.of(context).canvasColor,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      entries[i].key,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  content: Padding(
                    padding: i == entries.length - 1
                        ? EdgeInsets.only(bottom: 16)
                        : EdgeInsets.zero,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i1) {
                        final e = entries[i].value[i1];
                        return Hero(
                          tag: e.toString(),
                          child: AbsenceListItem(
                            absence: e,
                            session: widget.session,
                          ),
                        );
                      },
                      itemCount: entries[i].value.length,
                      shrinkWrap: true,
                    ).paddingDirectional(horizontal: 16),
                  ),
                );
              },
              itemCount: entries.length,
            ),
          ],
        ),
      ),
    );
  }
}
