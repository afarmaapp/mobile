import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // this basically makes it so you can instantiate this class

  static const _primaryValue = 0xffD93C43;
  static const _whiteValue = 0xffffffff;
  static const _blackValue = 0xff000000;
  static const _greyValue = 0xff909090;
  static const _secondaryValue = 0xff00aacb;
  static const _selectedValue = 0xff00A9D3;
  static const _backgroundValue = 0xffefefef;

  static MaterialColor createMaterialColor(int colorInt) {
    Color color = Color(colorInt);
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static MaterialColor primary = createMaterialColor(_primaryValue);

  static MaterialColor white = createMaterialColor(_whiteValue);

  static MaterialColor black = createMaterialColor(_blackValue);

  static MaterialColor grey = createMaterialColor(_greyValue);

  static MaterialColor secondary = createMaterialColor(_secondaryValue);

  static MaterialColor selected = createMaterialColor(_selectedValue);

  static MaterialColor background = createMaterialColor(_backgroundValue);
}
