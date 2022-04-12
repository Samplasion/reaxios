import 'dart:math';

import 'package:dio/dio.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Meeting/Meeting.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/enums/ReportCardSubjectKind.dart';
import 'package:reaxios/api/utils/utils.dart';

class TestAxios implements Axios {
  TestAxios() : super();

  ComputeImpl compute = defaultCompute;

  @override
  void Function() get onError => () => print("error");
  set onError(void Function() onError) {}

  @override
  DateTime sessionStart = DateTime.now();

  @override
  Student? student = Student.test();

  DateTime get _fakeDate =>
      DateTime.now().subtract(Duration(days: Random().nextInt(14) - 7));

  @override
  AxiosAccount get account =>
      AxiosAccount(student!.schoolUUID, student!.studentUUID, "passw0rd!");

  @override
  Dio get client => Dio();

  @override
  Future<List<Absence>> getAbsences() async {
    return [Absence.test()];
  }

  Assignment _assignment(String sub, String assmt) => Assignment(
        date: _fakeDate,
        publicationDate: _fakeDate,
        subject: sub,
        lessonHour: (Random().nextInt(5) + 1),
        id: "76712890",
        assignment: assmt,
      );
  @override
  Future<List<Assignment>> getAssignments() async {
    return [
      _assignment("Matematica", "Pag. 280-293; es. 4-9 pag. 297"),
      _assignment("Disegno e Storia dell'Arte", "Libro rosso pag. 387-407"),
      _assignment("Fisica", "Pag. 45-50; es. 5-30 pag. 10-15"),
      _assignment("Religione", "Terminare visione del film"),
      _assignment("Lingua e Cultura Italiana", "Pag. 589-591"),
      _assignment("Storia", "La Dichiarazione d'Indipendenza"),
      _assignment("Informatica", "La programmazione ad oggetti"),
      _assignment("Scienze Naturali", "La meccanica quantistica"),
      _assignment("Educazione Civica", "Il diritto dell'umanità"),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<Authorization>> getAuthorizations() async {
    return [
      Authorization.test()
        ..setSession(this)
        ..setKinds(await this.getStructural())
        ..setPeriod("I QUADRIMESTRE")
    ];
  }

  @override
  Future<List<Bulletin>> getBulletins() async {
    return [Bulletin.test()];
  }

  @override
  Future<Period?> getCurrentPeriod() async {
    final year = DateTime.now().year;
    return Period(
      id: "E8F10619-1823-4004-B215-B299FEAF3C9F",
      desc: "I QUADRIMESTRE",
      startDate: DateTime(year, 9, 15),
      endDate: DateTime(year + 1, 6, 8),
    );
  }

  @override
  Future<List<Grade>> getGrades() async {
    final now = DateTime.now();
    return [
      Grade.test(
        7.75,
        "Lingua e Letteratura Italiana",
        "Vittoria Scassi",
        "Interrogazione sulla Divina Commedia",
        date: now.subtract(Duration(days: 7)),
      ),
      Grade.test(
        6.5,
        "Disegno e Storia dell'Arte",
        "Ugo Spitaliere",
        "Esposizione PowerPoint sull'Arte Gotica",
        date: now.subtract(Duration(days: 4)),
        kind: "Altro/Unico",
      ),
      Grade.test(
        9.00,
        "Religione",
        "Marco Ghironi",
        "Partecipazione attiva",
        date: now.subtract(Duration(days: 3)),
        kind: "Altro/Unico",
      ),
      Grade.test(
        9.50,
        "Informatica",
        "Giuseppe Carollo",
        "Verifica sull'iterazione: ciclo while, do/while e for.",
        date: now.subtract(Duration(days: 2)),
        kind: "Scritto",
      ),
      Grade.test(
        7.50,
        "Scienze Naturali",
        "Giovanni Pizzi",
        "Interrogazione sulla meccanica quantistica",
        date: now.subtract(Duration(days: 9)),
      ),
      Grade.test(
        7.50,
        "Matematica",
        "Alessandro Bresciani",
        "Verifica sulle funzioni",
        date: now.subtract(Duration(days: 18)),
        kind: "Scritto",
      ),
      Grade.test(
        9,
        "Informatica",
        "Giuseppe Carollo",
        "Interrogazione sull'iterazione",
        date: now.subtract(Duration(days: 12)),
      )
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<MaterialData>> getMaterialDetails(
      String teacherUUID, String folderUUID) async {
    return [MaterialData.test()];
  }

  @override
  Future<List<MaterialTeacherData>> getMaterials() async {
    return [MaterialTeacherData.test()];
  }

  @override
  Future<List<Note>> getNotes() async {
    return [Note.test()];
  }

  @override
  Future<List<Period>> getPeriods() async {
    final period = await getCurrentPeriod();
    return [period!];
  }

  @override
  Future<List<ReportCard>> getReportCards([bool forceReload = false]) async {
    final grades = await this.getGrades();
    return [
      ReportCard(
        studentUUID: "634F8D7A-0717-416D-A9E5-8A36BAA36B56",
        periodUUID: "E93641D9-E871-4607-953A-71797476A891",
        periodCode: '425678',
        period: "I QUADRIMESTRE",
        result: "Ammesso",
        rating: "Ottimo",
        url: "",
        read: true,
        visible: true,
        subjects: [
          for (String subject in grades.map((e) => e.subject).toSet())
            ReportCardSubject(
              id: "D840640D-CF1A-416E-88BB-93EF40839E29",
              name: subject,
              kind: ReportCardSubjectKind.Other,
              recoveryKind: '',
              absences: Random().nextInt(20).toDouble(),
              gradeAverage: gradeAverage(
                  grades.where((e) => subject == e.subject).toList()),
              details: [
                ReportCardSubjectDetail(
                  kind: "Unico",
                  label: "Unico",
                  textGrade: gradeText(gradeAverage(
                          grades.where((e) => subject == e.subject).toList())
                      .round()),
                  grade: gradeAverage(
                          grades.where((e) => subject == e.subject).toList())
                      .round(),
                )
              ],
            ),
        ],
        dateRead: DateTime.now(),
        canViewAbsences: true,
      )
    ];
  }

  @override
  Future<Structural> getStructural() async {
    return Structural(
      periods: [
        Periods(
          schoolID: this.student!.schoolUUID,
          periods: await this.getPeriods(),
        ),
      ],
      gradeKinds: [
        GradeKinds(
          schoolID: this.student!.schoolUUID,
          kinds: [
            GradeKind(
              kind: "Orale",
              code: "O",
              desc: "Orale",
            )
          ],
        ),
      ],
      absenceKinds: [
        SimpleKind(kind: "C", desc: "desc"),
      ],
      authorizationKinds: [
        SimpleKind(kind: "C", desc: "desc"),
      ],
      justificationKinds: [
        SimpleKind(kind: "C", desc: "desc"),
      ],
    );
  }

  @override
  Future<List<Student>> getStudents([bool forceReload = false]) async {
    return this.students;
  }

  @override
  Future<List<String>> getSubjects() async {
    return (await this.getGrades())
        .map((grade) => grade.subject)
        .toList()
        .toSet()
        .toList();
  }

  Topic _topic(String subj, String desc) {
    return Topic(
      id: "D840640D-CF1A-416E-88BB-93EF40839E29",
      topic: desc,
      subject: subj,
      date: _fakeDate.subtract(Duration(days: 7)),
      publicationDate: _fakeDate.subtract(Duration(days: 7)),
      lessonHour: (Random().nextInt(5) + 1).toString(),
      flags: "",
    );
  }

  @override
  Future<List<Topic>> getTopics() async {
    return [
      _topic("Informatica",
          "Verifica sull'iterazione: ciclo while, do/while e for."),
      _topic("Storia", "Introduzione alla rivoluzione industriale"),
      _topic("Scienze Naturali", "Principio di Aufbau"),
      _topic(
          "Lingua e Letteratura Italiana", "Francesco Petrarca; il Canzoniere"),
      _topic("Disegno e Storia dell'Arte",
          "Verifica ed esposizione PowerPoint sull'Arte Gotica"),
      _topic("Religione", "Visione del film di Giuseppe Carollo"),
      _topic("Informatica",
          "Introduzione all'Intelligenza artificiale: GitHub Copilot."),
    ];
  }

  @override
  Future<bool> justifyAbsence(Absence absence) async {
    return true;
  }

  @override
  Future<bool> justifyAuthorization(Authorization authorization) async {
    return true;
  }

  @override
  Future<Login> login() async {
    return Login(
      pin: "1234",
      schoolID: "098765432",
      schoolName: "A.S. di Alessandro Volta",
      schoolTitle: "Liceo Scientifico",
      sessionUUID: '8B8A476B-0C04-45F8-A9F4-2E552124EE53',
      id: 3,
      // Parent name
      firstName: "Valeria",
      lastName: "Tarantino",
      avatar: "",
      userID: "12456",
      password: "passw0rd!",
      kind: "studente",
      birthday: new DateTime(2004, 04, 21),
    );
  }

  @override
  Future<Bulletin> markBulletinAsRead(Bulletin bulletin) async => bulletin;

  @override
  Future<void> markGradeAsRead(Grade grade) async {}

  @override
  Future<bool> readAllBulletins() async {
    return true;
  }

  @override
  List<Student> get students => [this.student!];

  @override
  Future<List<MeetingSchema>> getTeacherMeetings() async {
    return [];
  }
}

gradeText(int round) {
  switch (round) {
    case 0:
      return "ZERO";
    case 1:
      return "UNO";
    case 2:
      return "DUE";
    case 3:
      return "TRE";
    case 4:
      return "QUATTRO";
    case 5:
      return "CINQUE";
    case 6:
      return "SEX";
    case 7:
      return "SETTE";
    case 8:
      return "OTTO";
    case 9:
      return "NOVE";
    case 10:
      return "DIECI";
  }
}
