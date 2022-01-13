import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/utils.dart' as axios_utils;
import 'package:reaxios/generated/locale_base.dart';

// Matches before a capital letter that is not also at beginning of string.
import 'dart:math';

import 'package:reaxios/system/AxiosLocalizationDelegate.dart';

import 'enums/GradeDisplay.dart';
import 'system/Store.dart';

extension StringUtils on String {
  repeat(int times) {
    return List.generate(times, (_) => this).join();
  }

  toTitleCase() {
    final _titleCaseify = (String word) {
      return word.substring(0, 1).toUpperCase() +
          word.substring(1).toLowerCase();
    };
    return this
        .toLowerCase()
        .split(Utils.beforeNonLeadingCapitalLetter)
        .map(_titleCaseify)
        .join(' ');
  }
}

final _min = min;
final _max = max;

extension NumListUtilities<T extends num> on List<T> {
  T? get min => (this.isEmpty ? null : this.reduce((a, b) => _min(a, b)));
  T? get max => (this.isEmpty ? null : this.reduce((a, b) => _max(a, b)));
}

class Utils {
  static final beforeNonLeadingCapitalLetter = RegExp(r"(?=(?!^)[A-Z])");

  static isSmall(context) => MediaQuery.of(context).size.width < 320.0;

  /// Splits a PascalCase string into its words.
  ///
  /// ```dart
  /// splitPascalCase("MyAwesome String") // => "My Awesome String"
  /// ```
  /// [Source](https://stackoverflow.com/a/53719052)
  static List<String> splitPascalCase(String input) =>
      input.split(beforeNonLeadingCapitalLetter);

  static String generateAbbreviation(
    int length,
    String input, {
    List<String> ignoreList = const [
      "e",
      "dell",
      "del",
      "di",
      "delle",
      "della",
      // Inglese, italiano
      "lingua",
      "letteratura",
      "cultura",
      // Arte
      "disegno",
      "storia"
    ],
  }) {
    if (input.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "").length <=
        length) {
      var base = input.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
      for (int i = base.length; i < length; i++) base += "X";
      return base;
    }

    var words = splitPascalCase(input)
        .join(" ")
        .split(RegExp("[\\s'\"]"))
        .where((element) => !ignoreList.contains(element.toLowerCase()))
        .where((element) => element.trim().isNotEmpty)
        .toList();

    var out = "";
    if (words.length >= length) {
      for (var word in words) {
        if (out.length < length) {
          out += word[0];
        }
      }
    } else {
      if (input
          .toLowerCase()
          .split(" ")
          .every((element) => ignoreList.contains(element))) {
        return generateAbbreviation(length, input, ignoreList: []);
      }
      var coefficient = (length / max(words.length, 1)).round();
      for (var word in words) {
        for (var i = 0; i < coefficient && out.length < length; i++) {
          out += word[i];
        }
      }
    }

    return out.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static const List<MaterialColor> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];

  static MaterialColor getRandomColor() => colors[_rnd.nextInt(colors.length)];
  static MaterialColor getColorFromString(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    var index = hash % colors.length;
    return colors[index];
  }

  static const int darkShade = 700;
  static const int lightShade = 300;
  static int getShade(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? darkShade : lightShade;
  }

  static int getContrastShade(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? lightShade : darkShade;
  }

  static IconData getBestIconForSubject(String subject, IconData defaultIcon) {
    final sub = subject.toLowerCase();
    if (sub.contains("scienze della vita")) {
      return Icons.nature_people;
    } else if (sub.contains("scienze dell'uomo")) {
      return Icons.person;
    } else if (sub.contains("scienze della comunicazione")) {
      return Icons.chat;
    } else if (sub.contains("scienze della tecnologia")) {
      return Icons.computer;
    } else if (sub.contains("scienze della medicina")) {
      return Icons.local_hospital;
    } else if (sub.contains("scienze dell'ingegneria")) {
      return Icons.build;
    } else if (sub.contains("scienze dell'economia")) {
      return Icons.attach_money;
    } else if (sub.contains("scienze dell'architettura")) {
      return Icons.home;
    } else if (sub.contains("scienze naturali")) {
      return Icons.nature_people;
    } else if (sub.contains("italian")) {
      return Icons.book;
    } else if (sub.contains("lingue") ||
        sub.contains("lingua") ||
        sub.contains("cultura") ||
        sub.contains("letteratura")) {
      return Icons.language;
    } else if (sub.contains("ginnastica") ||
        sub.contains("sport") ||
        sub.contains("motoria") ||
        sub.contains("motorie")) {
      return Icons.directions_bike;
    } else if (sub.contains("scienze") ||
        sub.contains("scienza") ||
        sub.contains("chimica")) {
      return Icons.science;
    } else if (sub.contains("arte") || sub.contains("disegno")) {
      return Icons.art_track;
    } else if (sub.contains("informatica") || sub.contains("tecnologia")) {
      return Icons.computer;
    } else if (sub.contains("sistemi") || sub.contains("reti")) {
      return Icons.settings_ethernet;
    } else if (sub.contains("matematica")) {
      return Icons.calculate;
    } else if (sub.contains("musica")) {
      return Icons.music_note;
    } else if (sub.contains("fisica")) {
      return Icons.grain;
    } else if (sub.contains("arte")) {
      return Icons.computer;
    } else if (sub.contains("inglese")) {
      return Icons.language;
    } else if (sub.contains("storia")) {
      return Icons.history;
    } else if (sub.contains("geografia")) {
      return Icons.map;
    } else if (sub.contains("musica")) {
      return Icons.music_note;
    } else if (sub.contains("religione")) {
      return Icons.health_and_safety;
    } else if (sub.contains("filosofia")) {
      return Icons.school;
    } else if (sub.contains("civica")) {
      return Icons.holiday_village;
    } else
      return defaultIcon;
  }
}

