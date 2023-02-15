import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Login/Login.dart';

import '../api/entities/Student/Student.dart';
import '../api/enums/NoteKind.dart';
import '../cubit/app_cubit.dart';
import '../utils/utils.dart';
import 'nav/Absences.dart';
import 'nav/Assignments.dart';
import 'nav/Authorizations.dart';
import 'nav/BulletinBoard.dart';
import 'nav/Calculator.dart';
import 'nav/Calendar.dart';
import 'nav/Grades.dart';
import 'nav/Info.dart';
import 'nav/Materials.dart';
import 'nav/Meetings.dart';
import 'nav/Overview.dart';
import 'nav/ReportCards.dart';
import 'nav/Reports.dart';
import 'nav/Stats.dart';
import 'nav/Timetable.dart';
import 'nav/Topics.dart';
import 'nav/colors.dart';
import 'nav/curriculum.dart';

List<Pane> get paneList => [
      Pane(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        titleKey: "drawer.overview",
        id: "overview",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadGrades().then((_) {
            cubit.loadAssignments();
          });
        },
        builder: (_, session, login, switchToTab) {
          return Builder(builder: (context) {
            return OverviewPane(
              session: session,
              login: login,
              student: session.student ?? Student.empty(),
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
              switchToTab: switchToTab,
            );
          });
        },
      ),
      Pane(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        titleKey: "drawer.calendar",
        id: "calendar",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadAssignments();
          cubit.loadTopics();
          cubit.loadStructural();
        },
        builder: (context, session, _, __) => CalendarPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.book_outlined),
        activeIcon: Icon(Icons.book),
        titleKey: "drawer.assignments",
        id: "assignments",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadAssignments();
        },
        builder: (_, session, login, switchToTab) {
          return Builder(
            builder: (context) => AssignmentsPane(
              session: session,
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
      Pane(
        icon: Icon(Icons.star_outline),
        activeIcon: Icon(Icons.star),
        titleKey: "drawer.grades",
        id: "grades",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadGrades();
          cubit.loadStructural();
          cubit.loadSubjects();
        },
        builder: (context, session, login, switchToTab) {
          final cubit = context.read<AppCubit>();
          return Builder(
            builder: (context) => GradesPane(
              session: session,
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
              period: cubit.currentPeriod,
            ),
          );
        },
      ),
      Pane(
        icon: Icon(Icons.calculate_outlined),
        activeIcon: Icon(Icons.calculate),
        titleKey: "drawer.calculator",
        id: "calculator",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadGrades();
          cubit.loadStructural();
          cubit.loadSubjects();
        },
        builder: (context, session, login, switchToTab) {
          final cubit = context.read<AppCubit>();
          return Builder(
            builder: (context) => CalculatorPane(
              session: session,
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
              period: cubit.currentPeriod,
            ),
          );
        },
      ),
      Pane(
        icon: Icon(Icons.topic_outlined),
        activeIcon: Icon(Icons.topic),
        titleKey: "drawer.topics",
        id: "topics",
        usesManagedAppBar: false,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadTopics();
        },
        builder: (context, session, login, switchToTab) {
          return Builder(
            builder: (context) => TopicsPane(
              session: session,
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
      Pane(
        icon: Icon(Icons.access_time_outlined),
        activeIcon: Icon(Icons.access_time),
        titleKey: "drawer.timetable",
        id: "timetable",
        usesManagedAppBar: false,
        builder: (context, session, login, switchToTab) {
          return Builder(
            builder: (context) => TimetablePane(
              openMainDrawer: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
      Pane(
        icon: Icon(Icons.mail_outlined),
        activeIcon: Icon(Icons.mail),
        titleKey: "drawer.secretary",
        id: "secretary",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadBulletins();
        },
        builder: (context, session, _, __) => BulletinsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.contact_mail_outlined),
        activeIcon: Icon(Icons.contact_mail),
        titleKey: "drawer.teacherNotes",
        id: "teacherNotes",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadNotes();
        },
        builder: (context, session, _, __) => NotesPane(
          session: session,
          kind: NoteKind.Note,
        ),
      ),
      Pane(
        icon: Icon(Icons.perm_contact_cal_outlined),
        activeIcon: Icon(Icons.perm_contact_cal),
        titleKey: "drawer.notices",
        id: "notices",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadNotes();
        },
        builder: (context, session, _, __) => NotesPane(
          session: session,
          kind: NoteKind.Notice,
        ),
      ),
      Pane(
        icon: Icon(Icons.no_accounts_outlined),
        activeIcon: Icon(Icons.no_accounts),
        titleKey: "drawer.absences",
        id: "absences",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadAbsences();
        },
        builder: (context, session, login, _) => AbsencesPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.edit_outlined),
        activeIcon: Icon(Icons.edit),
        titleKey: "drawer.authorizations",
        id: "authorizations",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadAuthorizations();
        },
        builder: (context, session, login, _) =>
            AuthorizationsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.terrain_outlined),
        activeIcon: Icon(Icons.terrain),
        titleKey: "drawer.teacherMeetings",
        id: "teacherMeetings",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadMeetings();
        },
        builder: (context, session, login, _) => MeetingsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.badge_outlined),
        activeIcon: Icon(Icons.badge),
        titleKey: "drawer.teachingMaterials",
        id: "teachingMaterials",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadMaterials();
        },
        builder: (context, session, login, _) =>
            MaterialsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.star_border),
        activeIcon: Icon(Icons.star_half),
        titleKey: "drawer.stats",
        id: "stats",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit
            ..loadAbsences()
            ..loadGrades()
            ..loadStructural()
            ..loadTopics();
        },
        builder: (context, session, login, _) => StatsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.gradient_outlined),
        activeIcon: Icon(Icons.gradient),
        titleKey: "drawer.reportCards",
        id: "reportCards",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit
            ..loadReportCards()
            ..loadStructural();
        },
        builder: (context, session, login, _) =>
            ReportCardsPane(session: session),
      ),
      Pane(
        icon: Icon(Icons.school_outlined),
        activeIcon: Icon(Icons.school),
        titleKey: "drawer.curriculum",
        id: "curriculum",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadCurricula();
        },
        builder: (context, session, login, _) => CurriculumPane(),
      ),
      Pane(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        titleKey: "drawer.info",
        id: "info",
        usesManagedAppBar: true,
        onLoad: (context) async {
          final cubit = context.read<AppCubit>();
          cubit.loadStructural();
        },
        builder: (context, session, login, _) => InfoPane(login: login),
      ),
      Pane(
        icon: Icon(Icons.color_lens_outlined),
        activeIcon: Icon(Icons.color_lens),
        titleKey: "[DEBUG] Show colors",
        id: "colors",
        usesManagedAppBar: true,
        builder: (context, session, login, _) => ColorsPane(),
        isShown: kDebugMode,
      ),
    ];
Map<String, Pane> get panes => {
      for (final pane in paneList) pane.id: pane,
    };

typedef Widget PaneBuilder(
  BuildContext context,
  Axios session,
  Login login,
  void Function(int) switchToTab,
);

class Pane {
  final Widget icon;
  final Widget? activeIcon;
  final String titleKey;
  final String id;
  final bool usesManagedAppBar;
  final Future<void> Function(BuildContext)? onLoad;
  final PaneBuilder builder;
  final bool isShown;

  Widget titleBuilder(BuildContext context) =>
      Text(context.loc.translate(titleKey));

  const Pane({
    required this.icon,
    this.activeIcon,
    required this.titleKey,
    required this.id,
    required this.usesManagedAppBar,
    this.onLoad,
    required this.builder,
    this.isShown = true,
  });
}
