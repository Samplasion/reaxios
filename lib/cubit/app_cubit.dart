// ignore_for_file: close_sinks

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/School/School.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/services/compute.dart';
import 'package:rxdart/rxdart.dart';

part 'app_cubit.g.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(AppState.empty());

  BehaviorSubject<int> loadingTasks = BehaviorSubject<int>.seeded(0);

  void load() => loadingTasks.add(loadingTasks.value + 1);
  void loaded() => loadingTasks.add(loadingTasks.value - 1);

  late Stream<bool> isEmpty = stream.map((state) => state.isEmpty);

  bool get hasAccount => state.axios?.account != null;
  School? get school => state.school;
  List<String> get subjects {
    final List<String> res = <String>[];
    topics.forEach((topic) {
      if (topic.subject.isNotEmpty) {
        res.add(topic.subject);
      }
    });
    assignments.forEach((assignment) {
      if (assignment.subject.isNotEmpty) {
        res.add(assignment.subject);
      }
    });

    return res.toSet().toList();
  }

  List<Assignment> get assignments => state.assignments ?? [];
  List<Grade> get grades => state.grades ?? [];
  List<Topic> get topics => state.topics ?? [];
  List<ReportCard> get reportCards => state.reportCards ?? [];
  List<Bulletin> get bulletins => state.bulletins ?? [];
  List<Note> get notes => state.notes ?? [];
  List<Absence> get absences => state.absences ?? [];
  List<Authorization> get authorizations => state.authorizations ?? [];
  List<MaterialTeacherData> get materials => state.materials ?? [];

  Structural? get structural => state.structural;
  List<Period> get periods => structural?.periods[0].periods ?? [];
  Period? get currentPeriod =>
      // ignore: unnecessary_cast
      (periods as List<Period?>)
          .firstWhere((period) => period!.isCurrent(), orElse: () => null);

  Future<Object?> login(AxiosAccount account) async {
    Axios axios;
    try {
      axios = Axios(account, compute: compute);
      await axios.login();
    } catch (e) {
      return e;
    }

    emit(state.copyWith(axios: axios));
    return null;
  }

  setSchool(School school) {
    emit(state.copyWith(school: school));
  }

  Future<void> loadObject(VoidFutureCallBack objectGetter) async {
    try {
      load();
      await objectGetter();
    } catch (e) {
      print(e);
    } finally {
      loaded();
    }
  }

  Future<void> loadAssignments() async {
    await loadObject(() async {
      final assignments = await state.axios!.getAssignments();
      emit(state.copyWith(assignments: assignments));
    });
  }

  Future<void> loadGrades() async {
    await loadObject(() async {
      final grades = await state.axios!.getGrades();
      emit(state.copyWith(grades: grades));
    });
  }

  Future<void> loadTopics() async {
    await loadObject(() async {
      final topics = await state.axios!.getTopics();
      emit(state.copyWith(topics: topics));
    });
  }

  Future<void> loadReportCards() async {
    await loadObject(() async {
      final reportCards = await state.axios!.getReportCards();
      emit(state.copyWith(reportCards: reportCards));
    });
  }

  Future<void> loadBulletins() async {
    await loadObject(() async {
      final bulletins = await state.axios!.getBulletins();
      emit(state.copyWith(bulletins: bulletins));
    });
  }

  Future<void> loadNotes() async {
    await loadObject(() async {
      final notes = await state.axios!.getNotes();
      emit(state.copyWith(notes: notes));
    });
  }

  Future<void> loadAbsences() async {
    await loadObject(() async {
      final absences = await state.axios!.getAbsences();
      emit(state.copyWith(absences: absences));
    });
  }

  Future<void> loadAuthorizations() async {
    await loadObject(() async {
      final authorizations = await state.axios!.getAuthorizations();
      emit(state.copyWith(authorizations: authorizations));
    });
  }

  Future<void> loadMaterials() async {
    await loadObject(() async {
      final materials = await state.axios!.getMaterials();
      emit(state.copyWith(materials: materials));
    });
  }

  Future<void> loadSubjects() async {
    await loadObject(() async {
      await loadTopics();
      await loadAssignments();
    });
  }

  Future<void> loadStructural() async {
    await loadObject(() async {
      final structural = await state.axios!.getStructural();
      emit(state.copyWith(structural: structural));
    });
  }

  void setTestMode(bool testMode) {
    emit(state.copyWith(testMode: testMode));
  }

  logout() {
    emit(AppState.empty());
  }

  clearData() {
    emit(AppState.empty().copyWith(axios: state.axios));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    return AppState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    return state.toJson();
  }

  @override
  void hydrate() {
    print("AppCubit: Hydrate AppCubit");
    super.hydrate();
  }
}
