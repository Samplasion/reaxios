import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class ColorConverter extends JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.value;
  }
}
