import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/School/School.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';

import 'entities/Bulletin/Bulletin.dart';
import 'entities/Student/Student.dart';
import 'entities/Login/Login.dart';
import 'entities/Account.dart';
import 'utils/Encrypter.dart';

typedef JSON = Map<String, dynamic>;
// typedef CreateModelFromJSON<T> = T Function(JSON json);
typedef ModelJSONClosure<T> = T Function(dynamic json);

const VENDOR_TOKEN = "a67ff23d-3277-4e2b-855d-f8fa52a6ba8e";
const kMaxRequests = 5;

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
      : this.response = data['response'],
        this.errormessage = data['errormessage'] ?? "",
        this.errorcode = data['errorcode'] ?? 0;

  // static error(String message) {
  //   return _RawAPIResponse(
  //       {"response": null, "errorcode": -1, "errormessage": message});
  // }

  // static wrap<T>(T value) {
  //   return _RawAPIResponse<T>(
  //       {"response": value, "errorcode": 0, "errormessage": ""});
  // }

  get isError => this.response == null;
}

class Axios {
  late final AxiosAccount _account;
  Login? _session;
  List<Student> _students = [];
  final client = Dio();
  Student? student;
  void Function() onError = () {};
  //int _requests = 0;
  DateTime sessionStart = DateTime.now();

  List<Student> get students => _students;
  AxiosAccount get account => _account;

