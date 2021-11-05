// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RegistroStore on _RegistroStore, Store {
  final _$schoolAtom = Atom(name: '_RegistroStore.school');

  @override
  School? get school {
    _$schoolAtom.reportRead();
    return super.school;
  }

  @override
  set school(School? value) {
    _$schoolAtom.reportWrite(value, super.school, () {
      super.school = value;
    });
  }

  final _$assignmentsAtom = Atom(name: '_RegistroStore.assignments');

  @override
  ObservableFuture<List<Assignment>>? get assignments {
    _$assignmentsAtom.reportRead();
    return super.assignments;
  }

  @override
  set assignments(ObservableFuture<List<Assignment>>? value) {
    _$assignmentsAtom.reportWrite(value, super.assignments, () {
      super.assignments = value;
    });
  }

  final _$gradesAtom = Atom(name: '_RegistroStore.grades');

  @override
  ObservableFuture<List<Grade>>? get grades {
    _$gradesAtom.reportRead();
    return super.grades;
  }

  @override
  set grades(ObservableFuture<List<Grade>>? value) {
    _$gradesAtom.reportWrite(value, super.grades, () {
      super.grades = value;
    });
  }

  final _$topicsAtom = Atom(name: '_RegistroStore.topics');

  @override
  ObservableFuture<List<Topic>>? get topics {
    _$topicsAtom.reportRead();
    return super.topics;
  }

  @override
  set topics(ObservableFuture<List<Topic>>? value) {
    _$topicsAtom.reportWrite(value, super.topics, () {
      super.topics = value;
    });
  }

  final _$reportCardsAtom = Atom(name: '_RegistroStore.reportCards');

  @override
  ObservableFuture<List<ReportCard>>? get reportCards {
    _$reportCardsAtom.reportRead();
    return super.reportCards;
  }

  @override
  set reportCards(ObservableFuture<List<ReportCard>>? value) {
    _$reportCardsAtom.reportWrite(value, super.reportCards, () {
      super.reportCards = value;
    });
  }

  final _$bulletinsAtom = Atom(name: '_RegistroStore.bulletins');

  @override
  ObservableFuture<List<Bulletin>>? get bulletins {
    _$bulletinsAtom.reportRead();
    return super.bulletins;
  }

  @override
  set bulletins(ObservableFuture<List<Bulletin>>? value) {
    _$bulletinsAtom.reportWrite(value, super.bulletins, () {
      super.bulletins = value;
    });
  }

  final _$periodsAtom = Atom(name: '_RegistroStore.periods');

  @override
  ObservableFuture<List<Period>>? get periods {
    _$periodsAtom.reportRead();
    return super.periods;
  }

  @override
  set periods(ObservableFuture<List<Period>>? value) {
    _$periodsAtom.reportWrite(value, super.periods, () {
      super.periods = value;
    });
  }

  final _$notesAtom = Atom(name: '_RegistroStore.notes');

  @override
  ObservableFuture<List<Note>>? get notes {
    _$notesAtom.reportRead();
    return super.notes;
  }

  @override
  set notes(ObservableFuture<List<Note>>? value) {
    _$notesAtom.reportWrite(value, super.notes, () {
      super.notes = value;
    });
  }

  final _$absencesAtom = Atom(name: '_RegistroStore.absences');

  @override
  ObservableFuture<List<Absence>>? get absences {
    _$absencesAtom.reportRead();
    return super.absences;
  }

  @override
  set absences(ObservableFuture<List<Absence>>? value) {
    _$absencesAtom.reportWrite(value, super.absences, () {
      super.absences = value;
    });
  }

  final _$authorizationsAtom = Atom(name: '_RegistroStore.authorizations');

  @override
  ObservableFuture<List<Authorization>>? get authorizations {
    _$authorizationsAtom.reportRead();
    return super.authorizations;
  }

  @override
  set authorizations(ObservableFuture<List<Authorization>>? value) {
    _$authorizationsAtom.reportWrite(value, super.authorizations, () {
      super.authorizations = value;
    });
  }

  final _$materialsAtom = Atom(name: '_RegistroStore.materials');

  @override
  ObservableFuture<List<MaterialTeacherData>>? get materials {
    _$materialsAtom.reportRead();
    return super.materials;
  }

  @override
  set materials(ObservableFuture<List<MaterialTeacherData>>? value) {
    _$materialsAtom.reportWrite(value, super.materials, () {
      super.materials = value;
    });
  }

  final _$networkErrorAtom = Atom(name: '_RegistroStore.networkError');

  @override
  bool get networkError {
    _$networkErrorAtom.reportRead();
    return super.networkError;
  }

  @override
  set networkError(bool value) {
    _$networkErrorAtom.reportWrite(value, super.networkError, () {
      super.networkError = value;
    });
  }

  final _$_RegistroStoreActionController =
      ActionController(name: '_RegistroStore');

  @override
  dynamic reset() {
    final _$actionInfo = _$_RegistroStoreActionController.startAction(
        name: '_RegistroStore.reset');
    try {
      return super.reset();
    } finally {
      _$_RegistroStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
school: ${school},
assignments: ${assignments},
grades: ${grades},
topics: ${topics},
reportCards: ${reportCards},
bulletins: ${bulletins},
periods: ${periods},
notes: ${notes},
absences: ${absences},
authorizations: ${authorizations},
materials: ${materials},
networkError: ${networkError}
    ''';
  }
}
