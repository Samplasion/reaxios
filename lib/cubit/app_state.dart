part of 'app_cubit.dart';

@JsonSerializable()
class AppState extends Equatable {
  @override
  final bool? stringify = true;

  @AxiosConverter()
  final Axios? axios;
  final School? school;
  final List<Assignment>? assignments;

  const AppState({
    this.axios,
    this.school,
    this.assignments,
  });

  @override
  List<Object?> get props => [
        axios,
        school,
        assignments,
      ];

  factory AppState.empty() => AppState(school: null);

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  AppState copyWith({
    Axios? axios,
    School? school,
    List<Assignment>? assignments,
  }) {
    return AppState(
      axios: axios ?? this.axios,
      school: school ?? this.school,
      assignments: assignments ?? this.assignments,
    );
  }
}

class AxiosConverter implements JsonConverter<Axios?, Map<String, dynamic>> {
  const AxiosConverter();

  @override
  Axios? fromJson(Map<String, dynamic> json) {
    return Axios(AxiosAccount.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson(Axios? instance) {
    return instance?.account.toJson() ?? {};
  }
}
