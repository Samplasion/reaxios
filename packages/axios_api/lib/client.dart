import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'entities/Absence/Absence.dart';
import 'entities/Account.dart';
import 'entities/Assignment/Assignment.dart';
import 'entities/Authorization/Authorization.dart';
import 'entities/Bulletin/Bulletin.dart';
import 'entities/Curriculum/curriculum.dart';
import 'entities/Grade/Grade.dart';
import 'entities/Login/Login.dart';
import 'entities/Material/Material.dart';
import 'entities/Meeting/Meeting.dart';
import 'entities/Note/Note.dart';
import 'entities/ReportCard/ReportCard.dart';
import 'entities/School/School.dart';
import 'entities/Structural/Structural.dart';
import 'entities/Student/Student.dart';
import 'entities/Topic/Topic.dart';
import 'utils/Encrypter.dart';

typedef JSON = Map<String, dynamic>;
typedef ModelJSONClosure<T> = T Function(dynamic json);
typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);
typedef ComputeImpl = Future<R> Function<Q, R>(
    ComputeCallback<Q, R> callback, Q message,
    {String? debugLabel});

Future<R> defaultCompute<Q, R>(ComputeCallback<Q, R> callback, Q message,
    {String? debugLabel}) {
  return Future.microtask(() => callback(message));
}

// ignore: constant_identifier_names
const VENDOR_TOKEN = "5ed95c58-fbc2-4db8-92cb-7e1e73ba2065";
const kMaxRequests = 5;

List<APIAbsences> _absencesFromJSON(List<dynamic> json) {
  return json.map((e) => APIAbsences.fromJson(e)).toList();
}

List<APIAuthorizations> _authorizationsFromJSON(List<dynamic> json) {
  return json.map((e) => APIAuthorizations.fromJson(e)).toList();
}

List<Assignment> _assignmentsFromJSON(List<dynamic> data) {
  List<dynamic> json = data.first;
  String studentID = data.last;
  return json
      .map((e) => APIAssignments.fromJson(e))
      .where((element) => element.idAlunno == studentID)
      .map((e) => e.compiti)
      .expand((i) => i)
      .toList();
}

List<APIBulletins> _bulletinsFromJSON(List<dynamic> json) {
  return json.map((e) => APIBulletins.fromJson(e)).toList();
}

List<APIGrades> _gradesFromJSON(List<dynamic> json) {
  return json.map((e) => APIGrades.fromJson(e)).toList();
}

List<APIMaterials> _materialsFromJSON(List<dynamic> json) {
  return json.map((e) => APIMaterials.fromJson(e)).toList();
}

List<APINotes> _notesFromJSON(List<dynamic> json) {
  return json.map((e) => APINotes.fromJson(e)).toList();
}

List<Topic> _topicsFromJSON(List<dynamic> data) {
  List<dynamic> json = data.first;
  String studentID = data.last;
  return json
      .map((e) => APITopics.fromJson(e))
      .toList()
      .where((element) => element.idAlunno == studentID)
      .map((e) => e.argomenti)
      .expand((i) => i)
      .toList();
}

List<ReportCard> _reportCardsFromJSON(List<dynamic> json) {
  return json.map((e) => ReportCard.fromJson(e)).toList();
}

List<Student> _studentsFromJSON(List<dynamic> json) {
  return json.map((e) => Student.fromJson(e)).toList();
}

/*
String svc,
    ModelJSONClosure<T> model, [
    String path = "RetrieveDataInformation",
    dynamic data,
    String? sModule,
    String? method,
  ]
  */
class _LastCall<T> {
  final String svc;
  final ModelJSONClosure<T> model;
  final String path;
  final dynamic data;
  final String? sModule;
  final String? method;

  _LastCall({
    required this.svc,
    required this.model,
    this.path = "RetrieveDataInformation",
    this.data,
    this.sModule,
    this.method,
  });
}

class _RawAPIResponse<T> {
  late T? response;
  late String errormessage;
  late int errorcode;
  _RawAPIResponse(JSON data)
      : response = data['response'],
        errormessage = data['errormessage'] ?? "",
        errorcode = data['errorcode'] ?? 0;

  get isError => this.response == null;
}

class Axios {
  late final AxiosAccount _account;
  Login? _session;
  List<Student> _students = [];
  final _client = http.Client();
  Student? student;
  void Function() onError = () {};
  //int _requests = 0;
  DateTime sessionStart = DateTime.now();
  final ComputeImpl compute;

  List<Student> get students => _students;
  AxiosAccount get account => _account;

