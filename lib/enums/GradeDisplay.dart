enum GradeDisplay { letter, decimal, percentage }

extension Serialization on GradeDisplay {
  String get serialized {
    switch (this) {
      case GradeDisplay.letter:
        return 'letter';
      case GradeDisplay.decimal:
        return 'decimal';
      case GradeDisplay.percentage:
        return 'percentage';
    }
  }
}

GradeDisplay deserializeGradeDisplay(String serialized) {
  switch (serialized) {
    case 'letter':
      return GradeDisplay.letter;
    case 'decimal':
      return GradeDisplay.decimal;
    case 'percentage':
      return GradeDisplay.percentage;
  }
  return GradeDisplay.decimal;
}
