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

List<Pane> get panes => [
      Pane(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.overview")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.calendar")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.assignments")),
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
        titleBuilder: (context) => Text(context.loc.translate("drawer.grades")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.calculator")),
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
        titleBuilder: (context) => Text(context.loc.translate("drawer.topics")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.timetable")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.secretary")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.teacherNotes")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.notices")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.absences")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.authorizations")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.teacherMeetings")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.teachingMaterials")),
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
        titleBuilder: (context) => Text(context.loc.translate("drawer.stats")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.reportCards")),
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
        titleBuilder: (context) =>
            Text(context.loc.translate("drawer.curriculum")),
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
        titleBuilder: (context) => Text(context.loc.translate("drawer.info")),
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
        titleBuilder: (context) => Text("[DEBUG] Show colors"),
        usesManagedAppBar: true,
        builder: (context, session, login, _) => ColorsPane(),
        isShown: kDebugMode,
      ),
    ];

typedef Widget PaneBuilder(
  BuildContext context,
  Axios session,
  Login login,
  void Function(int) switchToTab,
);

class Pane {
  final Widget icon;
  final Widget? activeIcon;
  final WidgetBuilder titleBuilder;
  final bool usesManagedAppBar;
  final Future<void> Function(BuildContext)? onLoad;
  final PaneBuilder builder;
  final bool isShown;

  const Pane({
    required this.icon,
    this.activeIcon,
    required this.titleBuilder,
    required this.usesManagedAppBar,
    this.onLoad,
    required this.builder,
    this.isShown = true,
  });
}
