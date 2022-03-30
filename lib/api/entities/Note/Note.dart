import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part 'Note.g.dart';

@JsonSerializable()
class Note extends Equatable implements AbstractJson {
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

  static test() {
    final content = "L'alunno interviene spesso durante la lezione in maniera "
        "inappropriata. Gli è' stato suggerito di non farlo poichè tali "
        "interventi sono sempre poco chiari, proiettati su aspetti non "
        "strettamente attinenti all'obiettivo della lezione e soprattutto "
        "l'alunno si pone verso l'insegnante in maniera inadeguata: non si "
        "accontenta della risposta che gli viene fornita senza considerare "
        "che sia il suo comportamento che la natura dei suoi interventi sono "
        "estremamente fuorvianti per la classe poichè disorietano, "
        "fanno perdere il filo della lezione con grande perdita di tempo ";

    return Note(
      date: DateTime.now(),
      content: content,
      rawKind: NoteKind.Notice,
      id: "6",
      subjectID: "",
      subject: "Disegno e Storia dell'Arte",
      teacher: "Ugo Spitaliere",
      period: "I QUADRIMESTRE",
    );
  }

  @override
  List<Object> get props => [
        date,
        content,
        rawKind,
        id,
        subjectID,
        subject,
        teacher,
        period,
      ];
}

@JsonSerializable()
class APINotes extends Equatable {
  final String idAlunno;
  final String idFrazione;
  final String descFrazione;
  final List<Note> note;

  const APINotes({
    required this.idAlunno,
    required this.idFrazione,
    required this.descFrazione,
    required this.note,
  });

  factory APINotes.fromJson(Map<String, dynamic> json) =>
      _$APINotesFromJson(json);

  Map<String, dynamic> toJson() => _$APINotesToJson(this);

  @override
  List<Object> get props => [
        idAlunno,
        idFrazione,
        descFrazione,
        note,
      ];
}

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
