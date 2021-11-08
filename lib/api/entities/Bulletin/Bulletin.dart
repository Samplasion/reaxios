import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/BulletinAttachmentKind.dart';
import 'package:reaxios/api/enums/BulletinKind.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part 'Bulletin.g.dart';

@JsonSerializable()
class Bulletin implements AbstractJson {
  num id;
  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;
  @JsonKey(name: "titolo")
  String title;
  @JsonKey(name: "desc")
  String desc;
  @JsonKey(name: "tipo")
  @BulletinKindSerializer()
  BulletinKind kind;
  @JsonKey(name: "tipo_risposta")
  String responseKind;
  @JsonKey(name: "opzioni")
  String options;
  @JsonKey(name: "pin")
  @BooleanSerializer()
  bool pin;
  @JsonKey(name: "modificabile")
  @BooleanSerializer()
  bool editable;
  @JsonKey(name: "letta")
  @BooleanSerializer()
  bool read;
  @JsonKey(name: "risposta")
  String reply;
  @JsonKey(name: "risposta_testo")
  String textReply;
  @JsonKey(name: "allegati")
  List<BulletinAttachment> attachments;

  get humanReadableKind {
    switch (kind) {
      case BulletinKind.Principal:
        return "Dirigente";
      case BulletinKind.Secretary:
        return "Segreteria";
      case BulletinKind.BoardOfTeachers:
        return "Collegio docenti";
      case BulletinKind.Teacher:
        return "Docente";
      case BulletinKind.Other:
        return "Altro";
    }
  }

  Bulletin({
    required this.id,
    required this.date,
    required this.title,
    required this.desc,
    required this.kind,
    required this.responseKind,
    required this.options,
    required this.pin,
    required this.editable,
    required this.read,
    required this.reply,
    required this.textReply,
    required this.attachments,
  });

  static empty() {
    return Bulletin(
      id: 0,
      date: DateTime.now(),
      title: "",
      desc: "",
      kind: BulletinKind.Other,
      responseKind: "",
      options: "",
      pin: false,
      editable: false,
      read: false,
      reply: "",
      textReply: "",
      attachments: [],
    );
  }

  factory Bulletin.fromJson(Map<String, dynamic> json) =>
      _$BulletinFromJson(json);

  Map<String, dynamic> toJson() => _$BulletinToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static test() {
    return Bulletin(
      id: 42,
      date: DateTime.now(),
      title: "Circolare n. 10",
      desc: "Regolamentazione uscite didattiche",
      kind: BulletinKind.Principal,
      responseKind: "",
      options: "",
      pin: false,
      editable: false,
      read: false,
      reply: "",
      textReply: "",
      attachments: [
        BulletinAttachment(
          kind: BulletinAttachmentKind.File,
          url: "https://google.com",
          desc: "Allegata è la circolare numero 10.",
          sourceName: "Circolare_10_uscite.docx",
        )
      ],
    );
  }
}

@JsonSerializable()
class APIBulletins {
  String idAlunno;
  List<Bulletin> comunicazioni;

  APIBulletins({
    required this.idAlunno,
    required this.comunicazioni,
  });

  factory APIBulletins.fromJson(Map<String, dynamic> json) =>
      _$APIBulletinsFromJson(json);

  Map<String, dynamic> toJson() => _$APIBulletinsToJson(this);
}

@JsonSerializable()
class BulletinAttachment {
  @JsonKey(name: "tipo")
  @BulletinAttachmentKindSerializer()
  BulletinAttachmentKind kind;
  @JsonKey(name: "URL")
  String url;
  String? desc;
  String? sourceName;

  BulletinAttachment({
    required this.kind,
    required this.url,
    required this.desc,
    required this.sourceName,
  });

  factory BulletinAttachment.fromJson(Map<String, dynamic> json) =>
      _$BulletinAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$BulletinAttachmentToJson(this);
}

class BulletinKindSerializer implements JsonConverter<BulletinKind, String> {
  const BulletinKindSerializer();

  @override
  BulletinKind fromJson(String json) {
    switch ("$json".toUpperCase()) {
      case "D":
        return BulletinKind.Principal;
      case "S":
        return BulletinKind.Secretary;
      case "C":
        return BulletinKind.BoardOfTeachers;
      case "P":
        return BulletinKind.Teacher;
      case "A":
      default:
        return BulletinKind.Other;
    }
  }

  @override
  String toJson(BulletinKind b) {
    switch (b) {
      case BulletinKind.Principal:
        return "D";
      case BulletinKind.Secretary:
        return "S";
      case BulletinKind.BoardOfTeachers:
        return "C";
      case BulletinKind.Teacher:
        return "P";
      case BulletinKind.Other:
        return "A";
    }
  }
}

class BulletinAttachmentKindSerializer
    implements JsonConverter<BulletinAttachmentKind, String> {
  const BulletinAttachmentKindSerializer();

  @override
  BulletinAttachmentKind fromJson(String json) {
    switch ("$json".toUpperCase()) {
      case "1":
        return BulletinAttachmentKind.File;
      case "O":
      default:
        return BulletinAttachmentKind.Other;
    }
  }

  @override
  String toJson(BulletinAttachmentKind b) {
    switch (b) {
      case BulletinAttachmentKind.File:
        return "1";
      case BulletinAttachmentKind.Other:
        return "O";
    }
  }
}
