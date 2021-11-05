import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';
import 'package:reaxios/api/utils/IntSerializer.dart';

part 'Authorization.g.dart';

@JsonSerializable()
class Authorization implements AbstractJson {
  // num id;
  @JsonKey(name: "idPermesso")
  String id;

  @JsonKey(name: "tipo")
  String rawKind;

  @JsonKey(ignore: true)
  String kind = "";

  @JsonKey(name: "dataInizio")
  @DateSerializer()
  DateTime startDate;

  @JsonKey(name: "dataFine")
  @DateSerializer()
  DateTime endDate;

  @JsonKey(name: "ora")
  @IntSerializer()
  int rawLessonHour;
  int? get lessonHour => rawLessonHour == 0 ? null : rawLessonHour;

  @JsonKey(name: "orario")
  @DateSerializer()
  DateTime time;

  @JsonKey(name: "motivo")
  String reason;

  @JsonKey(name: "note")
  String notes;

  @JsonKey(name: "calcolo")
  @BooleanSerializer()
  bool concurs;

  @JsonKey(name: "giustificato")
  @BooleanSerializer()
  bool justified;

  @JsonKey(name: "classe")
  @BooleanSerializer()
  bool entireClass;

  @JsonKey(name: "utenteInserimento")
  String insertedBy;

  @JsonKey(name: "utenteAutorizzazione")
  String authorizedBy;

  @JsonKey(name: "dataAutorizzazione")
  @DateSerializer()
  DateTime authorizedDate;

  @JsonKey(ignore: true)
  late Axios session;

  @JsonKey(ignore: true)
  late String period;

  Authorization({
    required this.id,
    required this.rawKind,
    required this.startDate,
    required this.endDate,
    required this.rawLessonHour,
    required this.time,
    required this.reason,
    required this.notes,
    required this.concurs,
    required this.justified,
    required this.entireClass,
    required this.insertedBy,
    required this.authorizedBy,
    required this.authorizedDate,
  });

  static empty() {
    return Authorization(
      id: '',
      rawKind: '',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      rawLessonHour: 0,
      time: DateTime.now(),
      reason: '',
      notes: '',
      concurs: false,
      justified: false,
      entireClass: false,
      insertedBy: '',
      authorizedBy: '',
      authorizedDate: DateTime.now(),
    );
  }

  factory Authorization.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationFromJson(json);

  Authorization setSession(Axios session) {
    this.session = session;
    return this;
  }

  Authorization setPeriod(String period) {
    this.period = period;
    return this;
  }

  Authorization setKinds(Structural structural) {
    this.kind = structural.authorizationKinds
        .firstWhere((element) => element.kind == this.rawKind,
            orElse: () => SimpleKind.empty())
        .desc;
    return this;
  }

  Map<String, dynamic> toJson() => _$AuthorizationToJson(this);

  Future<bool> justify() async {
    return await session.justifyAuthorization(this);
  }

  @override
  String toString() {
    return 'Authorization{id: $id, rawKind: $rawKind, kind: $kind, startDate: $startDate, endDate: $endDate, rawLessonHour: $rawLessonHour, time: $time, reason: $reason, notes: $notes, concurs: $concurs, justified: $justified, entireClass: $entireClass, insertedBy: $insertedBy, authorizedBy: $authorizedBy, authorizedDate: $authorizedDate, session: $session, period: $period}';
  }
}

@JsonSerializable()
class Request implements AbstractJson {}

@JsonSerializable()
class APIAuthorizations {
  String idAlunno;
  List<Authorization> permessiDaAutorizzare;
  List<Authorization> permessiAutorizzati;

  APIAuthorizations({
    required this.idAlunno,
    required this.permessiDaAutorizzare,
    required this.permessiAutorizzati,
  });

  factory APIAuthorizations.fromJson(Map<String, dynamic> json) =>
      _$APIAuthorizationsFromJson(json);

  Map<String, dynamic> toJson() => _$APIAuthorizationsToJson(this);
}
