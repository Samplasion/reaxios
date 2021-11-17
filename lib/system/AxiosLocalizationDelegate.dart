import 'package:flutter/material.dart';
import 'package:reaxios/generated/locale_base.dart';

class AxiosLocalizationDelegate extends LocalizationsDelegate<LocaleBase> {
  const AxiosLocalizationDelegate();
  final idMap = const {
    'en': 'locales/EN_US.json',
    'it': 'locales/IT.json',
  };

  @override
  bool isSupported(Locale locale) =>
      idMap.keys.map((e) => e.split("-").first).contains(locale.languageCode);

  @override
  Future<LocaleBase> load(Locale locale) async {
    var lang = 'en';
    if (isSupported(locale)) lang = locale.languageCode;
    final loc = LocaleBase();
    await loc.load(idMap[lang]!);
    return loc;
  }

  @override
  bool shouldReload(old) => false;

  static LocaleBase? of(context) => Localizations.of<LocaleBase>(context, LocaleBase);
}
