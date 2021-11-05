import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/components/ListItems/AuthorizationListItem.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/ListItems/NoteListItem.dart';
import 'package:reaxios/system/Store.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

class AuthorizationsPane extends StatefulWidget {
  AuthorizationsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _AuthorizationsPaneState createState() => _AuthorizationsPaneState();
}

class _AuthorizationsPaneState extends State<AuthorizationsPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Authorization>> splitAuthorizations(
      List<Authorization> authorizations) {
    return authorizations.fold(new Map(), (map, note) {
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

    if (widget.session.student?.securityBits[SecurityBits.hideAuthorizations] ==
        "1") {
      return EmptyUI(
        text: "Non hai il permesso di visualizzare le autorizzazioni. "
            "Contatta la scuola per saperne di più.",
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return FutureBuilder<List<Authorization>>(
      future: store.authorizations ?? Future.value([]),
      initialData: [],
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Text("${snapshot.error}");
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty)
          return buildOk(context, snapshot.data!.reversed.toList());

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Authorization> authorizations) {
    // authorizations = authorizations.where((n) => n.kind == NoteKind.Authorization).toList();
    final map = splitAuthorizations(authorizations);
    final entries = map.entries.toList();

    if (authorizations.isEmpty) {
      return EmptyUI(
        icon: Icons.no_accounts_outlined,
        text: "Non hai assenze.",
      );
    }

    return Container(
      child: ListView.separated(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        controller: controller,
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
                    child: AuthorizationListItem(
                        authorization: e, session: widget.session),
                    tag: e.toString(),
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
    );
  }
}
