// ignore_for_file: close_sinks

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:rxdart/rxdart.dart';

import '../api/entities/School/School.dart';

part 'app_cubit.g.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(AppState.empty());

  bool get hasAccount => state.axios?.account != null;

  School? get school => state.school;

  // BehaviorSubject<List<Assignment>> assignments = BehaviorSubject();
  List<Assignment> get assignments => state.assignments ?? [];

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
    final assignments = await state.axios!.getAssignments();
    // this.assignments.add(assignments);
    emit(state.copyWith(assignments: assignments));
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
