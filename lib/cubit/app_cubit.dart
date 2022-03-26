// ignore_for_file: close_sinks

import 'dart:ui';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:rxdart/rxdart.dart';

import '../api/entities/School/School.dart';

part 'app_cubit.g.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(AppState.empty());

  BehaviorSubject<int> loadingTasks = BehaviorSubject<int>.seeded(0);

  void load() => loadingTasks.add(loadingTasks.value + 1);
  void loaded() => loadingTasks.add(loadingTasks.value - 1);

  bool get hasAccount => state.axios?.account != null;

  School? get school => state.school;

  List<Assignment> get assignments => state.assignments ?? [];
  List<Grade> get grades => state.grades ?? [];
  List<Topic> get topics => state.topics ?? [];
  List<ReportCard> get reportCards => state.reportCards ?? [];

  Future<Object?> login(AxiosAccount account) async {
    Axios axios;
    try {
      axios = Axios(account);
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
    loadObject(() async {
      final assignments = await state.axios!.getAssignments();
      emit(state.copyWith(assignments: assignments));
    });
  }

  Future<void> loadGrades() async {
    loadObject(() async {
      final grades = await state.axios!.getGrades();
      emit(state.copyWith(grades: grades));
    });
  }

  Future<void> loadTopics() async {
    loadObject(() async {
      final topics = await state.axios!.getTopics();
      emit(state.copyWith(topics: topics));
    });
  }

  Future<void> loadReportCards() async {
    loadObject(() async {
      final reportCards = await state.axios!.getReportCards();
      emit(state.copyWith(reportCards: reportCards));
    });
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
