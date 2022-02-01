enum AverageMode { allGradesAverage, averageOfAverages }

extension Serialization on AverageMode {
  String get serialized {
    switch (this) {
      case AverageMode.allGradesAverage:
        return 'allGradesAverage';
      case AverageMode.averageOfAverages:
        return 'averageOfAverages';
    }
  }
}

AverageMode deserializeAverageMode(String serialized) {
  switch (serialized) {
    case 'allGradesAverage':
      return AverageMode.allGradesAverage;
    case 'averageOfAverages':
      return AverageMode.averageOfAverages;
  }
  return AverageMode.allGradesAverage;
}
