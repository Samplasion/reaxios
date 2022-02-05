import 'package:flutter/widgets.dart';

String formatString(String base, List<dynamic> replacements) {
  final Map<String, dynamic> replacementMap = {};
  for (int i = 0; i < replacements.length; i++) {
    replacementMap['$i'] = replacements[i];
  }
  return formatStringWithMap(base, replacementMap);
}

String formatStringWithMap(String base, Map<String, dynamic> replacements) {
  return base.replaceAllMapped(RegExp(r'\{([^}]*)\}'), (Match match) {
    String key = match.group(1)!;
    if (replacements.containsKey(key)) {
      return "${replacements[key]}";
    }
    print("Found string without replacement\n"
        "String: $base\n"
        "Match: $key\n"
        "Map: $replacements");
    return '{$key}';
  });
}

List<InlineSpan> formatStringToSpans(
    String base, List<InlineSpan> replacements) {
  final Map<String, InlineSpan> replacementMap = {};
  for (int i = 0; i < replacements.length; i++) {
    replacementMap['$i'] = replacements[i];
  }
  return formatStringToSpansWithMap(base, replacementMap);
}

List<InlineSpan> formatStringToSpansWithMap(
    String base, Map<String, InlineSpan> replacements) {
  return base.split(RegExp(r'[{}]')).map((e) {
    if (replacements.containsKey(e)) {
      return replacements[e]!;
    } else if (e.isNotEmpty) {
      return TextSpan(text: e);
    } else {
      return TextSpan(text: "");
    }
  }).toList();
}

extension FormatStringExtension on String {
  String format(List<dynamic> replacements) {
    return formatString(this, replacements);
  }

  String mapFormat(Map<String, dynamic> replacements) {
    return formatStringWithMap(this, replacements);
  }

  List<InlineSpan> formatToSpans(List<InlineSpan> replacements) {
    return formatStringToSpans(this, replacements);
  }

  List<InlineSpan> mapFormatToSpans(Map<String, InlineSpan> replacements) {
    return formatStringToSpansWithMap(this, replacements);
  }
}
