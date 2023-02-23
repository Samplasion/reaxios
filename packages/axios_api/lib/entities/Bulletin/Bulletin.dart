import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/enums/BulletinAttachmentKind.dart';
import 'package:axios_api/enums/BulletinKind.dart';
import 'package:axios_api/interfaces/AbstractJson.dart';
import 'package:axios_api/utils/BooleanSerializer.dart';
import 'package:axios_api/utils/DateSerializer.dart';

part 'Bulletin.g.dart';

@JsonSerializable()
class Bulletin extends Equatable implements AbstractJson {
  final String id;
  @JsonKey(name: "data")
  @DateSerializer()
  final DateTime date;
  @JsonKey(name: "titolo")
  final String title;
  @JsonKey(name: "desc")
  final String desc;
  @JsonKey(name: "tipo")
  @BulletinKindSerializer()
  final BulletinKind kind;
  @JsonKey(name: "tipo_risposta")
  final String responseKind;
  @JsonKey(name: "opzioni")
  final String options;
  @JsonKey(name: "pin")
  @BooleanSerializer()
  final bool pin;
  @JsonKey(name: "modificabile")
  @BooleanSerializer()
  final bool editable;
  @JsonKey(name: "letta")
  @BooleanSerializer()
  final bool read;
  @JsonKey(name: "risposta")
  final String reply;
  @JsonKey(name: "risposta_testo")
  final String textReply;
  @JsonKey(name: "allegati")
  final List<BulletinAttachment> attachments;

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

  const Bulletin({
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
      id: "0",
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

  factory Bulletin.fromJson(Map<String, dynamic> json) => _$BulletinFromJson({
        ...json,
        "desc": "${json["desc"]}".replaceAll("<p>", "").replaceAll("</p>", "")
      });

  Map<String, dynamic> toJson() => _$BulletinToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static test() {
    return Bulletin(
      id: "42",
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

  @override
  List<Object?> get props => [
        id,
        date,
        title,
        desc,
        kind,
        responseKind,
        options,
        pin,
        editable,
        read,
        reply,
        textReply,
        attachments,
      ];

  copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? desc,
    BulletinKind? kind,
    String? responseKind,
    String? options,
    bool? pin,
    bool? editable,
    bool? read,
    String? reply,
    String? textReply,
    List<BulletinAttachment>? attachments,
  }) {
    return Bulletin(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      kind: kind ?? this.kind,
      responseKind: responseKind ?? this.responseKind,
      options: options ?? this.options,
      pin: pin ?? this.pin,
      editable: editable ?? this.editable,
      read: read ?? this.read,
      reply: reply ?? this.reply,
      textReply: textReply ?? this.textReply,
      attachments: attachments ?? this.attachments,
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
class BulletinAttachment extends Equatable {
  @JsonKey(name: "tipo")
  @BulletinAttachmentKindSerializer()
  final BulletinAttachmentKind kind;
  @JsonKey(name: "URL")
  final String url;
  final String? desc;
  final String? sourceName;

  const BulletinAttachment({
    required this.kind,
    required this.url,
    required this.desc,
    required this.sourceName,
  });

  factory BulletinAttachment.fromJson(Map<String, dynamic> json) =>
      _$BulletinAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$BulletinAttachmentToJson(this);

  @override
  List<Object?> get props => [
        kind,
        url,
        desc,
        sourceName,
      ];
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
