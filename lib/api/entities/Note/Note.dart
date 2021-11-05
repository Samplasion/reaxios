import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/BulletinAttachmentKind.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part 'Note.g.dart';

@JsonSerializable()
class Note implements AbstractJson {
  // num id;
  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;
  @JsonKey(name: "descNota")
  String content;
  @JsonKey(name: "tipo")
  @NoteKindSerializer()
  NoteKind rawKind;
  NoteKind get kind {
    if (content.startsWith("<i>Comunicazione: </i>"))
      return NoteKind.Note;
    else
      return NoteKind.Notice;
  }

  @JsonKey(name: "idNota")
  String id;
  @JsonKey(name: "idMat")
  String subjectID;
  @JsonKey(name: "descMat")
  String subject;
  @JsonKey(name: "descDoc")
  String teacher;
  @JsonKey(ignore: true)
  String period;

  Note({
    required this.date,
    required this.content,
    required this.rawKind,
    required this.id,
    required this.subjectID,
    required this.subject,
    required this.teacher,
    this.period = "",
  });

  static empty() {
    return Note(
      date: DateTime.now(),
      content: "",
      rawKind: NoteKind.Note,
      id: "",
      subjectID: "",
      subject: "",
      teacher: "",
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Note setPeriod(String period) {
    this.period = period;
    // print(this.content);
    // print(this.kind);
    return this;
  }

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class APINotes {
  String idAlunno;
  String idFrazione;
  String descFrazione;
  List<Note> note;

  APINotes({
    required this.idAlunno,
    required this.idFrazione,
    required this.descFrazione,
    required this.note,
  });

  factory APINotes.fromJson(Map<String, dynamic> json) =>
      _$APINotesFromJson(json);

  Map<String, dynamic> toJson() => _$APINotesToJson(this);
}

// @JsonSerializable()
// class BulletinAttachment {
//   @JsonKey(name: "tipo")
//   @BulletinAttachmentKindSerializer()
//   BulletinAttachmentKind kind;
//   @JsonKey(name: "URL")
//   String url;
//   String? desc;
//   String? sourceName;

//   BulletinAttachment({
//     required this.kind,
//     required this.url,
//     required this.desc,
//     required this.sourceName,
//   });

//   factory BulletinAttachment.fromJson(Map<String, dynamic> json) =>
//       _$BulletinAttachmentFromJson(json);

//   Map<String, dynamic> toJson() => _$BulletinAttachmentToJson(this);
// }

class NoteKindSerializer implements JsonConverter<NoteKind, String> {
  const NoteKindSerializer();

  @override
  NoteKind fromJson(String json) {
    // print("Tipo nota");
    // print(json);
    switch ("$json".toUpperCase()) {
      case "C":
        return NoteKind.Note;
      default:
        return NoteKind.Notice;
    }
  }

  @override
  String toJson(NoteKind b) {
    switch (b) {
      case NoteKind.Notice:
        return "N";
      case NoteKind.Note:
        return "C";
    }
  }
}

// class BulletinAttachmentKindSerializer
//     implements JsonConverter<BulletinAttachmentKind, String> {
//   const BulletinAttachmentKindSerializer();

//   @override
//   BulletinAttachmentKind fromJson(String json) {
//     switch ("$json".toUpperCase()) {
//       case "1":
//         return BulletinAttachmentKind.File;
//       case "O":
//       default:
//         return BulletinAttachmentKind.Other;
//     }
//   }

//   @override
//   String toJson(BulletinAttachmentKind b) {
//     switch (b) {
//       case BulletinAttachmentKind.File:
//         return "1";
//       case BulletinAttachmentKind.Other:
//         return "O";
//     }
//   }
// }
