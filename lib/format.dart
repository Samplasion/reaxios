import 'package:flutter/foundation.dart';

String formatString(String base, List<dynamic> replacements) {
  // return base.replaceAllMapped(RegExp(r'(?<!(?<!\\)\\)\{\d\}'), (Match match) {
  //   int index =
  //       int.parse(match.group(0)!.substring(1, match.group(0)!.length - 1));
  //   if (index >= replacements.length || index < 0) {
  //     return '{$index}';
  //   }
  //   return "${replacements[index]}";
  // });
  final Map<String, dynamic> replacementMap = {};
  for (int i = 0; i < replacements.length; i++) {
    replacementMap['$i'] = replacements[i];
  }
  return formatStringWithMap(base, replacementMap);
}

String formatStringWithMap(String base, Map<String, dynamic> replacements) {
  return base.replaceAllMapped(
      RegExp(r'(?<!(?<!\\)\\)\{([^}]*)(?<!(?<!\\)\\)\}'), (Match match) {
    String key = match.group(1)!;
    if (replacements.containsKey(key)) {
      return "${replacements[key]}";
    }
    print(
        "Found string without replacement\nString: $base\nMatch: $key\mMap: $replacements");
    return '{$key}';
  });
}

extension FormatStringExtension on String {
  String format(List<dynamic> replacements) {
    return formatString(this, replacements);
  }

  String mapFormat(Map<String, dynamic> replacements) {
    return formatStringWithMap(this, replacements);
  }
}
