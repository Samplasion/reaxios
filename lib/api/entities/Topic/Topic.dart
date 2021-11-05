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
class Topic implements AbstractJson {
  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;
  @JsonKey(name: "descMat")
  String subject;
  @JsonKey(name: "oreLezione")
  String lessonHour;
  @JsonKey(name: "descArgomenti", defaultValue: "")
  String topic;
  @JsonKey(name: "flagStato")
  String flags;
  @JsonKey(name: "data_pubblicazione")
  @DateSerializer()
  DateTime publicationDate;
  @JsonKey(name: "idCollabora", defaultValue: "")
  String id;

  Topic({
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
