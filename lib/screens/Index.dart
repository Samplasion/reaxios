import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/TestAxios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/ListItems/RegistroAboutListItem.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/Views/GradeView.dart';
import 'package:reaxios/screens/nav/Absences.dart';
import 'package:reaxios/screens/nav/Assignments.dart';
import 'package:reaxios/screens/nav/Authorizations.dart';
import 'package:reaxios/screens/nav/Calendar.dart';
import 'package:reaxios/screens/nav/Grades.dart';
import 'package:reaxios/screens/nav/Materials.dart';
import 'package:reaxios/screens/nav/Notes.dart';
import 'package:reaxios/screens/nav/Reports.dart';
import 'package:reaxios/screens/nav/Overview.dart';
import 'package:reaxios/screens/nav/Stats.dart';
import 'package:reaxios/screens/nav/Topics.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: import_of_legacy_library_into_null_safe
import '../../main.dart';
import 'nav/BulletinBoard.dart';
import 'nav/ReportCards.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.store}) : super(key: key);

  final RegistroStore store;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  Axios session = new Axios(new AxiosAccount("", "", ""));
  Login login = Login.empty();
  bool showUserDetails = false;
  String lastStudentUUID = "";

  List<Widget> panes = [];
  List<List<dynamic>> drawerItems = [];
  int selectedPane = 0;

  ScrollController drawerController = ScrollController();

  late GlobalKey mdKey;

  @override
  void initState() {
    super.initState();
    initSession();

    mdKey = GlobalKey(debugLabel: "Master/Detail Global Key");

    _checkConnection(15000)();
  }

  FutureOr<dynamic> Function() _checkConnection(int delay) {
    return () async {
      if (!mounted) return;

      // print("[NOI] Checking...");

      try {
        await Dio().get("https://1.1.1.1");
      } on DioError {
        // print("[NOI] No Internet.");
        Navigator.pushReplacementNamed(context, "nointernet");
        return;
      }

      // print("[NOI] Still Internet");
      return Future.delayed(
          Duration(milliseconds: delay), _checkConnection(delay));
    };
  }

  StreamSubscription? _subscription;

  void initSession() async {
    final store = Provider.of<RegistroStore>(context, listen: false);

    if (!store.testMode) {
      final prefs = await SharedPreferences.getInstance();
      final school = prefs.getString("school")!;
      final user = prefs.getString("user")!;
      final pass = prefs.getString("pass")!;

      try {
        await Dio().get("https://1.1.1.1");
      } catch (e) {
        // print(e is! Error && (!e.toString().contains("XMLHttpRequest error")));
        if (e is! Error && (!e.toString().contains("XMLHttpRequest error"))) {
          // print("[NOI] No Internet.");
          Navigator.pushReplacementNamed(context, "nointernet");
          return;
        }
      }

      // print("$school, $user, $pass");
      session = Axios(AxiosAccount(school, user, Encrypter.decrypt(pass)));
      login = await session.login().then((login) {
        return login;
      }).catchError((_, __) {
        prefs.remove("school");
        prefs.remove("user");
        prefs.remove("pass");
        Navigator.pushReplacementNamed(context, "login");
      });
    } else {
      session = TestAxios();
      login = await session.login();
    }
    await session.getStudents(true);

    initPanes(session, login);

    await runCallback(0);

    setState(() {
      loading = false;
      lastStudentUUID = session.student!.studentUUID;
    });

    _subscription =
        widget.store.payloadController.stream.listen((String? payload) async {
      if (payload == null) return;
      List<String> data = payload.split(":");
      String action = data.first;

      switch (action) {
        case "grade":
          String id = data[1];
          Grade grade = (await (widget.store.grades ?? Future.value(<Grade>[])))
              .firstWhere((g) => g.id == id, orElse: () => Grade.empty());

          if (grade.id.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GradeView(
                  grade: grade,
                  store: widget.store,
                  session: session,
                  reload: () => setState(() {}),
                ),
              ),
            );
          }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> runCallback([int index = 0]) async {
    if (drawerItems[index][3] != null && drawerItems[index][3] is Function)
      await drawerItems[index][3]();
  }

  void initPanes(Axios session, Login login) {
    setState(() {
      panes = [
        OverviewPane(
          session: session,
          login: login,
          student: session.student ?? Student.empty(),
          store: widget.store,
        ),
        CalendarPane(session: session),
        AssignmentsPane(session: session, store: widget.store),
        Builder(
          builder: (_) => FutureBuilder<Period?>(
            future: widget.store.getCurrentPeriod(session),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("${snapshot.error}");
              // if (!snapshot.hasData) return LoadingUI();
              return GradesPane(
                session: session,
                openMainDrawer: () => Scaffold.of(context).openDrawer(),
                store: widget.store,
                period: snapshot.data,
              );
            },
          ),
        ),
        TopicsPane(session: session, store: widget.store),
        BulletinsPane(session: session, store: widget.store),
        NotesPane(session: session),
        NoticesPane(session: session),
        AbsencesPane(session: session),
        AuthorizationsPane(session: session),
        MaterialsPane(session: session),
        StatsPane(session: session),
        ReportCardsPane(session: session, store: widget.store),
      ];
      drawerItems = [
        [
          Icon(Icons.home),
          Text('Panoramica'),
          true,
          () async {
            widget.store.fetchAssignments(session);
            widget.store.fetchGrades(session);
            widget.store.fetchTopics(session);
            await Future.wait(<Future<dynamic>>[
              widget.store.assignments ?? Future.value(<Assignment>[]),
              widget.store.grades ?? Future.value(<Grade>[]),
              widget.store.topics ?? Future.value(<Topic>[]),
            ]);
          }
        ],
        [
          Icon(Icons.calendar_today),
          Text('Agenda'),
          true,
          () {
            widget.store.fetchAssignments(session);
            widget.store.fetchTopics(session);
            widget.store.fetchPeriods(session);
          }
        ],
        [
          Icon(Icons.book),
          Text('Compiti'),
          true,
          () => widget.store.fetchAssignments(session)
        ],
        [
          Icon(Icons.star),
          Text('Voti'),
          false,
          () {
            widget.store.fetchGrades(session);
            widget.store.fetchPeriods(session);
            widget.store.fetchSubjects(session);
          }
        ],
        [
          Icon(Icons.topic),
          Text('Argomenti'),
          true,
          () => widget.store.fetchTopics(session)
        ],
        [
          Icon(Icons.mail),
          Text('Segreteria'),
          true,
          () => widget.store.fetchBulletins(session)
        ],
        [
          Icon(Icons.contact_mail),
          Text('Comunicazioni docente'),
          true,
          () => widget.store.fetchNotes(session, true)
        ],
        [
          Icon(Icons.perm_contact_cal),
          Text('Note disciplinari'),
          true,
          () => widget.store.fetchNotes(session, true)
        ],
        [
          Icon(Icons.no_accounts),
          Text('Assenze'),
          true,
          () => widget.store.fetchAbsences(session, true)
        ],
        [
          Icon(Icons.edit),
          Text('Autorizzazioni'),
          true,
          () => widget.store.fetchAuthorizations(session)
        ],
        [
          Icon(Icons.badge),
          Text('Materiale didattico'),
          true,
          () => widget.store.fetchMaterials(session)
        ],
        [
          Icon(Icons.star_outline),
          Text('Statistiche'),
          true,
          () {
            widget.store.fetchAbsences(session);
            widget.store.fetchGrades(session);
            widget.store.fetchPeriods(session);
            widget.store.fetchTopics(session);
          }
        ],
        [
          Icon(Icons.gradient),
          Text('Pagelle'),
          true,
          () {
            widget.store.fetchReportCards(session);
            widget.store.fetchPeriods(session);
          }
        ],
      ];
    });
  }

  Student getStudent() {
    return session.students.length > 0 ? session.student : Student.empty();
  }

  List<ListTile> buildDrawerItems() {
    // final width = MediaQuery.of(context).size.width;
    List<ListTile> items = [];
    for (var index = 0; index < drawerItems.length; index++) {
      items.add(ListTile(
        leading: drawerItems[index][0],
        title: drawerItems[index][1],
        selected: index == selectedPane,
        onTap: () {
          /* if (width <= kTabBreakpoint) */ Navigator.pop(context);
          runCallback(index);
          setState(() {
            selectedPane = index;
          });
        },
      ));
    }
    return items;
  }

  Widget _buildUserDetail() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final s = session.students[index];
          return ListTile(
            title: Text("${s.firstName} ${s.lastName}"),
            selected: s.studentUUID == session.student?.studentUUID,
            onTap: () {
              if (width <= kTabBreakpoint) Navigator.pop(context);
              session.student = s;
              widget.store.reset();
              runCallback(0);
              setState(() {
                showUserDetails = false;
                initPanes(session, login);
              });
            },
          );
        },
        itemCount: session.students.length,
      ),
    );
  }

  Drawer? _getDrawer() {
    // final width = MediaQuery.of(context).size.width;
    if (loading) return null;

    return Drawer(
      child: Column(
        // physics: NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: NetworkImage(
              //     "https://www.brookings.edu/wp-content/uploads/2020/05/empty-classroom_elementary-school-middle-school-high-school.jpg",
              //   ),
              //   fit: BoxFit.cover,
              //   colorFilter: ColorFilter.mode(
              //     Colors.grey,
              //     BlendMode.multiply,
              //   ),
              // ),
              color: Theme.of(context).cardColor,
            ),
            accountName: Text(
              "${login.firstName} ${login.lastName}",
              style: Theme.of(context).textTheme.bodyText1?.merge(
                    TextStyle(fontWeight: FontWeight.bold),
                  ),
            ),
            accountEmail: Text(
              "${session.student!.firstName} ${session.student!.lastName}",
              style: Theme.of(context).textTheme.caption,
            ),
            arrowColor: Theme.of(context).textTheme.bodyText1!.color!,
            currentAccountPicture: CircleAvatar(
              child: Text(
                "${login.firstName} ${login.lastName}".trim()[0],
                style: TextStyle(fontSize: 28),
              ),
              backgroundColor: Theme.of(context).accentColor,
              foregroundColor: Theme.of(context).accentColor.contrastText,
            ),
            onDetailsPressed: () {
              setState(() {
                showUserDetails = !showUserDetails;
              });
            },
            otherAccountsPictures: session.students
                .map(
                  (s) => CircleAvatar(
                    child: Text(
                      "${s.firstName} ${s.lastName}".trim()[0],
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    foregroundColor: Theme.of(context).accentColor.contrastText,
                  ),
                )
                .toList(),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: drawerController,
              child: ListTileTheme(
                selectedColor: Theme.of(context).accentColor,
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 125),
                  crossFadeState: showUserDetails
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _buildUserDetail(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      // shrinkWrap: true,
                      children: [
                        ...buildDrawerItems(),
                        Divider(),
                        ListTile(
                          title: Text("Impostazioni"),
                          leading: Icon(Icons.settings),
                          onTap: () {
                            /* if (width <= kTabBreakpoint) */ Navigator.pop(
                                context);
                            Navigator.pushNamed(context, "settings");
                          },
                        ),
                        RegistroAboutListItem(),
                        ListTile(
                          title: Text("Esci"),
                          leading: Icon(Icons.exit_to_app),
                          onTap: () {
                            showExitDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ] /* ..addAll(buildDrawerItems()) */,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    initPanes(session, login);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: MaybeMasterDetail(
          key: mdKey,
          master: _getDrawer(),
          detail: Scaffold(
            appBar: drawerItems[selectedPane][2]
                ? AppBar(
                    title: drawerItems[selectedPane][1],
                    leading: Builder(builder: (context) {
                      return IconButton(
                        tooltip: "Apri il menu di navigazione",
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: Icon(Icons.menu),
                      );
                    }),
                  )
                : null,
            drawer: _getDrawer(),
            body: loading ? LoadingUI() : panes[selectedPane],
          ),
        ),
      ),
    );
  }

  showExitDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Esci da ${login.schoolTitle} ${login.schoolName}"),
      content: Text(
          "Se esci, dovrai inserire nuovamente l'ID utente e la password."),
      actions: [
        TextButton(
          child: Text("Annulla"),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("OK"),
          onPressed: () async {
            // Refresh store
            await widget.store.reset();

            final prefs = await SharedPreferences.getInstance();

            prefs.remove("school");
            prefs.remove("user");
            prefs.remove("pass");

            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, "login");
          },
        )
      ],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
