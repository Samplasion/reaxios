import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocaleBase {
  late Map<String, dynamic> _data;
  late String _path;
  Future<void> load(String path) async {
    _path = path;
    final strJson = await rootBundle.loadString(path);
    _data = jsonDecode(strJson);
    initAll();
  }
  
  Map<String, String> getData(String group) {
    return Map<String, String>.from(_data[group]);
  }

  String getPath() => _path;

  late Localemain _main;
  Localemain get main => _main;
  late Localelogin _login;
  Localelogin get login => _login;
  late Localedrawer _drawer;
  Localedrawer get drawer => _drawer;
  late Localeabout _about;
  Localeabout get about => _about;
  late Localeoverview _overview;
  Localeoverview get overview => _overview;
  late Localeabsences _absences;
  Localeabsences get absences => _absences;
  late Localecalendar _calendar;
  Localecalendar get calendar => _calendar;
  late Localecharts _charts;
  Localecharts get charts => _charts;
  late Localeauthorizations _authorizations;
  Localeauthorizations get authorizations => _authorizations;
  late LocaleteachingMaterials _teachingMaterials;
  LocaleteachingMaterials get teachingMaterials => _teachingMaterials;
  late Localegrades _grades;
  Localegrades get grades => _grades;
  late Localestats _stats;
  Localestats get stats => _stats;
  late Localebulletins _bulletins;
  Localebulletins get bulletins => _bulletins;
  late Localeplurals _plurals;
  Localeplurals get plurals => _plurals;
  late Localeobjectives _objectives;
  Localeobjectives get objectives => _objectives;
  late Localesettings _settings;
  Localesettings get settings => _settings;
  late LocalereportCard _reportCard;
  LocalereportCard get reportCard => _reportCard;
  late Localeassignments _assignments;
  Localeassignments get assignments => _assignments;
  late LocaledisciplinaryNotices _disciplinaryNotices;
  LocaledisciplinaryNotices get disciplinaryNotices => _disciplinaryNotices;
  late Localetopics _topics;
  Localetopics get topics => _topics;

  void initAll() {
    _main = Localemain(Map<String, String>.from(_data['main']));
    _login = Localelogin(Map<String, String>.from(_data['login']));
    _drawer = Localedrawer(Map<String, String>.from(_data['drawer']));
    _about = Localeabout(Map<String, String>.from(_data['about']));
    _overview = Localeoverview(Map<String, String>.from(_data['overview']));
    _absences = Localeabsences(Map<String, String>.from(_data['absences']));
    _calendar = Localecalendar(Map<String, String>.from(_data['calendar']));
    _charts = Localecharts(Map<String, String>.from(_data['charts']));
    _authorizations = Localeauthorizations(Map<String, String>.from(_data['authorizations']));
    _teachingMaterials = LocaleteachingMaterials(Map<String, String>.from(_data['teachingMaterials']));
    _grades = Localegrades(Map<String, String>.from(_data['grades']));
    _stats = Localestats(Map<String, String>.from(_data['stats']));
    _bulletins = Localebulletins(Map<String, String>.from(_data['bulletins']));
    _plurals = Localeplurals(Map<String, String>.from(_data['plurals']));
    _objectives = Localeobjectives(Map<String, String>.from(_data['objectives']));
    _settings = Localesettings(Map<String, String>.from(_data['settings']));
    _reportCard = LocalereportCard(Map<String, String>.from(_data['reportCard']));
    _assignments = Localeassignments(Map<String, String>.from(_data['assignments']));
    _disciplinaryNotices = LocaledisciplinaryNotices(Map<String, String>.from(_data['disciplinaryNotices']));
    _topics = Localetopics(Map<String, String>.from(_data['topics']));
  }
}

