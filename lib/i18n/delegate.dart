import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};
  Map _raw = {};

  Map<String, String> flattenTranslations(Map<String, dynamic> json,
      [String prefix = '']) {
    final Map<String, String> translations = {};
    json.forEach((String key, dynamic value) {
      if (value is Map) {
        translations.addAll(
            flattenTranslations(value as Map<String, dynamic>, '$prefix$key.'));
      } else {
        translations['$prefix$key'] = value.toString();
      }
    });
    return translations;
  }

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('assets/locales/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _raw = jsonMap;
    _localizedStrings = flattenTranslations(jsonMap);
    return true;
  }

  T? get<T>(String key) {
    if (_raw[key] == null) {
      debugPrint('[I18N] Warning: key "$key" is undefined.');
    }

    return _raw[key];
  }

  T placeholderize<T extends String?>(
      T value, Map<String, String> replacements) {
    if (value == null) return null as T;
    return value.replaceAllMapped(
        RegExp(r'(?<!(?<!\\)\\){([^}]+)(?<!(?<!\\)\\)}'), (match) {
      final matchKey = match.group(1);
      if (matchKey == null || replacements[matchKey] == null) {
        // debugPrint(
        //     "[I18N] Key '$key': var '$matchKey' not found. Returning key.");
        return '{$matchKey}';
      }

      return replacements[matchKey]!;
    }) as T;
  }

  String translate(String key, [Map<String, String>? replacements]) {
    if (_localizedStrings[key] == null) {
      debugPrint('[I18N] Warning: key "$key" is undefined.');
    }

    var value = _localizedStrings[key] ?? key;

    if (replacements != null) {
      value = placeholderize(value, replacements);
    }

    return value;
  }

  String plural(
    String key,
    num howMany, {
    int? precision,
  }) {
    if (_raw[key] == null) {
      debugPrint('[I18N] Warning: key "$key" is undefined.');
      return key;
    }

    if (_raw[key]['other'] == null) {
      debugPrint(
          '[I18N] Warning: key "$key.other" is undefined in pluralization.');
      return key;
    }

    String localizedNumber =
        NumberFormat.decimalPattern(locale.toLanguageTag()).format(howMany);
    return Intl.plural(
      howMany,
      zero: placeholderize(_raw[key]['zero'], {'0': localizedNumber}),
      one: placeholderize(_raw[key]['one'], {'0': localizedNumber}),
      two: placeholderize(_raw[key]['two'], {'0': localizedNumber}),
      few: placeholderize(_raw[key]['few'], {'0': localizedNumber}),
      many: placeholderize(_raw[key]['many'], {'0': localizedNumber}),
      other: placeholderize(_raw[key]['other'], {'0': localizedNumber}),
      locale: locale.toLanguageTag(),
    );
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'it'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
