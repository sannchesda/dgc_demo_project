import 'package:flutter/material.dart';

class AppColors {
  /// Main Colors
  static Color get primary => navyBlue;

  static MaterialColor get primaryMaterialColor =>
      generateMaterialColor(primary);

  static Color get secondary => yellow;

  static Color get tertiary => blue;

  static Color get accentColor => yellow;

  static Color get backgroundColor => lightYellow;

  /// Widget Colors
  static Color get icon => navyBlue;
  static Color get iconDark => blue;

  static Color get iconSecondary => hexToColor("#8FBFFA");

  static Color get disableBorder => Colors.white.withValues(alpha: 0.5);

  /// Color Palette
  static Color navyBlue = hexToColor("#0C356A");
  static Color blue = hexToColor("#0174BE");
  static Color yellow = hexToColor("#FFC436");
  static Color lightYellow = hexToColor("#FFF0CE");
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

MaterialColor generateMaterialColor(Color color) {
  final int red = (color.r * 255).round();
  final int green = (color.g * 255).round();
  final int blue = (color.b * 255).round();

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, 0.1),
    100: Color.fromRGBO(red, green, blue, 0.2),
    200: Color.fromRGBO(red, green, blue, 0.3),
    300: Color.fromRGBO(red, green, blue, 0.4),
    400: Color.fromRGBO(red, green, blue, 0.5),
    500: Color.fromRGBO(red, green, blue, 0.6),
    600: Color.fromRGBO(red, green, blue, 0.7),
    700: Color.fromRGBO(red, green, blue, 0.8),
    800: Color.fromRGBO(red, green, blue, 0.9),
    900: Color.fromRGBO(red, green, blue, 1.0),
  };

  return MaterialColor(color.toARGB32(), shades);
}