class Localemain {
  late final Map<String, String> _data;
  Localemain(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get logoutTitle => _data["logoutTitle"]!;
  String get logoutBody => _data["logoutBody"]!;
  String get lessonHour => _data["lessonHour"]!;
  String get genderM => _data["genderM"]!;
  String get genderF => _data["genderF"]!;
  String get idleText => _data["idleText"]!;
  String get completeText => _data["completeText"]!;
  String get releaseText => _data["releaseText"]!;
  String get refreshingText => _data["refreshingText"]!;
  String get failedText => _data["failedText"]!;
  String get failedLinkOpen => _data["failedLinkOpen"]!;
  String get failedFileDownload => _data["failedFileDownload"]!;
  String get downloadButtonLabel => _data["downloadButtonLabel"]!;
  String get noDataForPeriod => _data["noDataForPeriod"]!;
  String get noPermission => _data["noPermission"]!;
  String get didYouKnow => _data["didYouKnow"]!;
}

class Localelogin {
  late final Map<String, String> _data;
  Localelogin(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get selectSchool => _data["selectSchool"]!;
  String get title => _data["title"]!;
  String get searchBarPlaceholder => _data["searchBarPlaceholder"]!;
  String get back => _data["back"]!;
  String get next => _data["next"]!;
  String get userIDPlaceholder => _data["userIDPlaceholder"]!;
  String get passwordPlaceholder => _data["passwordPlaceholder"]!;
  String get loginButtonText => _data["loginButtonText"]!;
  String get loginPhaseTwoTitle => _data["loginPhaseTwoTitle"]!;
}

class Localedrawer {
  late final Map<String, String> _data;
  Localedrawer(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get teachingMaterials => _data["teachingMaterials"]!;
  String get overview => _data["overview"]!;
  String get calendar => _data["calendar"]!;
  String get assignments => _data["assignments"]!;
  String get grades => _data["grades"]!;
  String get topics => _data["topics"]!;
  String get secretary => _data["secretary"]!;
  String get teacherNotes => _data["teacherNotes"]!;
  String get absences => _data["absences"]!;
  String get stats => _data["stats"]!;
  String get authorizations => _data["authorizations"]!;
  String get notices => _data["notices"]!;
  String get reportCards => _data["reportCards"]!;
  String get settings => _data["settings"]!;
  String get logOut => _data["logOut"]!;
}

class Localeabout {
  late final Map<String, String> _data;
  Localeabout(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get aboutApp => _data["aboutApp"]!;
  String get synopsis => _data["synopsis"]!;
  String get longDescription => _data["longDescription"]!;
}

class Localeoverview {
  late final Map<String, String> _data;
  Localeoverview(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get latestGrades => _data["latestGrades"]!;
  String get latestLessons => _data["latestLessons"]!;
  String get homeworkForTomorrow => _data["homeworkForTomorrow"]!;
  String get average => _data["average"]!;
  String get grades => _data["grades"]!;
  String get assignments => _data["assignments"]!;
  String get topics => _data["topics"]!;
}

class Localeabsences {
  late final Map<String, String> _data;
  Localeabsences(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get noPermission => _data["noPermission"]!;
  String get empty => _data["empty"]!;
  String get sectionAlertBody => _data["sectionAlertBody"]!;
  String get sectionAlertTitle => _data["sectionAlertTitle"]!;
  String get justifiedSubtitle => _data["justifiedSubtitle"]!;
  String get typeAssenze => _data["typeAssenze"]!;
  String get typeRitardi => _data["typeRitardi"]!;
  String get typeUscite => _data["typeUscite"]!;
  String get typeOther => _data["typeOther"]!;
  String get justifiedSnackbar => _data["justifiedSnackbar"]!;
  String get errorSnackbar => _data["errorSnackbar"]!;
  String get justifyButtonLabel => _data["justifyButtonLabel"]!;
  String get alreadyJustified => _data["alreadyJustified"]!;
}

class Localecalendar {
  late final Map<String, String> _data;
  Localecalendar(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get formatWeek => _data["formatWeek"]!;
  String get formatTwoWeeks => _data["formatTwoWeeks"]!;
  String get formatMonth => _data["formatMonth"]!;
  String get homework => _data["homework"]!;
  String get topics => _data["topics"]!;
  String get noEvents => _data["noEvents"]!;
}

class Localecharts {
  late final Map<String, String> _data;
  Localecharts(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get average => _data["average"]!;
  String get averages => _data["averages"]!;
  String get scopeAllYear => _data["scopeAllYear"]!;
  String get noData => _data["noData"]!;
  String get fewGradesText => _data["fewGradesText"]!;
  String get trend => _data["trend"]!;
}

class Localeauthorizations {
  late final Map<String, String> _data;
  Localeauthorizations(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get typeA => _data["typeA"]!;
  String get typeR => _data["typeR"]!;
  String get typeU => _data["typeU"]!;
  String get typeE => _data["typeE"]!;
  String get typeOther => _data["typeOther"]!;
  String get justifiedSubtitle => _data["justifiedSubtitle"]!;
  String get calculated => _data["calculated"]!;
  String get notCalculated => _data["notCalculated"]!;
  String get justifiedSnackbar => _data["justifiedSnackbar"]!;
  String get errorSnackbar => _data["errorSnackbar"]!;
  String get justifyButtonLabel => _data["justifyButtonLabel"]!;
  String get justifiedBy => _data["justifiedBy"]!;
  String get empty => _data["empty"]!;
}

class LocaleteachingMaterials {
  late final Map<String, String> _data;
  LocaleteachingMaterials(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get foldersZero => _data["foldersZero"]!;
  String get foldersOne => _data["foldersOne"]!;
  String get foldersTwo => _data["foldersTwo"]!;
  String get foldersFew => _data["foldersFew"]!;
  String get foldersMany => _data["foldersMany"]!;
  String get foldersOther => _data["foldersOther"]!;
  String get noDescription => _data["noDescription"]!;
  String get noData => _data["noData"]!;
  String get teacherNoDataTitle => _data["teacherNoDataTitle"]!;
  String get teacherNoDataText => _data["teacherNoDataText"]!;
  String get emptyFolder => _data["emptyFolder"]!;
  String get noMaterialDescription => _data["noMaterialDescription"]!;
  String get noHost => _data["noHost"]!;
  String get downloadAlertTitle => _data["downloadAlertTitle"]!;
  String get downloadAlertBody => _data["downloadAlertBody"]!;
}

class Localegrades {
  late final Map<String, String> _data;
  Localegrades(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get weight => _data["weight"]!;
  String get value => _data["value"]!;
  String get commentInSubject => _data["commentInSubject"]!;
  String get gradeInSubject => _data["gradeInSubject"]!;
  String get latestGrade => _data["latestGrade"]!;
  String get noGrades => _data["noGrades"]!;
  String get mainPageAverage => _data["mainPageAverage"]!;
  String get objective => _data["objective"]!;
  String get seen => _data["seen"]!;
  String get markAsSeen => _data["markAsSeen"]!;
  String get seenSnackbar => _data["seenSnackbar"]!;
  String get errorSnackbar => _data["errorSnackbar"]!;
}

class Localestats {
  late final Map<String, String> _data;
  Localestats(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get overallAverage => _data["overallAverage"]!;
  String get bestSubject => _data["bestSubject"]!;
  String get worstSubject => _data["worstSubject"]!;
  String get failedSubjects => _data["failedSubjects"]!;
  String get passedSubjects => _data["passedSubjects"]!;
  String get trendHistory => _data["trendHistory"]!;
  String get average => _data["average"]!;
}

class Localebulletins {
  late final Map<String, String> _data;
  Localebulletins(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get typePrincipal => _data["typePrincipal"]!;
  String get typeSecretary => _data["typeSecretary"]!;
  String get typeBoardOfTeachers => _data["typeBoardOfTeachers"]!;
  String get typeTeacher => _data["typeTeacher"]!;
  String get typeOther => _data["typeOther"]!;
  String get openLink => _data["openLink"]!;
  String get download => _data["download"]!;
  String get title => _data["title"]!;
  String get markAsRead => _data["markAsRead"]!;
  String get markedSuccessfully => _data["markedSuccessfully"]!;
  String get markedError => _data["markedError"]!;
  String get alreadyRead => _data["alreadyRead"]!;
  String get downloadBody => _data["downloadBody"]!;
  String get empty => _data["empty"]!;
}

class Localeplurals {
  late final Map<String, String> _data;
  Localeplurals(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get gradesZero => _data["gradesZero"]!;
  String get gradesOne => _data["gradesOne"]!;
  String get gradesTwo => _data["gradesTwo"]!;
  String get gradesFew => _data["gradesFew"]!;
  String get gradesMany => _data["gradesMany"]!;
  String get gradesOther => _data["gradesOther"]!;
  String get teachersZero => _data["teachersZero"]!;
  String get teachersOne => _data["teachersOne"]!;
  String get teachersTwo => _data["teachersTwo"]!;
  String get teachersFew => _data["teachersFew"]!;
  String get teachersMany => _data["teachersMany"]!;
  String get teachersOther => _data["teachersOther"]!;
}

class Localeobjectives {
  late final Map<String, String> _data;
  Localeobjectives(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get lt5Title => _data["lt5Title"]!;
  String get lt5Text => _data["lt5Text"]!;
  String get lt6Title => _data["lt6Title"]!;
  String get lt6Text => _data["lt6Text"]!;
  String get lt7Title => _data["lt7Title"]!;
  String get lt7Text => _data["lt7Text"]!;
  String get lt8Title => _data["lt8Title"]!;
  String get lt8Text => _data["lt8Text"]!;
  String get otherTitle => _data["otherTitle"]!;
  String get otherText => _data["otherText"]!;
}

class Localesettings {
  late final Map<String, String> _data;
  Localesettings(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get title => _data["title"]!;
  String get groupsColorsTitle => _data["groupsColorsTitle"]!;
  String get groupsBehaviorTitle => _data["groupsBehaviorTitle"]!;
  String get changesRestart => _data["changesRestart"]!;
  String get gradeDisplayDecimal => _data["gradeDisplayDecimal"]!;
  String get gradeDisplayLetter => _data["gradeDisplayLetter"]!;
  String get gradeDisplayPercentage => _data["gradeDisplayPercentage"]!;
  String get colorPrimary => _data["colorPrimary"]!;
  String get colorSecondary => _data["colorSecondary"]!;
  String get colorTheme => _data["colorTheme"]!;
  String get colorThemeLight => _data["colorThemeLight"]!;
  String get colorThemeDark => _data["colorThemeDark"]!;
  String get colorThemeDynamic => _data["colorThemeDynamic"]!;
  String get gradeDisplayLabel => _data["gradeDisplayLabel"]!;
  String get groupsAdvancedTitle => _data["groupsAdvancedTitle"]!;
  String get restartAppTitle => _data["restartAppTitle"]!;
  String get restartAppSubtitle => _data["restartAppSubtitle"]!;
  String get chooseColor => _data["chooseColor"]!;
  String get chooseOption => _data["chooseOption"]!;
  String get gradeDisplayPrecise => _data["gradeDisplayPrecise"]!;
}

class LocalereportCard {
  late final Map<String, String> _data;
  LocalereportCard(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get notAvailableTitle => _data["notAvailableTitle"]!;
  String get notAvailableBody => _data["notAvailableBody"]!;
  String get overview => _data["overview"]!;
  String get average => _data["average"]!;
  String get absences => _data["absences"]!;
  String get failedSubjects => _data["failedSubjects"]!;
  String get outcome => _data["outcome"]!;
  String get judgment => _data["judgment"]!;
  String get period => _data["period"]!;
  String get grade => _data["grade"]!;
  String get subjAbsences => _data["subjAbsences"]!;
  String get subjKind => _data["subjKind"]!;
  String get subjGrade => _data["subjGrade"]!;
}

class Localeassignments {
  late final Map<String, String> _data;
  Localeassignments(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get empty => _data["empty"]!;
}

class LocaledisciplinaryNotices {
  late final Map<String, String> _data;
  LocaledisciplinaryNotices(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get empty => _data["empty"]!;
}

class Localetopics {
  late final Map<String, String> _data;
  Localetopics(this._data);

  String getByKey(String key) {
    return _data[key]!;
  }

  String get empty => _data["empty"]!;
}

