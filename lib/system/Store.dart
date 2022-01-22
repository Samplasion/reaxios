import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/School/School.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/enums/GradeDisplay.dart';

part 'Store.g.dart';

class RegistroStore = _RegistroStore with _$RegistroStore;

abstract class _RegistroStore with Store {
  @observable
  School? school;
  @observable
  ObservableFuture<List<Assignment>>? assignments;
  @observable
  ObservableFuture<List<Grade>>? grades;
  @observable
  ObservableFuture<List<Topic>>? topics;
  @observable
  ObservableFuture<List<ReportCard>>? reportCards;
  @observable
  ObservableFuture<List<Bulletin>>? bulletins;
  @observable
  ObservableFuture<List<Period>>? periods;
  @observable
  ObservableFuture<List<Note>>? notes;
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

  fetchAssignments(Axios session) {
    if (assignments == null)
      assignments = ObservableFuture(session.getAssignments())
          .then(_successHandler)
          .catchError(_errorHandler<List<Assignment>>(<Assignment>[]));
  }

  fetchGrades(Axios session, [bool force = false]) {
    if (grades == null || force) {
      grades = null;
      grades = ObservableFuture(session.getGrades())
          .then(_successHandler)
          .catchError(_errorHandler<List<Grade>>(<Grade>[]));
    }
  }

  fetchTopics(Axios session) {
    if (topics == null)
      topics = ObservableFuture(session.getTopics())
          .then(_successHandler)
          .catchError(_errorHandler<List<Topic>>(<Topic>[]));
  }

  fetchReportCards(Axios session) {
    if (reportCards == null)
      reportCards = ObservableFuture(session.getReportCards())
          .then(_successHandler)
          .catchError(_errorHandler<List<ReportCard>>(<ReportCard>[]));
  }

  fetchBulletins(Axios session, [bool force = false]) {
    if (bulletins == null || force) {
      bulletins = null;
      bulletins = ObservableFuture(session.getBulletins())
          .then(_successHandler)
          .catchError(_errorHandler<List<Bulletin>>(<Bulletin>[]));
    }
  }

  fetchPeriods(Axios session) {
    if (periods == null)
      periods = ObservableFuture(session.getPeriods())
          .then(_successHandler)
          .catchError(_errorHandler<List<Period>>(<Period>[]));
    return periods;
  }

  fetchNotes(Axios session, [bool force = false]) {
    if (notes == null || force) {
      notes = null;
      notes = ObservableFuture(session.getNotes())
          .then(_successHandler)
          .catchError(_errorHandler<List<Note>>(<Note>[]));
    }
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

  Future<Period?> getCurrentPeriod(Axios session) async {
    if (session.account.schoolID.isEmpty) return null;
    final List<Period?> periods =
        (this.periods == null || this.periods!.error != null)
            ? await this.fetchPeriods(session)
            : await this.periods!;
    return periods.firstWhere((Period? period) {
      if (period == null) return false;
      return period.startDate.millisecondsSinceEpoch <
              DateTime.now().millisecondsSinceEpoch &&
          DateTime.now().millisecondsSinceEpoch <
              period.endDate.millisecondsSinceEpoch;
    }, orElse: () => null);
  }

  @action
  reset() {
    assignments = grades = topics = reportCards = bulletins = notes = null;
    networkError = false;
    testMode = false;
  }

  @action
  notificationPayloadAction(String? payload) {
    payloadController.add(payload);
  }
}
