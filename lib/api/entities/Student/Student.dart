import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/Gender.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';
import 'package:reaxios/api/utils/GenderSerializer.dart';
import 'package:reaxios/api/utils/utils.dart';

part 'Student.g.dart';

@JsonSerializable()
class Student implements AbstractJson {
  String avatar;
  @JsonKey(name: "nome")
  String firstName;
  @JsonKey(name: "cognome")
  String lastName;

  @JsonKey(name: "dataNascita")
  @DateSerializer()
  DateTime birthday;

  @JsonKey(name: "flagGiustifica")
  @BooleanSerializer()
  bool justifiable;

  @JsonKey(name: "idAlunno")
  String studentUUID;
  @JsonKey(name: "idPlesso")
  String schoolUUID;

  @JsonKey(name: "security")
  String securityBits;

  @JsonKey(name: "sesso")
  @GenderSerializer()
  Gender gender;

  int? id;

  @JsonKey(name: "userId")
  String parentID;

  Student(
      {required this.avatar,
      required this.birthday,
      required this.id,
      required this.firstName,
      required this.lastName,
      required this.parentID,
      required this.gender,
      required this.justifiable,
      required this.schoolUUID,
      required this.securityBits,
      required this.studentUUID});

  static empty() {
    return Student(
      avatar: "",
      birthday: DateTime.now(),
      id: 0,
      firstName: "",
      lastName: "",
      parentID: "",
      gender: Gender.Male,
      justifiable: false,
      schoolUUID: "",
      securityBits: "",
      studentUUID: "",
    );
  }

  get fullName => "${titleCase(firstName)} ${titleCase(lastName)}";

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

class SecurityBits {
  static int hideGrades = 2;
  static int hideAssignments = 3;
  static int hideTopics = 3;
  static int hideReports = 3;
  static int hideAbsences = 6;
  static int hideCurriculum = 7;
  static int hideReportCards = 8;
  static int hideAuthorizations = 14;
  static int showMaterials = 17;
  static int hideGradeAverage = 19;
  static int canAuthorizeAuthorization = 29;
}