  static const Map<String, String> defaultHeaders = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "X-Requested-With": "com.axiositalia.re.family",
    "Host": "wssd.axioscloud.it",
  };
  static const Map<String, String> defaultPOSTHeaders = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Content-Type": "application/json; charset=UTF-8",
    "Host": "wssd.axioscloud.it",
    "Origin": "file://"
  };

  Axios(this._account, {required this.compute});

  static Future<List<School>> searchSchools(String query) async {
    if (query.trim().length < 3) return [];

    final session = Axios(
      const AxiosAccount("", "", ""),
      compute: defaultCompute,
    );
    final url = Axios._getURL("GET", "RetrieveAPPCustomerInformationByString",
        data: {"sSearch": query, "sVendorToken": VENDOR_TOKEN});
    Logger.d(url);
    final res = await session._makeCall<dynamic>(url, model: (raw) {
      List<dynamic> list = raw;
      return list.map((e) => School.fromJson(e)).toList();
    });
    return res;
  }

  Future<Login?> _getSession() async {
    try {
      if (_session == null ||
          DateTime.now().difference(sessionStart).inMinutes > 10) {
        await login();
      } else {
        final res = _session;
        if (res == null) await login();
      }
      return _session;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response> _sendRequest({
    required Uri url,
    required String method,
    required Map<String, String> headers,
    required dynamic body,
  }) {
    if (method.toLowerCase() == "post") {
      return _client.post(url, headers: headers, body: body);
    }
    return _client.get(url, headers: headers);
  }

  /// The function where all requests are sent.
  Future<T> _makeCall<T>(
    String url, {
    String method = "GET",
    Map<String, String> headers = Axios.defaultHeaders,
    dynamic body,
    required ModelJSONClosure<T> model,
    _LastCall? lastCall,
  }) async {
    // _requests++;
    try {
      final res = await _sendRequest(
        url: Uri.tryParse(url)!,
        method: method,
        headers: headers,
        body: body,
      );

      final text = res.body;
      if (text.startsWith("<?xml")) {
        Logger.e("XML response: ${res.statusCode}");
        throw Exception("XML response: ${res.statusCode}");
      }
      dynamic data = _RawAPIResponse(
          jsonDecode(Encrypter.decrypt(text).replaceAll("#CR#", "\\n")));

      if (data.errorcode != 0) {
        if (data.errormessage.contains("9999|Utente non trovato")) {
          Logger.i("Got error: Utente non trovato");
          if (lastCall != null) {
            _session = null;
            return _retryLastCall(lastCall);
          } else {
            Logger.i(" └> Additionally, no last call was provided.");
          }
        }
        Logger.e("Error [${data.errorcode}] - ${data.errormessage}");
        throw (data.errormessage);
      }

      return model(data.response);
    } on HttpException {
      onError();
      rethrow;
    }
  }

  Future<T> _retryLastCall<T>(_LastCall lastCall) async {
    final res = await _makeAuthenticatedCall<T>(
      lastCall.svc,
      lastCall.model as ModelJSONClosure<T>,
      lastCall.path,
      lastCall.data,
      lastCall.sModule,
      lastCall.method,
    );
    return res;
  }

  Future<T> _makeAuthenticatedCall<T>(
    String svc,
    ModelJSONClosure<T> model, [
    String path = "RetrieveDataInformation",
    dynamic data,
    String? sModule,
    String? method,
  ]) async {
    Login? session; // = await this._getSession();
    do {
      session = await _getSession();
      // if (session == null) throw ("Unauthenticable.");
    } while (session == null);

    final sCommandJSON = data == null
        ?
        // GET
        {
            "sApplication": "FAM",
            "sService": svc,
          }
        :
        // POST
        {
            "sApplication": "FAM",
            "sService": svc,
            "sModule": sModule,
            "data": data
          };
    final json = {
      "sCodiceFiscale": _account.schoolID,
      "sVendorToken": VENDOR_TOKEN,
      "sCommandJSON": sCommandJSON,
      "sSessionGuid": session.sessionUUID,
    };

    final definiteMethod = method ?? (data == null ? "GET" : "POST");

    // Set the last call so that we can retry it in case of session expiration.
    final lastCall = _LastCall(
      svc: svc,
      model: model,
      path: path,
      data: data,
      sModule: sModule,
      method: method,
    );

    if (definiteMethod == "POST") {
      return _makeCall<T>(
        Axios._getURL(definiteMethod, path, data: json),
        model: model,
        method: definiteMethod,
        headers: definiteMethod == "POST" ? defaultPOSTHeaders : defaultHeaders,
        body: jsonEncode(
            {"JsonRequest": Encrypter.encryptPost(jsonEncode(json))}),
        lastCall: lastCall,
      );
    }
    return _makeCall<T>(
      Axios._getURL(definiteMethod, path, data: json),
      model: model,
      method: definiteMethod,
      headers: definiteMethod == "POST" ? defaultPOSTHeaders : defaultHeaders,
      lastCall: lastCall,
    );
  }

  static String _getURL(String method, String path, {dynamic data}) {
    const url = "https://wssd.axioscloud.it/webservice/AxiosCloud_Ws_Rest.svc/";
    switch (method.toLowerCase()) {
      case "post":
        return "$url$path";
      default:
        return "$url$path?${Encrypter.encrypt(jsonEncode(data))}";
    }
  }

  Future<Login> login() async {
    final data = {
      "sAppName": "FAM_APP",
      "sCodiceFiscale": _account.schoolID,
      "sCustomerIdSpid": _account.schoolID,
      "sUserName": _account.userID,
      "sPassword": _account.userPassword,
      "sVendorToken": VENDOR_TOKEN
    };
    print(data);
    final url = Axios._getURL("GET", "Login", data: data);
    final res =
        await _makeCall<Login>(url, model: (map) => Login.fromJson(map));
    _session = res;
    final students = await getStudents();
    student ??= students[0];
    _students = students;

    sessionStart = DateTime.now();

    return res;
  }

  Future<List<Student>> getStudents([bool forceReload = false]) async {
    // final url = Axios._getURL("GET", "Login", data: {
    //     "sAppName": "FAM_APP",
    //     "sCodiceFiscale": this._account.schoolID,
    //     "sUserName": this._account.userID,
    //     "sPassword": this._account.userPassword,
    //     "sVendorToken": VENDOR_TOKEN
    // });
    if (_students.isNotEmpty && !forceReload) {
      return _students;
    } else {
      final res = await _makeAuthenticatedCall<dynamic>("GET_STUDENTI", (raw) {
        return compute<List<dynamic>, List<Student>>(_studentsFromJSON, raw);
        // return Future.wait(
        //     list.map((e) => compute(Student.fromJson, e)).toList());
      });
      return res;
    }
  }

  void setStudentByID(String userID) {
    if (students.any((element) => element.studentUUID == userID)) {
      student = students.firstWhere(
        (element) => element.studentUUID == userID,
      );
    }
  }

  Future<List<Assignment>> getAssignments() async {
    final List<Assignment> res =
        await _makeAuthenticatedCall<dynamic>("GET_COMPITI_MASTER", (raw) {
      return compute<List<dynamic>, List<Assignment>>(
          _assignmentsFromJSON, [raw, student!.studentUUID]);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APIAssignments.fromJson, e)).toList());
    });
    return res;
  }

  Future<List<Grade>> getGrades(Structural structural) async {
    final List<APIGrades> res =
        await _makeAuthenticatedCall<dynamic>("GET_VOTI_LIST_DETAIL", (raw) {
      return compute<List<dynamic>, List<APIGrades>>(_gradesFromJSON, raw);
    });
    final data =
        res.where((element) => element.idAlunno == student!.studentUUID);
    return data
        .map((e) {
          final grades = e.voti.map(
            (g) => g..normalize(structural, e.idFrazione),
          );
          return grades;
        })
        .expand((i) => i)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<Structural> getStructural() async {
    final JSON sJson = await _makeAuthenticatedCall<JSON>(
      "GET_STRUCTURAL",
      (json) => json,
    );

    return await compute(
      Structural.fromJson,
      sJson,
    );
  }

  Future<List<Period>> getPeriods() async {
    final res = await getStructural();
    return res.periods[0].periods;
  }

  Future<Period?> getCurrentPeriod() async {
    final res = await getStructural();
    try {
      // ignore: unnecessary_cast
      return (res.periods[0].periods as List<Period?>).firstWhere(
          (Period? period) {
        if (period == null) return false;
        return period.startDate.millisecondsSinceEpoch <
                DateTime.now().millisecondsSinceEpoch &&
            DateTime.now().millisecondsSinceEpoch <
                period.endDate.millisecondsSinceEpoch;
      }, orElse: () => null);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReportCard>> getReportCards([bool forceReload = false]) async {
    final res =
        await _makeAuthenticatedCall<dynamic>("GET_PAGELLA_MASTER_V3", (raw) {
      return compute<List<dynamic>, List<ReportCard>>(
          _reportCardsFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(ReportCard.fromJson, e)).toList());
      // return list.map((e) => ReportCard.fromJson(e)).toList();
    });
    return res;
  }

  Future<List<Topic>> getTopics() async {
    final List<Topic> res =
        await _makeAuthenticatedCall<dynamic>("GET_ARGOMENTI_MASTER", (raw) {
      return compute<List<dynamic>, List<Topic>>(
          _topicsFromJSON, [raw, student!.studentUUID]);
    });
    return res;
  }

  Future<List<Bulletin>> getBulletins() async {
    final List<APIBulletins> res = await _makeAuthenticatedCall<dynamic>(
        "GET_COMUNICAZIONI_MASTER", (raw) {
      return compute<List<dynamic>, List<APIBulletins>>(
          _bulletinsFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APIBulletins.fromJson, e)).toList());
      // return (raw as List).map((e) => APIBulletins.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.comunicazioni)
        .expand((i) => i)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Note>> getNotes() async {
    final List<APINotes> res =
        await _makeAuthenticatedCall<dynamic>("GET_NOTE_MASTER", (raw) {
      return compute<List<dynamic>, List<APINotes>>(_notesFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APINotes.fromJson, e)).toList());
      // return (raw as List).map((e) => APINotes.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.note.map((note) => note.setPeriod(e.descFrazione)))
        .expand((i) => i)
        .toList();
  }

  Future<List<Absence>> getAbsences() async {
    final structural = await getStructural();
    final List<APIAbsences> res =
        await _makeAuthenticatedCall<dynamic>("GET_ASSENZE_MASTER", (raw) {
      return compute<List<dynamic>, List<APIAbsences>>(_absencesFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APIAbsences.fromJson, e)).toList());
      // return (raw as List).map((e) => APIAbsences.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.assenze.map((note) => note
            .setSession(this)
            .setPeriod(e.descFrazione)
            .setKinds(structural)))
        .expand((i) => i)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<MaterialTeacherData>> getMaterials([String? uuid]) async {
    final List<APIMaterials> res =
        await _makeAuthenticatedCall<dynamic>("GET_MATERIALE_MASTER", (raw) {
      return compute<List<dynamic>, List<APIMaterials>>(
          _materialsFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APIMaterials.fromJson, e)).toList());
      // return (raw as List).map((e) => APIMaterials.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == (uuid ?? student!.studentUUID))
        .map((e) => e.docenti
          ..forEach((teacher) {
            for (var folder in teacher.folders) {
              folder.setSession(this).setTeacher(teacher);
            }
          }))
        .expand((i) => i)
        .toList();
  }

  Future<List<MeetingSchema>> getTeacherMeetings() async {
    final List<MeetingSchema> res =
        await _makeAuthenticatedCall<dynamic>("GET_COLLOQUI_MASTER", (raw) {
      return (raw as List).map((e) => MeetingSchema.fromJson(e)).toList();
    });
    Logger.d("$res");
    return res
        .where((element) => element.studentID == student!.studentUUID)
        // .map((e) => e.docenti
        //   ..forEach((teacher) {
        //     teacher.folders.forEach((folder) {
        //       folder.setSession(this).setTeacher(teacher);
        //     });
        //   }))
        // .expand((i) => i)
        .toList();
  }

  Future<List<MaterialData>> getMaterialDetails(
      String teacherUUID, String folderUUID) async {
    final List<MaterialData> res = await _makeAuthenticatedCall<dynamic>(
      "GET_MATERIALE_DETAIL",
      (raw) {
        return (raw as List).map((e) => MaterialData.fromJson(e)).toList();
      },
      "RetrieveDataInformation",
      {
        "idDocente": teacherUUID,
        "idFolder": folderUUID,
      },
      null,
      "GET",
    );
    return res;
  }

  Future<List<Curriculum>> getCurriculum() async {
    final List<Curriculum> res = await _makeAuthenticatedCall<dynamic>(
      "GET_CURRICULUM_MASTER",
      (raw) {
        return compute<List<dynamic>, List<Curriculum>>(
          curriculaFromJSON,
          [raw, student!.studentUUID],
        );
      },
      "RetrieveDataInformation",
      {
        "alunnoId": student!.studentUUID,
      },
      "FAM",
      "GET",
    );
    return res;
  }

  Future<List<Authorization>> getAuthorizations() async {
    final structural = await getStructural();
    final List<APIAuthorizations> res = await _makeAuthenticatedCall<dynamic>(
        "GET_AUTORIZZAZIONI_MASTER", (raw) {
      return compute<List<dynamic>, List<APIAuthorizations>>(
          _authorizationsFromJSON, raw);
      // List<JSON> list = List<JSON>.from(raw);
      // return Future.wait(
      //     list.map((e) => compute(APIAuthorizations.fromJson, e)).toList());
      // return (raw as List).map((e) => APIAuthorizations.fromJson(e)).toList();
    });
    final periods = structural.periods
        .firstWhere((element) => element.schoolID == student!.schoolUUID);
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => <Authorization>[
              ...e.permessiDaAutorizzare,
              ...e.permessiAutorizzati
            ].map((auth) => auth
                .setSession(this)
                .setPeriod(periods.getCurrentPeriod(auth.startDate)?.desc ?? "")
                .setKinds(structural)))
        .expand((i) => i)
        .toList()
        .reversed
        .toList();
  }

  Future<List<String>> getSubjects() async {
    final topics = await getTopics();
    final assignments = await getAssignments();

    final List<String> res = <String>[];
    for (var topic in topics) {
      if (topic.subject.isNotEmpty) {
        res.add(topic.subject);
      }
    }
    for (var assignment in assignments) {
      if (assignment.subject.isNotEmpty) {
        res.add(assignment.subject);
      }
    }

    return res.toSet().toList();
  }

  Future<Bulletin> markBulletinAsRead(Bulletin bulletin) async {
    String result = await _makeAuthenticatedCall(
      "APP_PROCESS_QUEUE",
      (any) => "$any",
      "ExecuteCommand",
      {"comunicazioneId": bulletin.id, "alunnoId": student?.studentUUID},
      "COMUNICAZIONI_READ",
    );

    return bulletin.copyWith(
      read: result.toString().contains("ok"),
    );
  }

  Future<void> markGradeAsRead(Grade grade) async {
    Student? student = this.student;
    String gradeBit = student?.securityBits[22] ?? "1";

    if (gradeBit == "0") return;

    // The official app doesn't care about the result
    // of this operation. So we don't either
    try {
      await _makeAuthenticatedCall(
        "APP_PROCESS_QUEUE",
        (any) => "$any",
        "ExecuteCommand",
        {
          // "id": grade.id,
          "idVoto": grade.id,
          // "@i_vread_voto_id": int.parse(grade.id),
          // "i_vread_voto_id": int.parse(grade.id),
          "pin": _session?.pin ?? "",
          "idAlunno": student?.studentUUID,
        },
        "VOTO_VISTA",
      );
    } catch (e) {
      // noop
    }

    // bool read = result.toString().contains("ok");

    // if (read) {
    grade.seen = true;
    grade.seenBy = "${_session?.firstName} ${_session?.lastName}";
    grade.seenOn = DateTime.now();
    // }
  }

  Future<bool> justifyAbsence(Absence absence) async {
    Login login = await this.login();
    Student? student = this.student;

    if (student == null) return false;

    String result = await _makeAuthenticatedCall(
      "APP_PROCESS_QUEUE",
      (any) => "$any",
      "ExecuteCommand",
      {
        "id": absence.id,
        "pin": login.pin,
        "alunnoId": student.studentUUID,
        "tipo": absence.rawKind,
        "motivoId": "",
      },
      "ASSENZE_GIUSTIFICA",
    );

    return result.toLowerCase().contains("ok");
  }

  Future<bool> justifyAuthorization(Authorization authorization) async {
    Login login = await this.login();
    Student? student = this.student;

    if (student == null) return false;

    String result = await _makeAuthenticatedCall(
      "APP_PROCESS_DIRECT",
      (any) => "$any",
      "ExecuteCommand",
      {
        "idAlunno": student.studentUUID,
        "idPermesso": authorization.id,
        "pin": login.pin,
      },
      "PERMESSO_ACCEPT",
    );

    return result.toLowerCase().contains("ok");
  }

  Future<bool> readAllBulletins() async {
    final List<Bulletin> bulletins = await getBulletins();
    final List<Bulletin> unread = bulletins.where((e) => !e.read).toList();
    if (unread.isEmpty) return true;
    for (final bulletin in unread) {
      await markBulletinAsRead(bulletin);
    }
    return true;
  }

  Future<Map<String, dynamic>> getWebVersionUrl() async {
    return _makeAuthenticatedCall("GET_URL_WEB", (json) => json);
  }
}