extension ColorUtils on Color {
  Color get contrastText => axios_utils.getContrastText(this);

  Color darken([double amount = .1]) {
    amount = amount.clamp(0.0, 1.0);
    // assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    amount = amount.clamp(0.0, 1.0);
    // assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

extension PrettyGrade on Grade {
  String getPrettyGrade(BuildContext context) {
    if (this.grade == 0 || axios_utils.isNaN(this.grade))
      return "${this.prettyGrade}";
    return context.gradeToString(this.grade);
  }
}

extension ContextUtils on BuildContext {
  LocaleBase get locale => AxiosLocalizationDelegate.of(this)!;
  MaterialLocalizations get materialLocale => MaterialLocalizations.of(this);
  Locale get currentLocale => Localizations.localeOf(this);

  void showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  String gradeToString(
    dynamic grade, {
    bool round = true,
    bool showAsNumber = false,
  }) {
    final store = Provider.of<RegistroStore>(this, listen: false);
    switch (store.gradeDisplay) {
      case GradeDisplay.letter:
        // FIXME: this sucks big time
        // Edit: It sucks less, but still...
        if (!showAsNumber) return axios_utils.gradeToLetter(grade);

        // Boi this is ugly af
        continue decimal;
      decimal:
      case GradeDisplay.decimal:
        if (round) {
          return axios_utils.gradeToString(grade);
        } else if (grade is num) {
          return axios_utils.formatNumber(grade);
        } else
          return "$grade";
      case GradeDisplay.percentage:
        return "${(grade * 10).floor()}%";
      default:
        return "N/A";
    }
  }

  String dateToString(
    DateTime date, {
    bool short = false,
    includeTime = false,
    includeSeconds = false,
    includeMonth = false, // noop
    includeYear = false, // noop
  }) {
    String res;
    if (short) {
      res = DateFormat.yMd(this.currentLocale.toLanguageTag()).format(date);
    } else {
      res = DateFormat.yMMMMd(this.currentLocale.toLanguageTag()).format(date);
    }

    if (includeTime) {
      String time;
      if (includeSeconds) {
        time = DateFormat.Hms(this.currentLocale.toLanguageTag()).format(date);
      } else {
        time = DateFormat.Hm(this.currentLocale.toLanguageTag()).format(date);
      }
      res += " " + time;
    }

    return res;
  }
}

extension DateUtils on DateTime {
  bool operator <(DateTime other) =>
      this.millisecondsSinceEpoch < other.millisecondsSinceEpoch;
  bool operator >(DateTime other) =>
      this.millisecondsSinceEpoch > other.millisecondsSinceEpoch;
  bool operator <=(DateTime other) =>
      this.millisecondsSinceEpoch <= other.millisecondsSinceEpoch;
  bool operator >=(DateTime other) =>
      this.millisecondsSinceEpoch >= other.millisecondsSinceEpoch;

  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

T nullOrElse<T>(T value, T orElse) => value ?? orElse;
T ifNull<T>(T? value, T nonNull, T orElse) => value == null ? orElse : nonNull;

num map(num value, num min, num max, num min2, num max2) {
  return min2 + (max2 - min2) * ((value - min) / (max - min));
}

List<Color> getGradient(Color color, {double strength = 1}) {
  return [
    color.darken(0.1 * strength),
    color.lighten(0.06 * strength),
  ];
}
