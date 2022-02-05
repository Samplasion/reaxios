// This is a Class because I need to store some data that identifies
// the subject, both to the user and to the application.

/// Identifies a subject and stores a custom target.
///
/// This class is used to serialize together information about a subject
/// along with a custom target defined by the user.
class SubjectObjective {
  final String subjectName;
  final String subjectID;
  final int year;
  final double objective;

  SubjectObjective({
    required this.subjectName,
    required this.subjectID,
    required this.year,
    required this.objective,
  }) : assert(objective >= 1.0 && objective <= 10.0);

  factory SubjectObjective.fromJson(Map<String, dynamic> json) {
    return SubjectObjective(
      subjectName: json['subjectName'],
      subjectID: json['subjectID'],
      year: json['year'],
      objective: json['objective'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'subjectID': subjectID,
      'year': year,
      'objective': objective,
    };
  }

  copyWith({
    String? subjectName,
    String? subjectID,
    int? year,
    double? objective,
  }) {
    return SubjectObjective(
      subjectName: subjectName ?? this.subjectName,
      subjectID: subjectID ?? this.subjectID,
      year: year ?? this.year,
      objective: objective ?? this.objective,
    );
  }
}
