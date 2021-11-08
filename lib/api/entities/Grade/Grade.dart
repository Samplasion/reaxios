import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';
import 'package:reaxios/api/utils/DoubleSerializer.dart';
import 'package:reaxios/api/utils/utils.dart';

part 'Grade.g.dart';

// {
//     date: Date,
//     subject: string,
//     assignment: string
// }

@JsonSerializable()
class Grade implements AbstractJson {
  @JsonKey(name: "idVoto")
  String id;
  @JsonKey(name: "idMat")
  String subjectID;
  @JsonKey(name: "descMat")
  String subject;
  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;
  @JsonKey(name: "tipo")
  String kind;
  @JsonKey(name: "voto")
  String prettyGrade;
  @JsonKey(name: "votoValore")
  @DoubleSerializer()
  double grade;
  @JsonKey(name: "peso")
  @DoubleSerializer()
  double weight;
  @JsonKey(name: "commento")
  String comment;
  @JsonKey(name: "docente")
  String teacher;
  @JsonKey(name: "vistato")
  @BooleanSerializer()
  bool seen;
  @JsonKey(name: "vistatoUtente")
  String? seenBy;
  @JsonKey(name: "vistatoData")
  @DateSerializer()
  DateTime seenOn;

  String period = "";

  Grade({
    required this.id,
    required this.subjectID,
    required this.subject,
    required this.date,
    required this.kind,
    required this.prettyGrade,
    required this.grade,
    required this.weight,
    required this.comment,
    required this.teacher,
    required this.seen,
    required this.seenBy,
    required this.seenOn,
  });

  static empty() {
    return Grade(
      id: "",
      subjectID: "",
      subject: "",
      date: DateTime.now(),
      kind: "",
      prettyGrade: "",
      grade: 0,
      weight: 0,
      comment: "",
      teacher: "",
      seen: false,
      seenBy: "",
      seenOn: DateTime.now(),
    );
  }

  factory Grade.fakeFromDouble(double grade) {
    return Grade(
      id: "",
      subjectID: "",
      subject: "",
      date: DateTime.now(),
      kind: "",
      prettyGrade: isNaN(grade) ? "" : gradeToString(grade),
      grade: grade,
      weight: isNaN(grade) ? 0 : 1,
      comment: "",
      teacher: "",
      seen: false,
      seenBy: "",
      seenOn: DateTime.now(),
    );
  }

  factory Grade.test(
    double grade,
    String subject,
    String teacher,
    String comment, {
    String kind = "Orale",
    DateTime? date,
    bool seen = false,
  }) {
    return Grade(
      id: "83",
      subjectID: 'AC07A276-4B7F-413D-A122-67337F4360EE',
      subject: subject,
      date: date ?? DateTime.now(),
      kind: kind,
      prettyGrade: isNaN(grade) ? "" : gradeToString(grade),
      grade: grade,
      weight: 1,
      comment: comment,
      teacher: teacher,
      seen: seen,
      seenBy: "",
      seenOn: DateTime.now(),
    )..period = "I QUADRIMESTRE";
  }

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  normalize(Structural structural, String periodID) {
    final kinds = structural.gradeKinds[0].kinds;
    final periods = structural.periods[0].periods;

    this.weight = this.grade == 0 ? 0 : this.weight / 100;
    this.prettyGrade =
        /* this.weight == 0 ? this.prettyGrade : */ gradeToString(
            this.grade == 0 ? this.prettyGrade : this.grade);
    this.kind = kinds.firstWhere((element) => element.kind == this.kind).desc;
    this.period = periods
        .firstWhere((p) => p.id == periodID, orElse: () => periods[0])
        .desc;
  }

  @override
  String toString() {
    return 'Grade{id: $id, subjectID: $subjectID, subject: $subject, date: $date, kind: $kind, prettyGrade: $prettyGrade, grade: $grade, weight: $weight, comment: $comment, teacher: $teacher, seen: $seen, seenBy: $seenBy, seenOn: $seenOn}';
  }

  Map<String, dynamic> toJson() => _$GradeToJson(this);
}

@JsonSerializable()
class APIGrades {
  String idAlunno;
  String idFrazione;
  List<Grade> voti;

  APIGrades({
    required this.idAlunno,
    required this.idFrazione,
    required this.voti,
  });

  factory APIGrades.fromJson(Map<String, dynamic> json) =>
      _$APIGradesFromJson(json);

  Map<String, dynamic> toJson() => _$APIGradesToJson(this);
}
