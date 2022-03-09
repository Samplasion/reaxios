import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/timetable/extensions.dart';

import '../../interfaces/AbstractJson.dart';

part 'Meeting.g.dart';

@JsonSerializable()
class MeetingSchema implements AbstractJson {
  @JsonKey(name: 'idAlunno')
  final String studentID;

  @JsonKey(name: 'idDocente')
  final String teacherID;

  @JsonKey(name: 'descDoc')
  final String teacher;

  @JsonKey(name: 'descMat')
  final String subject;

  @JsonKey(name: 'colloqui')
  final Meeting meetings;

  MeetingSchema({
    required this.studentID,
    required this.teacherID,
    required this.teacher,
    required this.subject,
    required this.meetings,
  });

  static empty() {
    return MeetingSchema(
      studentID: '',
      teacherID: '',
      teacher: '',
      subject: '',
      meetings: Meeting.empty(),
    );
  }

  factory MeetingSchema.fromJson(Map<String, dynamic> json) =>
      _$MeetingSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSchemaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static test() {
    return MeetingSchema(
      studentID: '',
      teacherID: '',
      teacher: "Montanaro Genitori",
      subject: "Matematica",
      meetings: Meeting.test(),
    );
  }
}

@JsonSerializable()
class Meeting implements AbstractJson {
  @JsonKey(name: 'descSede')
  final String location;

  @JsonKey(name: 'giorno')
  final String day;

  @JsonKey(name: 'oraInizio')
  final String startTime;

  @JsonKey(name: 'oraFine')
  final String endTime;

  @JsonKey(name: 'descNota')
  final String note;

  final String link;

  @JsonKey(name: 'date')
  final List<MeetingDate> dates;

  Meeting({
    required this.location,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.link,
    required this.dates,
  });

  static empty() {
    return Meeting(
      location: '',
      day: '',
      startTime: '',
      endTime: '',
      note: '',
      link: '',
      dates: [],
    );
  }

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static test() {
    return Meeting(
      location: '',
      day: '',
      startTime: '',
      endTime: '',
      note: '',
      link: '',
      dates: [],
    );
  }
}

@JsonSerializable()
class MeetingDate {
  @JsonKey(name: 'idPeriodo')
  final String periodID;

  @JsonKey(name: 'idPrenotazione')
  final String bookingID;

  @JsonKey(name: 'data')
  final String date;

  @JsonKey(name: 'posti')
  final String rawSeats;
  Map<String, bool> get availableSeats {
    final list = rawSeats.split('').map((s) => s != '0').toList();
    return Map<String, bool>.fromIterable(
      0.to(list.length - 1),
      key: (i) => times[i],
      value: (i) => list[i],
    );
  }

  bool get hasSeats => availableSeats.values.any((v) => v);

  @JsonKey(name: 'orari')
  final String rawTimes;
  List<String> get times {
    return rawTimes.split('|').where((s) => s.isNotEmpty).toList();
  }

  @JsonKey(name: 'prenotazione')
  final int rawBooked;
  bool get isBooked => rawBooked == 1;

  @JsonKey(name: 'modalita')
  final String mode;

  MeetingDate({
    required this.periodID,
    required this.bookingID,
    required this.date,
    required this.rawSeats,
    required this.rawTimes,
    required this.rawBooked,
    required this.mode,
  });

  static empty() {
    return MeetingDate(
      periodID: '',
      bookingID: '',
      date: '',
      rawSeats: '',
      rawTimes: '',
      rawBooked: 0,
      mode: '',
    );
  }

  factory MeetingDate.fromJson(Map<String, dynamic> json) =>
      _$MeetingDateFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingDateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static test() {
    return MeetingDate(
      periodID: '',
      bookingID: '',
      date: '',
      rawSeats: '',
      rawTimes: '',
      rawBooked: 0,
      mode: '',
    );
  }
}