  static const Map<String, String> defaultHeaders = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    // "X-Requested-With": "com.axiositalia.re.family",
    // "Host": "wssd.axioscloud.it",
  };
  static const Map<String, String> defaultPOSTHeaders = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Content-Type": "application/json; charset=UTF-8",
    // "Host": "wssd.axioscloud.it",
    // "Origin": "file://"
  };

  Axios(AxiosAccount account) {
    _account = account;
  }

  static Future<List<School>> searchSchools(String query) async {
    if (query.trim().length < 3) return [];

    final session = new Axios(new AxiosAccount("", "", ""));
    final url = Axios._getURL("GET", "RetrieveAPPCustomerInformationByString",
        data: {"sSearch": query, "sVendorToken": VENDOR_TOKEN});
    final res = await session._makeCall<dynamic>(url, model: (raw) {
      List<dynamic> list = raw;
      return list.map((e) => School.fromJson(e)).toList();
    });
    return res;
  }

  Future<Login?> _getSession() async {
    try {
      if (this._session == null ||
          DateTime.now().difference(sessionStart).inMinutes >
              10 /*  || _requests >= kMaxRequests */)
        await this.login();
      else {
        final res = this._session;
        if (res == null) await this.login();
      }
      return this._session;
    } catch (e) {
      // this._session = null;
      // print("$e ${this._account}");
      // return _RawAPIResponse.error("No session\n" + e.toString());
      return null;
    }
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
      final res = await client.requestUri(Uri.tryParse(url)!,
          options: Options(
            headers: headers,
            method: method,
          ),
          data: body);
      //     req.url, {
      //     ...req,
      //     method: req.method
      // });

      final text = res.toString();
      dynamic data = _RawAPIResponse(
          jsonDecode(Encrypter.decrypt(text).replaceAll("#CR#", "\\n")));

      if (data.errorcode != 0) {
        if (data.errormessage.contains("9999|Utente non trovato")) {
          print("Got error: Utente non trovato");
          if (lastCall != null) {
            _session = null;
            return _retryLastCall(lastCall);
          } else {
            print(" └> Additionally, no last call was provided.");
          }
        }
        throw (data.errormessage);
      }

      return model(data.response);
    } on DioError catch (e) {
      onError();
      throw e;
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
    var session; // = await this._getSession();
    do {
      session = await this._getSession();
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
      "sCodiceFiscale": this._account.schoolID,
      "sVendorToken": VENDOR_TOKEN,
      "sCommandJSON": sCommandJSON,
      "sSessionGuid": session.sessionUUID,
    };

    final _method = method ?? (data == null ? "GET" : "POST");

    // Set the last call so that we can retry it in case of session expiration.
    final lastCall = _LastCall(
      svc: svc,
      model: model,
      path: path,
      data: data,
      sModule: sModule,
      method: method,
    );

    if (_method == "POST") {
      // print(json);
      return this._makeCall<T>(
        Axios._getURL(_method, path, data: json),
        model: model,
        method: _method,
        headers: _method == "POST" ? defaultPOSTHeaders : defaultHeaders,
        body: jsonEncode(
            {"JsonRequest": Encrypter.encryptPost(jsonEncode(json))}),
        lastCall: lastCall,
      );
    }
    return this._makeCall<T>(
      Axios._getURL(_method, path, data: json),
      model: model,
      method: _method,
      headers: _method == "POST" ? defaultPOSTHeaders : defaultHeaders,
      lastCall: lastCall,
    );
  }

  static String _getURL(String method, String path, {dynamic data}) {
    const URL = "https://wssd.axioscloud.it/webservice/AxiosCloud_Ws_Rest.svc/";
    switch (method.toLowerCase()) {
      case "post":
        return "$URL$path";
      default:
        return "$URL$path?${Encrypter.encrypt(jsonEncode(data))}";
    }
  }

  Future<Login> login() async {
    final url = Axios._getURL("GET", "Login", data: {
      "sAppName": "FAM_APP",
      "sCodiceFiscale": this._account.schoolID,
      "sUserName": this._account.userID,
      "sPassword": this._account.userPassword,
      "sVendorToken": VENDOR_TOKEN
    });
    final res =
        await this._makeCall<Login>(url, model: (map) => Login.fromJson(map));
    this._session = res;
    final students = await this.getStudents();
    if (this.student == null) this.student = students[0];
    this._students = students;

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
    if (_students.length > 0 && !forceReload)
      return _students;
    else {
      final res =
          await this._makeAuthenticatedCall<dynamic>("GET_STUDENTI", (raw) {
        List<dynamic> list = raw;
        return list.map((e) => Student.fromJson(e)).toList();
      });
      return res;
    }
  }

  Future<List<Assignment>> getAssignments() async {
    final List<APIAssignments> res =
        await this._makeAuthenticatedCall<dynamic>("GET_COMPITI_MASTER", (raw) {
      return (raw as List).map((e) => APIAssignments.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.compiti)
        .expand((i) => i)
        .toList();
  }

  Future<List<Grade>> getGrades() async {
    final structural = await this.getStructural();
    final List<APIGrades> res = await this
        ._makeAuthenticatedCall<dynamic>("GET_VOTI_LIST_DETAIL", (raw) {
      return (raw as List).map((e) => APIGrades.fromJson(e)).toList();
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
        .toList()
        .reversed
        .expand((i) => i)
        .toList()
        .reversed
        .toList();
  }

  Future<Structural> getStructural() async {
    return await this._makeAuthenticatedCall<Structural>(
      "GET_STRUCTURAL",
      (json) => Structural.fromJson(json),
    );
  }

  Future<List<Period>> getPeriods() async {
    final res = await this.getStructural();
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
      // print("error: $e");
      return null;
    }
  }

  Future<List<ReportCard>> getReportCards([bool forceReload = false]) async {
    final res = await this
        ._makeAuthenticatedCall<dynamic>("GET_PAGELLA_MASTER_V3", (raw) {
      List<dynamic> list = raw;
      return list.map((e) => ReportCard.fromJson(e)).toList();
    });
    return res;
  }

  Future<List<Topic>> getTopics() async {
    final List<APITopics> res = await this
        ._makeAuthenticatedCall<dynamic>("GET_ARGOMENTI_MASTER", (raw) {
      return (raw as List).map((e) => APITopics.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.argomenti)
        .expand((i) => i)
        .toList();
  }

  Future<List<Bulletin>> getBulletins() async {
    final List<APIBulletins> res = await this
        ._makeAuthenticatedCall<dynamic>("GET_COMUNICAZIONI_MASTER", (raw) {
      return (raw as List).map((e) => APIBulletins.fromJson(e)).toList();
    });
    // print(res.map((e) => e.toJson()));
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.comunicazioni)
        .expand((i) => i)
        .toList()
        .reversed
        .toList();
  }

  Future<List<Note>> getNotes() async {
    final List<APINotes> res =
        await this._makeAuthenticatedCall<dynamic>("GET_NOTE_MASTER", (raw) {
      return (raw as List).map((e) => APINotes.fromJson(e)).toList();
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
        await this._makeAuthenticatedCall<dynamic>("GET_ASSENZE_MASTER", (raw) {
      return (raw as List).map((e) => APIAbsences.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.assenze.map((note) => note
            .setSession(this)
            .setPeriod(e.descFrazione)
            .setKinds(structural)))
        .expand((i) => i)
        .toList()
        .reversed
        .toList();
  }

  Future<List<MaterialTeacherData>> getMaterials() async {
    final List<APIMaterials> res = await this
        ._makeAuthenticatedCall<dynamic>("GET_MATERIALE_MASTER", (raw) {
      return (raw as List).map((e) => APIMaterials.fromJson(e)).toList();
    });
    return res
        .where((element) => element.idAlunno == student!.studentUUID)
        .map((e) => e.docenti
          ..forEach((teacher) {
            teacher.folders.forEach((folder) {
              folder.setSession(this).setTeacher(teacher);
            });
          }))
        .expand((i) => i)
        .toList();
  }

  Future<List<MaterialData>> getMaterialDetails(
      String teacherUUID, String folderUUID) async {
    final List<MaterialData> res = await this._makeAuthenticatedCall<dynamic>(
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

  Future<List<Authorization>> getAuthorizations() async {
    final structural = await getStructural();
    final List<APIAuthorizations> res = await this
        ._makeAuthenticatedCall<dynamic>("GET_AUTORIZZAZIONI_MASTER", (raw) {
      // print(jsonEncode(raw));
      // return [];
      return (raw as List).map((e) => APIAuthorizations.fromJson(e)).toList();
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
                .setPeriod(periods.getCurrentPeriod()?.desc ?? "")
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
    topics.forEach((topic) {
      if (topic.subject.isNotEmpty) {
        res.add(topic.subject);
      }
    });
    assignments.forEach((assignment) {
      if (assignment.subject.isNotEmpty) {
        res.add(assignment.subject);
      }
    });

    return res.toSet().toList();
  }

  Future<void> markBulletinAsRead(Bulletin bulletin) async {
    String result = await this._makeAuthenticatedCall(
      "APP_PROCESS_QUEUE",
      (_any) => "$_any",
      "ExecuteCommand",
      {"comunicazioneId": bulletin.id, "alunnoId": this.student?.studentUUID},
      "COMUNICAZIONI_READ",
    );

    bulletin.read = result.toString().contains("ok");
  }

  Future<void> markGradeAsRead(Grade grade) async {
    Student? student = this.student;
    String gradeBit = student?.securityBits[22] ?? "1";

    if (gradeBit == "0") return;

    String result = await this._makeAuthenticatedCall(
      "APP_PROCESS_QUEUE",
      (_any) => "$_any",
      "ExecuteCommand",
      {
        "idVoto": grade.id,
        "idAlunno": student?.studentUUID,
        "pin": gradeBit == "1" ? "" : this._session?.pin
      },
      "VOTO_VISTA",
    );

    bool read = result.toString().contains("ok");

    if (read) {
      grade.seen = read;
      grade.seenBy = "${this._session?.firstName} ${this._session?.lastName}";
      grade.seenOn = DateTime.now();
    }
  }

  Future<bool> justifyAbsence(Absence absence) async {
    Login login = await this.login();
    Student? student = this.student;

    if (student == null) return false;

    String result = await this._makeAuthenticatedCall(
      "APP_PROCESS_QUEUE",
      (_any) => "$_any",
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

    String result = await this._makeAuthenticatedCall(
      "APP_PROCESS_DIRECT",
      (_any) => "$_any",
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
      await this.markBulletinAsRead(bulletin);
    }
    return true;
  }
}
