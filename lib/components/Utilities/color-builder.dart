import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../timetable/structures/Settings.dart' as timetable;
import '../../utils.dart';

typedef Widget ColorSchemeBuilder(
    ColorScheme? lightDynamic, ColorScheme? darkDynamic);

class ColorBuilder extends StatelessWidget {
  final ColorSchemeBuilder builder;

  const ColorBuilder({
    required this.builder,
    super.key,
  });

  bool shouldBeDynamic(BuildContext context) {
    final settings = Provider.of<timetable.Settings>(context);
    final dcEnabled = settings.getUseDynamicColor();
    final dcSupported = true; // FIXME

    return dcEnabled && dcSupported;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<timetable.Settings>(context);

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        final primary = settings.getPrimaryColor(),
            accent = settings.getAccentColor();

        return DynamicColorBuilder(builder: (light, dark) {
          final isValid = light != null && dark != null;

          if (shouldBeDynamic(context) && isValid) {
            return builder(light, dark);
          }

          final lightColorScheme = ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            onPrimary: primary.contrastText,
            secondary: accent,
            onSecondary: accent.contrastText,
            brightness: Brightness.light,
          );
          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            onPrimary: primary.contrastText,
            secondary: accent,
            onSecondary: accent.contrastText,
            brightness: Brightness.dark,
          );
          // final darkColorScheme = ColorScheme.dark(
          //   primary: primary,
          //   onPrimary: primary.contrastText,
          //   secondary: accent,
          //   onSecondary: accent.contrastText,
          // );

          return builder(lightColorScheme, darkColorScheme);
        });
      },
    );
  }
}
