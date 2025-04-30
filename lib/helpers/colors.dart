import 'package:flutter/material.dart';

class ColorHelper {
  static Color getShade(Color color, {required Color alternateColor}) {
    return color;
  }

  static Color keepOrWhite(Color textColor, Color backgroundColor,
      {Color? alternateColor}) {
    return textColor;
  }

  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}
