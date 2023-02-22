import 'package:logger/logger.dart';
import 'package:reaxios/enums/GradeDisplay.dart';

class GradeAlertBoundaries {
  double underFailure, borderline, successBoundary, overSuccess;
  GradeAlertBoundaries._(
    this.underFailure,
    this.borderline,
    this.successBoundary,
    this.overSuccess,
  );

  static final GradeAlertBoundaries _letter = GradeAlertBoundaries._(
    5,
    6,
    7.5,
    8.5,
  );
  static final GradeAlertBoundaries _decimal = GradeAlertBoundaries._(
    5,
    6,
    7,
    8,
  );
  static final GradeAlertBoundaries _percentage = GradeAlertBoundaries._(
    5,
    6,
    7,
    8,
  );

  static GradeAlertBoundaries get(GradeDisplay type) {
    Logger.d(type.toString());
    switch (type) {
      case GradeDisplay.letter:
        return _letter;
      case GradeDisplay.decimal:
        return _decimal;
      case GradeDisplay.percentage:
        return _percentage;
      default:
        return _decimal;
    }
  }
}
