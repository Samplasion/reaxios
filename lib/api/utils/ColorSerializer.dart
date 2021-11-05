import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class ColorSerializer implements JsonConverter<Color, String> {
  const ColorSerializer();

  @override
  Color fromJson(String color) => Color(int.parse(color
      .replaceAll(
        RegExp(r'(MaterialColor|ColorSwatch|Color)\((primary value: )?'),
        "0x",
      )
      .replaceAll("#", "0x")
      .replaceAll(RegExp(r'(0x)+'), "0x")));

  @override
  String toJson(Color b) => b
      .toString()
      // .replaceAll("MaterialColor(primary value: ", "#")
      // .replaceAll("ColorSwatch(primary value: ", "#")
      // .replaceAll("Color(", "#")
      .replaceAll(
        RegExp(r'(MaterialColor|ColorSwatch|Color)\((primary value: )?'),
        "#",
      )
      .replaceAll(")", "")
      .replaceAll("0x", "#");
}
