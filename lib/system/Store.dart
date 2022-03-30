import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/enums/GradeDisplay.dart';

part 'Store.g.dart';

class RegistroStore = _RegistroStore with _$RegistroStore;

abstract class _RegistroStore with Store {
  @observable
  ObservableFuture<List<Absence>>? absences;
  @observable
  ObservableFuture<List<Authorization>>? authorizations;
  @observable
  ObservableFuture<List<MaterialTeacherData>>? materials;
  @observable
  ObservableFuture<List<String>>? subjects;
  @observable
  StreamController<String?> payloadController = StreamController<String?>();
  @observable
  GradeDisplay gradeDisplay = GradeDisplay.decimal;

  @observable
  bool testMode = false;

  @observable
  bool networkError = false;

  Future<T> Function(Object) _errorHandler<T>(T val) => (_) {
        networkError = true;
        return Future.value(val);
      };

  T _successHandler<T>(T value) {
    networkError = false;
    return value;
  }

  fetchAbsences(Axios session, [bool force = false]) {
    if (absences == null || force) {
      absences = null;
      absences = ObservableFuture(session.getAbsences())
          .then(_successHandler)
          .catchError(_errorHandler<List<Absence>>(<Absence>[]));
    }
  }

  fetchAuthorizations(Axios session, [bool force = false]) {
    if (authorizations == null || force) {
      authorizations = null;
      authorizations = ObservableFuture(session.getAuthorizations())
          .then(_successHandler)
          .catchError(_errorHandler<List<Authorization>>(<Authorization>[]));
    }
  }

  fetchMaterials(Axios session, [bool force = false]) {
    if (materials == null || force) {
      materials = null;
      materials = ObservableFuture(session.getMaterials())
          .then(_successHandler)
          .catchError(_errorHandler<List<MaterialTeacherData>>(
              <MaterialTeacherData>[]));
    }
  }

  fetchSubjects(Axios session, [bool force = false]) {
    if (subjects == null || force) {
      subjects = ObservableFuture(session.getSubjects())
          .then(_successHandler)
          .catchError(_errorHandler<List<String>>(<String>[]));
    }
  }

  @action
  notificationPayloadAction(String? payload) {
    payloadController.add(payload);
  }
}
