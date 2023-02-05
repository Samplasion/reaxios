import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
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
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/LowLevel/lifecycle_reactor.dart';
import 'package:reaxios/components/LowLevel/m3_drawer.dart';
import 'package:reaxios/components/Utilities/updates/update_scope.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/i18n/delegate.dart';
import 'package:reaxios/screens/nav/Absences.dart';
import 'package:reaxios/screens/nav/Assignments.dart';
import 'package:reaxios/screens/nav/Authorizations.dart';
import 'package:reaxios/screens/nav/Calendar.dart';
import 'package:reaxios/screens/nav/Grades.dart';
import 'package:reaxios/screens/nav/Info.dart';
import 'package:reaxios/screens/nav/Materials.dart';
import 'package:reaxios/screens/nav/Reports.dart';
import 'package:reaxios/screens/nav/Overview.dart';
import 'package:reaxios/screens/nav/Stats.dart';
import 'package:reaxios/screens/nav/Topics.dart';
import 'package:reaxios/screens/nav/colors.dart';
import 'package:reaxios/services/compute.dart';
import 'package:reaxios/utils/storage.dart';
import 'package:reaxios/system/intents.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../system/AppInfoStore.dart';
import '../utils/tuple.dart';
import 'nav/BulletinBoard.dart';
import 'nav/Calculator.dart';
import 'nav/Meetings.dart';
import 'nav/ReportCards.dart';
import 'nav/Timetable.dart';
import 'nav/curriculum.dart';

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
  List<Tuple4<Tuple2<Widget, Widget>, Widget, bool, Function?>> _drawerItems =
      [];
  int _selectedPane = 0;

  bool appIsActive = true;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });

    _checkConnection(15000)();
  }

  FutureOr<dynamic> Function() _checkConnection(int delay) {
    return () async {
      if (kIsWeb) return;
      if (!appIsActive) return;
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
      if (_drawerItems[index].fourth != null &&
          _drawerItems[index].fourth is Function)
        await _drawerItems[index].fourth!();
    } catch (e) {
      print(e);
      // Do nothing; the HydratedCubit will have stale data, but at least
      // the app will run.
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    debugPrint("[${widget.runtimeType}] Calling reassemble()...");
    AppLocalizations.of(context).load().then((value) {
      if (mounted) {
        if (value) {
          context.showSnackbar("Reloaded strings!");
        } else {
          context.showSnackbarError("Couldn't reload strings!");
        }
      }
    });
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
        CurriculumPane(),
        InfoPane(login: _login),
        if (kDebugMode) ColorsPane(),
      ];
      _drawerItems = [
        [
          Tuple2(Icon(Icons.home_outlined), Icon(Icons.home)),
          Text(context.loc.translate("drawer.overview")),
          false,
          () async {
            cubit.loadGrades().then((_) {
              cubit.loadAssignments();
            });
          }
        ],
        [
          Tuple2(
              Icon(Icons.calendar_today_outlined), Icon(Icons.calendar_today)),
          Text(context.loc.translate("drawer.calendar")),
          false,
          () {
            cubit.loadAssignments();
            cubit.loadTopics();
            cubit.loadStructural();
          }
        ],
        [
          Tuple2(Icon(Icons.book_outlined), Icon(Icons.book)),
          Text(context.loc.translate("drawer.assignments")),
          false,
          () => cubit.loadAssignments(),
        ],
        [
          Tuple2(Icon(Icons.star_border), Icon(Icons.star)),
          Text(context.loc.translate("drawer.grades")),
          false,
          () {
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadSubjects();
          }
        ],
        [
          Tuple2(Icon(Icons.calculate_outlined), Icon(Icons.calculate)),
          Text(context.loc.translate("drawer.calculator")),
          false,
          () {
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadSubjects();
          }
        ],
        [
          Tuple2(Icon(Icons.topic_outlined), Icon(Icons.topic)),
          Text(context.loc.translate("drawer.topics")),
          false,
          () => cubit.loadTopics(),
        ],
        [
          Tuple2(Icon(Icons.access_time_outlined), Icon(Icons.access_time)),
          Text(context.loc.translate("drawer.timetable")),
          false,
          () {},
        ],
        [
          Tuple2(Icon(Icons.mail_outlined), Icon(Icons.mail)),
          Text(context.loc.translate("drawer.secretary")),
          true,
          () => cubit.loadBulletins(),
        ],
        [
          Tuple2(Icon(Icons.contact_mail_outlined), Icon(Icons.contact_mail)),
          Text(context.loc.translate("drawer.teacherNotes")),
          true,
          () => cubit.loadNotes(),
        ],
        [
          Tuple2(Icon(Icons.perm_contact_cal_outlined),
              Icon(Icons.perm_contact_cal)),
          Text(context.loc.translate("drawer.notices")),
          true,
          () => cubit.loadNotes(),
        ],
        [
          Tuple2(Icon(Icons.no_accounts_outlined), Icon(Icons.no_accounts)),
          Text(context.loc.translate("drawer.absences")),
          true,
          () => cubit.loadAbsences()
        ],
        [
          Tuple2(Icon(Icons.edit_outlined), Icon(Icons.edit)),
          Text(context.loc.translate("drawer.authorizations")),
          true,
          () => cubit.loadAuthorizations()
        ],
        [
          Tuple2(Icon(Icons.terrain_outlined), Icon(Icons.terrain)),
          Text(context.loc.translate("drawer.teacherMeetings")),
          true,
          () => cubit.loadMeetings()
        ],
        [
          Tuple2(Icon(Icons.badge_outlined), Icon(Icons.badge)),
          Text(context.loc.translate("drawer.teachingMaterials")),
          true,
          () => cubit.loadMaterials()
        ],
        [
          Tuple2(Icon(Icons.star_border), Icon(Icons.star_half)),
          Text(context.loc.translate("drawer.stats")),
          true,
          () {
            cubit.loadAbsences();
            cubit.loadGrades();
            cubit.loadStructural();
            cubit.loadTopics();
          }
        ],
        [
          Tuple2(Icon(Icons.gradient_outlined), Icon(Icons.gradient)),
          Text(context.loc.translate("drawer.reportCards")),
          true,
          () {
            cubit.loadReportCards();
            cubit.loadStructural();
          }
        ],
        [
          Tuple2(Icon(Icons.school_outlined), Icon(Icons.school)),
          Text(context.loc.translate("drawer.curriculum")),
          true,
          () {
            cubit.loadCurricula();
          }
        ],
        [
          Tuple2(Icon(Icons.person_outlined), Icon(Icons.person)),
          Text(context.loc.translate("drawer.info")),
          true,
          () {
            cubit.loadStructural();
          }
        ],
        if (kDebugMode)
          [
            Tuple2(Icon(Icons.color_lens_outlined), Icon(Icons.color_lens)),
            Text("[DEBUG] Show colors"),
            true,
            () {},
          ],
      ]
          .map((el) => Tuple4<Tuple2<Widget, Widget>, Widget, bool,
              Function>.fromIterable(el))
          .toList();
    });
  }

  Future<void> launchWeb(BuildContext context) async {
    context.showSnackbar(context.loc.translate("main.loading"));
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
      try {
        throw "";
      } catch (e) {
        print(e);
        context.hideCurrentSnackBar();
        context.showSnackbarError(
          context.loc.translate("main.failedLinkOpen"),
          action: SnackBarAction(
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
      context.showSnackbarError(
        context.loc.translate("main.webVersionError"),
      );
    }
  }

  List<Widget> _buildDrawerItems() {
    // final width = MediaQuery.of(context).size.width;
    List<Widget> items = [];
    for (var index = 0; index < _drawerItems.length; index++) {
      items.add(M3DrawerListTile(
        icon: _drawerItems[index].first.first,
        selectedIcon: _drawerItems[index].first.second,
        title: _drawerItems[index].second,
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

  Drawer? _getDrawer(bool loading, bool scrim) {
    if (loading) return null;

    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    return Drawer(
      elevation: scrim ? Drawer().elevation : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        clipBehavior: Clip.hardEdge,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            // shrinkWrap: true,
            children: [
              SizedBox(height: 16),
              M3DrawerHeading(kIsWeb
                  ? context.loc.translate("about.appName")
                  : app.appName),
              SizedBox(height: 16),
              for (final s in _session.students)
                Builder(builder: (context) {
                  return M3DrawerListTile(
                    icon: Icon(Icons.person_outlined),
                    selectedIcon: Icon(Icons.person),
                    title: Text("${s.firstName} ${s.lastName}"),
                    selected: s.studentUUID ==
                        context.read<AppCubit>().student?.studentUUID,
                    onTap: () {
                      if (!MaybeMasterDetail.of(context)!.isShowingMaster)
                        Navigator.pop(context);
                      if (s.studentUUID ==
                          context.read<AppCubit>().student?.studentUUID) return;
                      final storage = context.read<Storage>();
                      storage.setLastStudentID(s.studentUUID);
                      _session.student = s;
                      context.read<AppCubit>().clearData();
                      context.read<AppCubit>().setStudent(s);
                      setState(() {
                        _showUserDetails = false;
                        _initPanes(_session, _login);
                      });
                      _runCallback(_selectedPane);
                    },
                  );
                }),
              Divider(
                height: 33,
                indent: 28,
                endIndent: 28,
              ),
              M3DrawerHeading(context.loc.translate("drawer.destinations")),
              SizedBox(height: 16),
              ..._buildDrawerItems(),
              Builder(
                builder: (context) => M3DrawerListTile(
                  title: Text(context.loc.translate("drawer.webVersion")),
                  icon: Icon(Icons.public),
                  onTap: () {
                    launchWeb(context);
                  },
                ),
              ),
              if (kDebugMode) ...[
                M3DrawerListTile(
                  title: Text("[DEBUG] Show no Internet page"),
                  icon: Icon(Icons.wifi_off),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "nointernet");
                  },
                ),
              ],
              ...showEndOfDrawerItems(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AppCubit>();
    _initPanes(_session, _login);

    return LifecycleReactor(
      onChange: (state) => setState(() {
        appIsActive = state == AppLifecycleState.resumed;
      }),
      child: BlocBuilder<AppCubit, AppState>(
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

                    final drawer =
                        (_getDrawer(isLoading, false)?.child! as Container)
                            .child;

                    return Material(
                      child: isLoading ? null : drawer,
                    );
                  }(),
                  detail: _buildDetailView(state),
                ),
              ),
            ),
          );
        },
      ),
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
                return StreamBuilder(
                    stream: MaybeMasterDetail.getShowingStream(context),
                    builder: (context, AsyncSnapshot<bool> state) {
                      final showingMaster = state.data ?? false;
                      return Scaffold(
                        appBar: _drawerItems[_selectedPane].third
                            ? AppBar(
                                title: _drawerItems[_selectedPane].second,
                                leading: MaybeMasterDetail.of(context)!
                                        .isShowingMaster
                                    ? null
                                    : Builder(builder: (context) {
                                        return IconButton(
                                          tooltip:
                                              MaterialLocalizations.of(context)
                                                  .openAppDrawerTooltip,
                                          onPressed: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          icon: Icon(Icons.menu),
                                        );
                                      }),
                              )
                            : null,
                        drawer: showingMaster ? null : _getDrawer(false, true),
                        // drawerEnableOpenDragGesture:
                        //     !MaybeMasterDetail.of(context)!.isShowingMaster,
                        body: isLoading
                            ? Scaffold(
                                appBar: AppBar(
                                  title: Text(
                                      context.loc.translate("about.appName")),
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
              var cardTheme = Theme.of(context).cardTheme;
              final child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: ElevationOverlay.applySurfaceTint(
                      cardTheme.color ?? Theme.of(context).cardColor,
                      cardTheme.surfaceTintColor,
                      cardTheme.elevation ?? 4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
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

  void _switchToTab(int index) {
    _runCallback(index);
    setState(() {
      _selectedPane = index;
    });
  }

  void openDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
}
