import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/utils/utils.dart' as axios_utils;
import 'package:reaxios/generated/locale_base.dart';

// Matches before a capital letter that is not also at beginning of string.
import 'dart:math';

import 'package:reaxios/system/AxiosLocalizationDelegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxios/timetable/structures/Settings.dart';

import 'components/ListItems/RegistroAboutListItem.dart';
import 'components/LowLevel/MaybeMasterDetail.dart';
import 'components/LowLevel/m3_drawer.dart';
import 'cubit/app_cubit.dart';
import 'enums/AverageMode.dart';
import 'enums/GradeDisplay.dart';
import 'format.dart';

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

extension WidgetUtils on Widget {
  Route get route => MaterialPageRoute(builder: (_) => this);
}

final _min = min;
final _max = max;

extension NumListUtilities<T extends num> on List<T> {
  T? get min => (this.isEmpty ? null : this.reduce((a, b) => _min(a, b)));
  T? get max => (this.isEmpty ? null : this.reduce((a, b) => _max(a, b)));
}

extension StringExtensions on String {
  String get sentenceCase =>
      this[0].toUpperCase() + this.substring(1).toLowerCase();
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
    if (sub.contains("vita") || sub.contains("natur")) {
      return Icons.nature_people;
    } else if (sub.contains("uomo")) {
      return Icons.person;
    } else if (sub.contains("comunicazione")) {
      return Icons.chat;
    } else if (sub.contains("tecnologia")) {
      return Icons.computer;
    } else if (sub.contains("medicina")) {
      return Icons.local_hospital;
    } else if (sub.contains("ingegneria")) {
      return Icons.build;
    } else if (sub.contains("economia")) {
      return Icons.attach_money;
    } else if (sub.contains("architettura")) {
      return Icons.home;
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
    } else if (sub.contains("inglese")) {
      return Icons.language;
    } else if (sub.contains("storia")) {
      return Icons.access_time;
    } else if (sub.contains("geografia")) {
      return Icons.map;
    } else if (sub.contains("religione")) {
      return Icons.health_and_safety;
    } else if (sub.contains("filosofia")) {
      return Icons.school;
    } else if (sub.contains("civica")) {
      return Icons.public;
    } else
      return defaultIcon;
  }
}

double gradeAverage(AverageMode mode, List<Grade> grades) {
  if (grades.isEmpty) return 0.0;
  if (mode == AverageMode.averageOfAverages) {
    final subjects = grades.map((grade) => grade.subject).toSet();
    if (subjects.isEmpty) return 0;
    double sum = 0.0;
    for (var subject in subjects) {
      sum += gradeAverage(
        AverageMode.allGradesAverage,
        grades.where((grade) => grade.subject == subject).toList(),
      );
    }
    return double.parse((sum / subjects.length).toStringAsFixed(2));
  }

  double sum = 0, weights = 0;

  grades.where((grade) => grade.weight != 0).forEach((g) {
    sum += g.grade * g.weight;
    weights += g.weight;
  });

  return double.parse((sum / weights).toStringAsFixed(2));
}

int calculateAge(DateTime birthDate) {
  var now = DateTime.now();
  var age = now.year - birthDate.year;
  var month = now.month - birthDate.month;
  if (month < 0 || (month == 0 && now.day < birthDate.day)) {
    age--;
  }
  return age;
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

  void showSnackbarError(
    String message, {
    SnackBarAction? action,
  }) {
    showSnackbar(
      message,
      backgroundColor: Theme.of(this).colorScheme.error,
      style: TextStyle(color: Theme.of(this).colorScheme.onError),
      action: () {
        if (action != null) {
          return SnackBarAction(
            label: action.label,
            onPressed: action.onPressed,
            textColor: Theme.of(this).colorScheme.onError,
            disabledTextColor:
                action.disabledTextColor ?? Theme.of(this).disabledColor,
            key: action.key,
          );
        }
      }(),
    );
  }

  void showSnackbar(
    String message, {
    TextStyle? style,
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: style),
        backgroundColor: backgroundColor,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void hideCurrentSnackBar() {
    try {
      ScaffoldMessenger.maybeOf(this)?.clearSnackBars();
    } catch (e) {}
  }

  String gradeToString(
    dynamic grade, {
    bool round = true,
    bool showAsNumber = false,
  }) {
    final settings = read<Settings>();
    final gradeDisplay = settings.getGradeDisplay();
    switch (gradeDisplay) {
      case GradeDisplay.letter:
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
      case GradeDisplay.precise:
        return axios_utils.formatNumber(grade);
      default:
        return "N/A";
    }
  }

  String dateToString(
    DateTime date, {
    bool short = false,
    includeTime = false,
    includeSeconds = false,
    includeDayOfWeek = false,
    @deprecated includeMonth = false, // noop
    @deprecated includeYear = false, // noop
  }) {
    String res;
    if (short) {
      if (includeDayOfWeek) {
        res = DateFormat.yMEd(this.currentLocale.toLanguageTag()).format(date);
      } else {
        res = DateFormat.yMd(this.currentLocale.toLanguageTag()).format(date);
      }
    } else {
      if (includeDayOfWeek) {
        res = DateFormat.yMMMMEEEEd(this.currentLocale.toLanguageTag())
            .format(date);
      } else {
        res =
            DateFormat.yMMMMd(this.currentLocale.toLanguageTag()).format(date);
      }
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

  Future<void> defaultLinkHandler(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      showSnackbarError(locale.main.failedLinkOpen);
    }
  }

  Color harmonize({required Color color}) {
    if (!this.read<Settings>().getHarmonizeColors()) return color;
    return color.harmonizeWith(Theme.of(this).colorScheme.primary);
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

List<Color> getGradient(
  BuildContext context,
  Color color, {
  double strength = 1,
}) {
  if (!context.read<Settings>().getUseGradients()) return [color, color];
  return [
    color.darken(0.1 * strength),
    color.lighten(0.06 * strength),
  ];
}

extension StringExtension on String {
  String or(String alternative) {
    if (trim().isEmpty) return alternative;
    return this;
  }
}

_showExitDialog(BuildContext context) {
  final alert = AlertDialog(
    icon: Icon(Icons.exit_to_app),
    title: Text(context.locale.main.logoutTitle),
    content: Text(
      context.locale.main.logoutBody,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
    actions: [
      TextButton(
        child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel.sentenceCase),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
        onPressed: () async {
          // Refresh store
          context.read<AppCubit>().logout();

          final prefs = await SharedPreferences.getInstance();

          prefs.remove("school");
          prefs.remove("user");
          prefs.remove("pass");

          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "login");
        },
      ),
    ],
  );

  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

List<Widget> showEndOfDrawerItems(BuildContext context) {
  return [
    Divider(
      height: 33,
      indent: 28,
      endIndent: 28,
    ),
    M3DrawerListTile(
      title: Text(context.locale.drawer.settings),
      leading: Icon(Icons.settings),
      onTap: () {
        if (!MaybeMasterDetail.shouldBeShowingMaster(context))
          Navigator.pop(context);
        Navigator.pushNamed(context, "settings");
      },
    ),
    RegistroAboutListItem(),
    M3DrawerListTile(
      title: Text(context.locale.drawer.logOut),
      leading: Icon(Icons.exit_to_app),
      onTap: () {
        _showExitDialog(context);
      },
    ),
    SizedBox(height: 16),
  ];
}
