import 'dart:async';

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/Utilities/updates/update_scope.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/screens/nav/Absences.dart';
import 'package:reaxios/screens/nav/Assignments.dart';
import 'package:reaxios/screens/nav/Authorizations.dart';
import 'package:reaxios/screens/nav/Calendar.dart';
import 'package:reaxios/screens/nav/Grades.dart';
import 'package:reaxios/screens/nav/Materials.dart';
import 'package:reaxios/screens/nav/Meetings.dart';
import 'package:reaxios/screens/nav/Notes.dart';
import 'package:reaxios/screens/nav/Reports.dart';
import 'package:reaxios/screens/nav/Overview.dart';
import 'package:reaxios/screens/nav/Stats.dart';
import 'package:reaxios/screens/nav/Topics.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/system/intents.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts.dart';
import '../system/AppInfoStore.dart';
import 'nav/BulletinBoard.dart';
import 'nav/Calculator.dart';
import 'nav/ReportCards.dart';
import 'nav/Timetable.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.store}) : super(key: key);

  final RegistroStore store;

  @override
  _HomeScreenState createState() => _HomeScreenState();

  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Axios _session = new Axios(new AxiosAccount("", "", ""));
  Login _login = Login.empty();
  bool _showUserDetails = false;

  List<Widget> _panes = [];
  List<List<dynamic>> _drawerItems = [];
  int _selectedPane = 0;

  ScrollController _drawerController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initSession();

    _checkConnection(15000)();
  }

  FutureOr<dynamic> Function() _checkConnection(int delay) {
    return () async {
      if (kIsWeb) return;

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

  // StreamSubscription? _subscription;

  void _initSession() async {
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
      _session = Axios(AxiosAccount(school, user, Encrypter.decrypt(pass)));
      _login = await _session.login().then((login) {
        return login;
      }).catchError((_, __) {
        prefs.remove("school");
        prefs.remove("user");
        prefs.remove("pass");
        Navigator.pushReplacementNamed(context, "login");
      });
    } else {
      _session = TestAxios();
      _login = await _session.login();
    }
    await _session.getStudents(true);

    _initPanes(_session, _login);

    await _runCallback(0);

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    // _subscription?.cancel();
    super.dispose();
  }

  Future<void> _runCallback([int index = 0]) async {
    if (_drawerItems[index][3] != null && _drawerItems[index][3] is Function)
      await _drawerItems[index][3]();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _initPanes(Axios session, Login login) {
    setState(() {
      _panes = [
        Builder(
          builder: (context) => OverviewPane(
            session: session,
            login: login,
            student: session.student ?? Student.empty(),
            store: widget.store,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
            switchToTab: _switchToTab,
          ),
        ),
        CalendarPane(session: session),
        Builder(
          builder: (context) => AssignmentsPane(
            session: session,
            store: widget.store,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
        Builder(
          builder: (_) => FutureBuilder<Period?>(
            future: widget.store.getCurrentPeriod(session),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("${snapshot.error}");
              // if (!snapshot.hasData) return LoadingUI();
              return CalculatorPane(
                session: session,
                openMainDrawer: () => Scaffold.of(context).openDrawer(),
                period: snapshot.data,
              );
            },
          ),
        ),
        Builder(
          builder: (context) => TopicsPane(
            session: session,
            store: widget.store,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Builder(
          builder: (context) => TimetablePane(
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        BulletinsPane(session: session, store: widget.store),
        NotesPane(session: session),
        NoticesPane(session: session),
        AbsencesPane(session: session),
        AuthorizationsPane(session: session),
        MeetingsPane(session: session),
        MaterialsPane(session: session),
        StatsPane(session: session),
        ReportCardsPane(session: session, store: widget.store),
      ];
      _drawerItems = [
        [
          Icon(Icons.home),
          Text(context.locale.drawer.overview),
          false,
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
          Text(context.locale.drawer.calendar),
          false,
          () {
            widget.store.fetchAssignments(session);
            widget.store.fetchTopics(session);
            widget.store.fetchPeriods(session);
          }
        ],
        [
          Icon(Icons.book),
          Text(context.locale.drawer.assignments),
          false,
          () => widget.store.fetchAssignments(session)
        ],
        [
          Icon(Icons.star),
          Text(context.locale.drawer.grades),
          false,
          () {
            widget.store.fetchGrades(session);
            widget.store.fetchPeriods(session);
            widget.store.fetchSubjects(session);
          }
        ],
        [
          Icon(Icons.calculate),
          Text(context.locale.drawer.calculator),
          false,
          () {
            widget.store.fetchGrades(session);
            widget.store.fetchPeriods(session);
            widget.store.fetchSubjects(session);
          }
        ],
        [
          Icon(Icons.topic),
          Text(context.locale.drawer.topics),
          false,
          () => widget.store.fetchTopics(session)
        ],
        [
          Icon(Icons.access_time),
          Text(context.locale.drawer.timetable),
          false,
          () {},
        ],
        [
          Icon(Icons.mail),
          Text(context.locale.drawer.secretary),
          true,
          () => widget.store.fetchBulletins(session)
        ],
        [
          Icon(Icons.contact_mail),
          Text(context.locale.drawer.teacherNotes),
          true,
          () => widget.store.fetchNotes(session, true)
        ],
        [
          Icon(Icons.perm_contact_cal),
          Text(context.locale.drawer.notices),
          true,
          () => widget.store.fetchNotes(session, true)
        ],
        [
          Icon(Icons.no_accounts),
          Text(context.locale.drawer.absences),
          true,
          () => widget.store.fetchAbsences(session, true)
        ],
        [
          Icon(Icons.edit),
          Text(context.locale.drawer.authorizations),
          true,
          () => widget.store.fetchAuthorizations(session)
        ],
        [
          Icon(Icons.terrain),
          Text("context.locale.drawer.teacherMeetings"),
          true,
          () => widget.store.fetchTeacherMeetings(session)
        ],
        [
          Icon(Icons.badge),
          Text(context.locale.drawer.teachingMaterials),
          true,
          () => widget.store.fetchMaterials(session)
        ],
        [
          Icon(Icons.star_outline),
          Text(context.locale.drawer.stats),
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
          Text(context.locale.drawer.reportCards),
          true,
          () {
            widget.store.fetchReportCards(session);
            widget.store.fetchPeriods(session);
          }
        ],
      ];
    });
  }

  Student _getStudent() {
    return _session.students.length > 0 ? _session.student : Student.empty();
  }

  List<ListTile> _buildDrawerItems() {
    // final width = MediaQuery.of(context).size.width;
    List<ListTile> items = [];
    for (var index = 0; index < _drawerItems.length; index++) {
      items.add(ListTile(
        leading: _drawerItems[index][0],
        title: _drawerItems[index][1],
        selected: index == _selectedPane,
        onTap: () {
          if (!MaybeMasterDetail.shouldBeShowingMaster(context))
            Navigator.pop(context);
          _switchToTab(index);
        },
      ));
    }
    return items;
  }

  Widget _buildUserDetail() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final s = _session.students[index];
          return ListTile(
            title: Text("${s.firstName} ${s.lastName}"),
            selected: s.studentUUID == _session.student?.studentUUID,
            onTap: () {
              if (!MaybeMasterDetail.of(context)!.isShowingMaster)
                Navigator.pop(context);
              _session.student = s;
              widget.store.reset();
              _runCallback(0);
              setState(() {
                _showUserDetails = false;
                _initPanes(_session, _login);
              });
            },
          );
        },
        itemCount: _session.students.length,
      ),
    );
  }

  Drawer? _getDrawer() {
    // final width = MediaQuery.of(context).size.width;
    if (_loading) return null;

    return Drawer(
      child: Column(
        // physics: NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            accountName: Text(
              "${_login.firstName} ${_login.lastName}",
              style: Theme.of(context).textTheme.bodyText1?.merge(
                    TextStyle(fontWeight: FontWeight.bold),
                  ),
            ),
            accountEmail: Text(
              "${_session.student!.firstName} ${_session.student!.lastName}",
              style: Theme.of(context).textTheme.caption,
            ),
            arrowColor: Theme.of(context).textTheme.bodyText1!.color!,
            currentAccountPicture: GradientCircleAvatar(
              child: Text(
                "${_login.firstName} ${_login.lastName}".trim()[0],
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 28),
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
            onDetailsPressed: () {
              setState(() {
                _showUserDetails = !_showUserDetails;
              });
            },
            otherAccountsPictures: _session.students
                .map(
                  (s) => GradientCircleAvatar(
                      child: Text(
                        "${s.firstName} ${s.lastName}".trim()[0],
                        style: Theme.of(context).textTheme.bodyText1!,
                      ),
                      color: Theme.of(context).colorScheme.secondary),
                )
                .toList(),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: _drawerController,
              child: ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                style: ListTileStyle.drawer,
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 125),
                  crossFadeState: _showUserDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  secondChild: _buildUserDetail(),
                  firstChild: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      // shrinkWrap: true,
                      children: [
                        ..._buildDrawerItems(),
                        Divider(),
                        ListTile(
                          title: Text(context.locale.drawer.settings),
                          leading: Icon(Icons.settings),
                          onTap: () {
                            if (!MaybeMasterDetail.shouldBeShowingMaster(
                                context)) Navigator.pop(context);
                            Navigator.pushNamed(context, "settings");
                          },
                        ),
                        RegistroAboutListItem(),
                        ListTile(
                          title: Text(context.locale.drawer.logOut),
                          leading: Icon(Icons.exit_to_app),
                          onTap: () {
                            _showExitDialog(context);
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
    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    _initPanes(_session, _login);
    return UpdateScope(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: MaybeMasterDetail(
            master: () {
              final drawer = _getDrawer();
              if (drawer == null) return null;

              final child = drawer.child;

              return Scaffold(
                appBar: GradientAppBar(
                  title: Text(kIsWeb ? "Registro" : app.appName),
                ),
                extendBodyBehindAppBar: true,
                body: child,
              );
            }(),
            detail: PageTransitionSwitcher(
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                if (kIsWeb)
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                return FadeThroughTransition(
                  child: child,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedPane),
                child: Builder(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: _drawerItems[_selectedPane][2]
                          ? GradientAppBar(
                              title: _drawerItems[_selectedPane][1],
                              leading: MaybeMasterDetail.of(context)!
                                      .isShowingMaster
                                  ? null
                                  : Builder(builder: (context) {
                                      return IconButton(
                                        tooltip:
                                            MaterialLocalizations.of(context)
                                                .openAppDrawerTooltip,
                                        onPressed: () =>
                                            Scaffold.of(context).openDrawer(),
                                        icon: Icon(Icons.menu),
                                      );
                                    }),
                            )
                          : null,
                      drawer: MaybeMasterDetail.of(context)!.isShowingMaster
                          ? null
                          : _getDrawer(),
                      body: _loading
                          ? LoadingUI(colorful: true, showHints: true)
                          : Builder(builder: (context) {
                              return Actions(
                                actions: {
                                  MenuIntent: CallbackAction<MenuIntent>(
                                      onInvoke: (intent) {
                                    Scaffold.of(context).openDrawer();
                                    return null;
                                  })
                                },
                                child: _panes[_selectedPane],
                              );
                            }),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showExitDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(formatString(context.locale.main.logoutTitle,
          [_login.schoolTitle, _login.schoolName])),
      content: Text(context.locale.main.logoutBody),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
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

  void _switchToTab(int index) {
    _runCallback(index);
    setState(() {
      _selectedPane = index;
    });
  }

  void openDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
}
