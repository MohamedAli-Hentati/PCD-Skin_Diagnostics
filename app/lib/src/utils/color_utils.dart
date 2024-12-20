import 'package:flutter/material.dart';

Color darken(Color color, {double percentage = 0.05}) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - percentage).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color lighten(Color color, {double percentage = 0.05}) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness + percentage).clamp(0.0, 1.0));
  return hslDark.toColor();
}