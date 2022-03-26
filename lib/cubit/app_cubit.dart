// ignore_for_file: close_sinks

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
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

  Future<void> loadAssignments() async {
    try {
      load();
      final assignments = await state.axios!.getAssignments();
      emit(state.copyWith(assignments: assignments));
    } catch (e) {
      print(e);
    } finally {
      loaded();
    }
  }

  Future<void> loadGrades() async {
    try {
      load();
      final grades = await state.axios!.getGrades();
      emit(state.copyWith(grades: grades));
    } catch (e) {
      print(e);
    } finally {
      loaded();
    }
  }

  Future<void> loadTopics() async {
    try {
      load();
      final topics = await state.axios!.getTopics();
      emit(state.copyWith(topics: topics));
    } catch (e) {
      print(e);
    } finally {
      loaded();
    }
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
