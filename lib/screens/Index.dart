import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide compute;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/TestAxios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/ListItems/RegistroAboutListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/Utilities/updates/update_scope.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/screens/nav/Absences.dart';
import 'package:reaxios/screens/nav/Assignments.dart';
import 'package:reaxios/screens/nav/Authorizations.dart';
import 'package:reaxios/screens/nav/Calendar.dart';
import 'package:reaxios/screens/nav/Grades.dart';
import 'package:reaxios/screens/nav/Materials.dart';
import 'package:reaxios/screens/nav/Reports.dart';
import 'package:reaxios/screens/nav/Overview.dart';
import 'package:reaxios/screens/nav/Stats.dart';
import 'package:reaxios/screens/nav/Topics.dart';
import 'package:reaxios/services/compute.dart';
import 'package:reaxios/storage.dart';
import 'package:reaxios/system/intents.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../consts.dart';
import '../system/AppInfoStore.dart';
import 'nav/BulletinBoard.dart';
import 'nav/Calculator.dart';
import 'nav/Meetings.dart';
import 'nav/ReportCards.dart';
import 'nav/Timetable.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();

  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Axios _session = new Axios(new AxiosAccount("", "", ""), compute: compute);
  Login _login = Login.empty();
  bool _showUserDetails = false;

  List<Widget> _panes = [];
  List<List<dynamic>> _drawerItems = [];
  int _selectedPane = 0;

  ScrollController _drawerController = ScrollController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _initSession();
    });

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
    final cubit = context.read<AppCubit>();
    final storage = context.read<Storage>();
    if (!cubit.state.testMode) {
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
      _session = Axios(AxiosAccount(school, user, Encrypter.decrypt(pass)),
          compute: compute);
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
    final lastStudentID = storage.getLastStudentID();
    print(lastStudentID);
    if (lastStudentID != null &&
        _session.students
            .any((element) => element.studentUUID == lastStudentID)) {
      _session.student = _session.students.firstWhere(
        (element) => element.studentUUID == lastStudentID,
      );
      cubit.setStudent(_session.student!);
    }

    _initPanes(_session, _login);

    await context.read<AppCubit>().loadStructural();
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
    try {
      if (_drawerItems[index][3] != null && _drawerItems[index][3] is Function)
        await _drawerItems[index][3]();
    } catch (e) {
      print(e);
      // Do nothing; the HydratedCubit will have stale data, but at least
      // the app will run.
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _initPanes(Axios session, Login login) {
    final cubit = context.read<AppCubit>();
    setState(() {
      _panes = [
        Builder(
          builder: (context) => OverviewPane(
            session: session,
            login: login,
            student: session.student ?? Student.empty(),
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
            switchToTab: _switchToTab,
          ),
        ),
        CalendarPane(session: session),
        Builder(
          builder: (context) => AssignmentsPane(
            session: session,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Builder(
          builder: (context) => GradesPane(
            session: session,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
            period: cubit.currentPeriod,
          ),
        ),
        Builder(
          builder: (context) => CalculatorPane(
            session: session,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
            period: cubit.currentPeriod,
          ),
        ),
        Builder(
          builder: (context) => TopicsPane(
            session: session,
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Builder(
          builder: (context) => TimetablePane(
            openMainDrawer: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        BulletinsPane(session: session),
        NotesPane(
          session: session,
          kind: NoteKind.Note,
        ),
        NotesPane(
          session: session,
          kind: NoteKind.Notice,
        ),
        AbsencesPane(session: session),
        AuthorizationsPane(session: session),
        MeetingsPane(session: session),
        MaterialsPane(session: session),
        StatsPane(session: session),
        ReportCardsPane(session: session),
      ];
      _drawerItems = [
        [
          Icon(Icons.home),
          Text(context.locale.drawer.overview),
          false,
          () async {
            cubit.loadAssignments();
            cubit.loadGrades();
            cubit.loadTopics();
          }
        ],
        [
          Icon(Icons.calendar_today),
          Text(context.locale.drawer.calendar),
          false,
          () {
            cubit.loadAssignments();
            cubit.loadTopics();
            cubit.loadStructural();
          }
        ],
        [
          Icon(Icons.book),
          Text(context.locale.drawer.assignments),
          false,
          () => cubit.loadAssignments(),
        ],
        [
          Icon(Icons.star),
          Text(context.locale.drawer.grades),
          false,
          () {
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadSubjects();
          }
        ],
        [
          Icon(Icons.calculate),
          Text(context.locale.drawer.calculator),
          false,
          () {
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadSubjects();
          }
        ],
        [
          Icon(Icons.topic),
          Text(context.locale.drawer.topics),
          false,
          () => cubit.loadTopics(),
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
          () => cubit.loadBulletins(),
        ],
        [
          Icon(Icons.contact_mail),
          Text(context.locale.drawer.teacherNotes),
          true,
          () => cubit.loadNotes(),
        ],
        [
          Icon(Icons.perm_contact_cal),
          Text(context.locale.drawer.notices),
          true,
          () => cubit.loadNotes(),
        ],
        [
          Icon(Icons.no_accounts),
          Text(context.locale.drawer.absences),
          true,
          () => cubit.loadAbsences()
        ],
        [
          Icon(Icons.edit),
          Text(context.locale.drawer.authorizations),
          true,
          () => cubit.loadAuthorizations()
        ],
        [
          Icon(Icons.terrain),
          Text(context.locale.drawer.teacherMeetings),
          true,
          () => cubit.loadMeetings()
        ],
        [
          Icon(Icons.badge),
          Text(context.locale.drawer.teachingMaterials),
          true,
          () => cubit.loadMaterials()
        ],
        [
          Icon(Icons.star_outline),
          Text(context.locale.drawer.stats),
          true,
          () {
            cubit.loadAbsences();
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadTopics();
          }
        ],
        [
          Icon(Icons.gradient),
          Text(context.locale.drawer.reportCards),
          true,
          () {
            cubit.loadReportCards();
            cubit.loadStructural();
          }
        ],
      ];
    });
  }

  Student _getStudent() {
    return _session.students.length > 0 ? _session.student : Student.empty();
  }

  Future<void> launchWeb(BuildContext context) async {
    context.showSnackbar(context.locale.main.loading);
    try {
      final res = await _session.getWebVersionUrl();

      final html = """
        <html>
          <head></head>
          <body>
            <form id="loginForm" action="${res["url"]}" method="post">
              <input type="hidden" name="parameters" value="${res["parameters"]}">
              <input type="hidden" name="action" value="${res["action"]}">
            </form>
            <script type="text/javascript">document.getElementById("loginForm").submit();</script>
          </body>
        </html>""";
      final url = "data:text/html;base64,${base64.encode(utf8.encode(html))}";
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        context.hideCurrentSnackBar();
        context.showSnackbar(
          context.locale.main.failedLinkOpen,
          backgroundColor: Colors.red,
          style: TextStyle(color: Colors.red.contrastText),
          action: SnackBarAction(
            textColor: Colors.red.contrastText,
            label: context.materialLocale.copyButtonLabel,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
            },
          ),
        );
      }
    } catch (e) {
      print(e);
      context.hideCurrentSnackBar();
      context.showSnackbar(
        context.locale.main.webVersionError,
        backgroundColor: Colors.red,
        style: TextStyle(color: Colors.red.contrastText),
      );
    }
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
            selected:
                s.studentUUID == context.read<AppCubit>().student?.studentUUID,
            onTap: () {
              final storage = context.read<Storage>();
              storage.setLastStudentID(s.studentUUID);
              if (!MaybeMasterDetail.of(context)!.isShowingMaster)
                Navigator.pop(context);
              _session.student = s;
              context.read<AppCubit>().clearData();
              context.read<AppCubit>().setStudent(s);
              _runCallback(_selectedPane);
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

  Drawer? _getDrawer(bool loading) {
    if (loading) return null;

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
              _session.student == null
                  ? "Null student! Please report"
                  : "${_session.student!.firstName} ${_session.student!.lastName}",
              style: Theme.of(context).textTheme.caption,
            ),
            arrowColor: Theme.of(context).textTheme.bodyText1!.color!,
            currentAccountPicture: GradientCircleAvatar(
              child: Text(
                "${_login.firstName} ${_login.lastName}.".trim()[0],
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
                        Builder(
                          builder: (context) => ListTile(
                            title: Text(context.locale.drawer.webVersion),
                            leading: Icon(Icons.public),
                            onTap: () {
                              launchWeb(context);
                            },
                          ),
                        ),
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
    final cubit = context.watch<AppCubit>();
    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    _initPanes(_session, _login);

    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        final isLoading = _loading || state.isEmpty;
        return UpdateScope(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: MaybeMasterDetail(
                master: () {
                  if (isLoading) return null;

                  final drawer = _getDrawer(isLoading);
                  if (drawer == null) return null;

                  final child = drawer.child;

                  return Scaffold(
                    appBar: GradientAppBar(
                      title: Text(
                        kIsWeb ? context.locale.about.appName : app.appName,
                      ),
                    ),
                    extendBodyBehindAppBar: true,
                    body: child,
                  );
                }(),
                detail: _buildDetailView(state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailView(AppState state) {
    final cubit = context.watch<AppCubit>();
    final isLoading = _loading || state.isEmpty;
    return PageTransitionSwitcher(
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
      child: Stack(
        children: [
          KeyedSubtree(
            key: ValueKey(_selectedPane),
            child: Builder(
              builder: (BuildContext context) {
                final drawer = _getDrawer(false);
                return StreamBuilder(
                    stream: MaybeMasterDetail.getShowingStream(context),
                    builder: (context, AsyncSnapshot<bool> state) {
                      final showingMaster = state.data ?? false;
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
                                          onPressed: () {
                                            print(drawer);
                                            Scaffold.of(context).openDrawer();
                                          },
                                          icon: Icon(Icons.menu),
                                        );
                                      }),
                              )
                            : null,
                        drawer: showingMaster ? null : drawer,
                        // drawerEnableOpenDragGesture:
                        //     !MaybeMasterDetail.of(context)!.isShowingMaster,
                        body: isLoading
                            ? Scaffold(
                                appBar: GradientAppBar(
                                  title: Text(context.locale.about.appName),
                                ),
                                body: LoadingUI(
                                  showHints: true,
                                ),
                              )
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
                    });
              },
            ),
          ),
          StreamBuilder<int>(
            stream: cubit.loadingTasks,
            builder: (context, state) {
              final child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    boxShadow: kElevationToShadow[4],
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: CupertinoActivityIndicator(),
                ),
              );
              return AnimatedCrossFade(
                crossFadeState: (state.data ?? 0) < 1
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: child,
                secondChild: Opacity(
                  opacity: 0,
                  child: child,
                ),
                duration: Duration(milliseconds: 500),
              );
            },
          ),
        ],
        alignment: Alignment.bottomLeft,
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
            context.read<AppCubit>().logout();

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
