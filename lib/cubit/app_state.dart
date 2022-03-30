part of 'app_cubit.dart';

@JsonSerializable()
class AppState extends Equatable {
  @override
  final bool? stringify = true;

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
  final Structural? structural;

  bool get isEmpty =>
      assignments == null &&
      grades == null &&
      topics == null &&
      reportCards == null &&
      bulletins == null &&
      notes == null &&
      absences == null &&
      structural == null;

  const AppState({
    this.axios,
    this.school,
    this.assignments,
    this.grades,
    this.topics,
    this.reportCards,
    this.bulletins,
    this.notes,
    this.absences,
    this.structural,
  });

  @override
  List<Object?> get props => [
        axios,
        school,
        assignments,
        grades,
        topics,
        reportCards,
        bulletins,
        notes,
        absences,
        structural,
      ];

  factory AppState.empty() => AppState(school: null);

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  AppState copyWith({
    Axios? axios,
    School? school,
    List<Assignment>? assignments,
    List<Grade>? grades,
    List<Topic>? topics,
    List<ReportCard>? reportCards,
    List<Bulletin>? bulletins,
    List<Note>? notes,
    List<Absence>? absences,
    Structural? structural,
  }) {
    return AppState(
      axios: axios ?? this.axios,
      school: school ?? this.school,
      assignments: assignments ?? this.assignments,
      grades: grades ?? this.grades,
      topics: topics ?? this.topics,
      reportCards: reportCards ?? this.reportCards,
      bulletins: bulletins ?? this.bulletins,
      notes: notes ?? this.notes,
      absences: absences ?? this.absences,
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
