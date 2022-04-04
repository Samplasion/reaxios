import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part 'Topic.g.dart';

// {
//     date: Date,
//     subject: string,
//     assignment: string
// }

@JsonSerializable()
class Topic extends Equatable implements AbstractJson {
  @JsonKey(name: "data")
  @DateSerializer()
  final DateTime date;
  @JsonKey(name: "descMat")
  final String subject;
  @JsonKey(name: "oreLezione")
  final String lessonHour;
  @JsonKey(name: "descArgomenti", defaultValue: "")
  final String topic;
  @JsonKey(name: "flagStato")
  final String flags;
  @JsonKey(name: "data_pubblicazione")
  @DateSerializer()
  final DateTime publicationDate;
  @JsonKey(name: "idCollabora", defaultValue: "")
  final String id;

  const Topic({
    required this.date,
    required this.publicationDate,
    required this.subject,
    required this.lessonHour,
    required this.id,
    required this.flags,
    required this.topic,
  });

  static empty() {
    return Topic(
      date: DateTime.now(),
      publicationDate: DateTime.now(),
      subject: "",
      lessonHour: "",
      id: "",
      topic: "",
      flags: "",
    );
  }

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);

  static test() {
    return Topic(
      date: DateTime.now(),
      publicationDate: DateTime.now(),
      subject: "Lingua e Letteratura Italiana",
      lessonHour: "4",
      id: "233",
      topic: "La Divina Commedia: Purgatorio",
      flags: "",
    );
  }

  @override
  List<Object?> get props => [
        date,
        subject,
        lessonHour,
        id,
        topic,
        flags,
        publicationDate,
      ];
}

@JsonSerializable()
class APITopics {
  String idAlunno;
  List<Topic> argomenti;

  APITopics({
    required this.idAlunno,
    required this.argomenti,
  });

  factory APITopics.fromJson(Map<String, dynamic> json) =>
      _$APITopicsFromJson(json);

  Map<String, dynamic> toJson() => _$APITopicsToJson(this);
}
