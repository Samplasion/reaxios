part of 'app_cubit.dart';

@JsonSerializable()
class AppState extends Equatable {
  @override
  final bool? stringify = true;

  final bool testMode;

  @AxiosConverter()
  final Axios? axios;
  final School? school;
  final List<Assignment>? assignments;
  final List<Grade>? grades;
  final List<Topic>? topics;
  final List<ReportCard>? reportCards;
  final List<Bulletin>? bulletins;
  final List<Note>? notes;
  final List<Absence>? absences;
  final List<Authorization>? authorizations;
  final List<MaterialTeacherData>? materials;
  final List<MeetingSchema>? meetings;
  final Structural? structural;

  bool get isEmpty =>
      assignments == null &&
      grades == null &&
      topics == null &&
      reportCards == null &&
      bulletins == null &&
      notes == null &&
      absences == null &&
      authorizations == null &&
      materials == null &&
      meetings == null &&
      structural == null;

  const AppState({
    required this.testMode,
    this.axios,
    this.school,
    this.assignments,
    this.grades,
    this.topics,
    this.reportCards,
    this.bulletins,
    this.notes,
    this.absences,
    this.authorizations,
    this.materials,
    this.meetings,
    this.structural,
  });

  // Use _propsX for potentially expensive lists that could freeze the UI
  @override
  List<Object?> get props => [
        testMode,
        axios,
        school,
        _propsAssignments,
        _propsGrades,
        _propsTopics,
        reportCards,
        bulletins,
        notes,
        absences,
        authorizations,
        materials,
        meetings,
        structural,
      ];

  List<Object?> get _propsAssignments => [
        assignments?.length,
      ];

  List<Object?> get _propsGrades => [
        grades?.length,
        grades?.where((g) => g.seen).length,
      ];

  List<Object?> get _propsTopics => [
        topics?.length,
      ];

  factory AppState.empty() => AppState(testMode: false, school: null);

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  AppState copyWith({
    bool? testMode,
    Axios? axios,
    School? school,
    List<Assignment>? assignments,
    List<Grade>? grades,
    List<Topic>? topics,
    List<ReportCard>? reportCards,
    List<Bulletin>? bulletins,
    List<Note>? notes,
    List<Absence>? absences,
    List<Authorization>? authorizations,
    List<MaterialTeacherData>? materials,
    List<MeetingSchema>? meetings,
    Structural? structural,
  }) {
    return AppState(
      testMode: testMode ?? this.testMode,
      axios: axios ?? this.axios,
      school: school ?? this.school,
      assignments: assignments ?? this.assignments,
      grades: grades ?? this.grades,
      topics: topics ?? this.topics,
      reportCards: reportCards ?? this.reportCards,
      bulletins: bulletins ?? this.bulletins,
      notes: notes ?? this.notes,
      absences: absences ?? this.absences,
      authorizations: authorizations ?? this.authorizations,
      materials: materials ?? this.materials,
      meetings: meetings ?? this.meetings,
      structural: structural ?? this.structural,
    );
  }
}

class AxiosConverter implements JsonConverter<Axios?, Map<String, dynamic>> {
  const AxiosConverter();

  @override
  Axios? fromJson(Map<String, dynamic> json) {
    return Axios(AxiosAccount.fromJson(json), compute: compute);
  }

  @override
  Map<String, dynamic> toJson(Axios? instance) {
    return instance?.account.toJson() ?? {};
  }
}
