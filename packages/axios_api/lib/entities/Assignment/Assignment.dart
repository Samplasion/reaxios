import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/interfaces/AbstractJson.dart';
import 'package:axios_api/utils/DateSerializer.dart';
import 'package:axios_api/utils/IntSerializer.dart';

part 'Assignment.g.dart';

enum AssignmentType {
  test,
  homework,
}

@JsonSerializable()
class Assignment extends Equatable implements AbstractJson {
  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;
  @JsonKey(name: "data_pubblicazione")
  @DateSerializer()
  DateTime publicationDate;
  @JsonKey(name: "descMat")
  String subject;
  @JsonKey(name: "oreLezione")
  @IntSerializer()
  int? lessonHour;
  @JsonKey(name: "idCompito")
  String id;
  @JsonKey(name: "descCompiti")
  String assignmentRaw;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get assignment =>
      assignmentRaw.replaceFirst("<b>Verifica</b>", "").trim();

  @JsonKey(includeFromJson: false, includeToJson: false)
  AssignmentType get type => assignmentRaw.contains("<b>Verifica</b>")
      ? AssignmentType.test
      : AssignmentType.homework;

  Assignment({
    required this.date,
    required this.publicationDate,
    required this.subject,
    required this.lessonHour,
    required this.id,
    required this.assignmentRaw,
  });

  static empty() {
    return Assignment(
      date: DateTime.now(),
      publicationDate: DateTime.now(),
      subject: "",
      lessonHour: 0,
      id: "",
      assignmentRaw: "",
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);

  @override
  String toString() {
    return 'Assignment{date: $date, publicationDate: $publicationDate, subject: $subject, lessonHour: $lessonHour, id: $id, assignment: $assignment, type: $type}';
  }

  static test() {
    return Assignment(
      date: DateTime.now(),
      publicationDate: DateTime.now(),
      subject: "Matematica",
      lessonHour: 2,
      id: "4",
      assignmentRaw: "Verifica sistemi",
    );
  }

  @override
  List<Object?> get props => [
        date,
        publicationDate,
        subject,
        lessonHour,
        id,
        assignmentRaw,
      ];
}

@JsonSerializable()
class APIAssignments {
  String idAlunno;
  List<Assignment> compiti;

  APIAssignments({
    required this.idAlunno,
    required this.compiti,
  });

  factory APIAssignments.fromJson(Map<String, dynamic> json) =>
      _$APIAssignmentsFromJson(json);

  Map<String, dynamic> toJson() => _$APIAssignmentsToJson(this);
}
