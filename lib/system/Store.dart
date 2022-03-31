import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/enums/GradeDisplay.dart';

part 'Store.g.dart';

class RegistroStore = _RegistroStore with _$RegistroStore;

abstract class _RegistroStore with Store {
  @observable
  StreamController<String?> payloadController = StreamController<String?>();
  @observable
  GradeDisplay gradeDisplay = GradeDisplay.decimal;

  @observable
  bool testMode = false;

  @observable
  bool networkError = false;

  @action
  notificationPayloadAction(String? payload) {
    payloadController.add(payload);
  }
}
