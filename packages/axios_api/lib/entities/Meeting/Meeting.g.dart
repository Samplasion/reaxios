// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSchema _$MeetingSchemaFromJson(Map<String, dynamic> json) =>
    MeetingSchema(
      studentID: json['idAlunno'] as String,
      teacherID: json['idDocente'] as String,
      teacher: json['descDoc'] as String,
      subject: json['descMat'] as String,
      meetings: Meeting.fromJson(json['colloqui'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeetingSchemaToJson(MeetingSchema instance) =>
    <String, dynamic>{
      'idAlunno': instance.studentID,
      'idDocente': instance.teacherID,
      'descDoc': instance.teacher,
      'descMat': instance.subject,
      'colloqui': instance.meetings,
    };

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
      location: json['descSede'] as String,
      day: json['giorno'] as String,
      startTime: json['oraInizio'] as String,
      endTime: json['oraFine'] as String,
      note: json['descNota'] as String,
      link: json['link'] as String,
      dates: (json['date'] as List<dynamic>)
          .map((e) => MeetingDate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
      'descSede': instance.location,
      'giorno': instance.day,
      'oraInizio': instance.startTime,
      'oraFine': instance.endTime,
      'descNota': instance.note,
      'link': instance.link,
      'date': instance.dates,
    };

MeetingDate _$MeetingDateFromJson(Map<String, dynamic> json) => MeetingDate(
      periodID: json['idPeriodo'] as String,
      bookingID: json['idPrenotazione'] as String,
      date: json['data'] as String,
      rawSeats: json['posti'] as String,
      rawTimes: json['orari'] as String,
      rawBooked: (json['prenotazione'] as num).toInt(),
      mode: json['modalita'] as String,
    );

Map<String, dynamic> _$MeetingDateToJson(MeetingDate instance) =>
    <String, dynamic>{
      'idPeriodo': instance.periodID,
      'idPrenotazione': instance.bookingID,
      'data': instance.date,
      'posti': instance.rawSeats,
      'orari': instance.rawTimes,
      'prenotazione': instance.rawBooked,
      'modalita': instance.mode,
    };
