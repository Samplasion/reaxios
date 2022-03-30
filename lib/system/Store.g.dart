// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RegistroStore on _RegistroStore, Store {
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

  final _$subjectsAtom = Atom(name: '_RegistroStore.subjects');

  @override
  ObservableFuture<List<String>>? get subjects {
    _$subjectsAtom.reportRead();
    return super.subjects;
  }

  @override
  set subjects(ObservableFuture<List<String>>? value) {
    _$subjectsAtom.reportWrite(value, super.subjects, () {
      super.subjects = value;
    });
  }

  final _$payloadControllerAtom =
      Atom(name: '_RegistroStore.payloadController');

  @override
  StreamController<String?> get payloadController {
    _$payloadControllerAtom.reportRead();
    return super.payloadController;
  }

  @override
  set payloadController(StreamController<String?> value) {
    _$payloadControllerAtom.reportWrite(value, super.payloadController, () {
      super.payloadController = value;
    });
  }

  final _$gradeDisplayAtom = Atom(name: '_RegistroStore.gradeDisplay');

  @override
  GradeDisplay get gradeDisplay {
    _$gradeDisplayAtom.reportRead();
    return super.gradeDisplay;
  }

  @override
  set gradeDisplay(GradeDisplay value) {
    _$gradeDisplayAtom.reportWrite(value, super.gradeDisplay, () {
      super.gradeDisplay = value;
    });
  }

  final _$testModeAtom = Atom(name: '_RegistroStore.testMode');

  @override
  bool get testMode {
    _$testModeAtom.reportRead();
    return super.testMode;
  }

  @override
  set testMode(bool value) {
    _$testModeAtom.reportWrite(value, super.testMode, () {
      super.testMode = value;
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
  dynamic notificationPayloadAction(String? payload) {
    final _$actionInfo = _$_RegistroStoreActionController.startAction(
        name: '_RegistroStore.notificationPayloadAction');
    try {
      return super.notificationPayloadAction(payload);
    } finally {
      _$_RegistroStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
absences: ${absences},
authorizations: ${authorizations},
materials: ${materials},
subjects: ${subjects},
payloadController: ${payloadController},
gradeDisplay: ${gradeDisplay},
testMode: ${testMode},
networkError: ${networkError}
    ''';
  }
}
