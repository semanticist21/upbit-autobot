import 'dart:math';

import 'package:flutter/material.dart';

class ColorInfo {
  final Color color;
  late final String hexCode;

  ColorInfo({required this.color}) {
    hexCode = colorToHex(color);
  }

  factory ColorInfo.fromHex(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    var color = Color(int.parse(hex, radix: 16));
    return ColorInfo(color: color);
  }

  static Color generateRandomColor() =>
      Color((Random().nextDouble() * 0.3 * 0xffffff).toInt()).withOpacity(0.8);

  static Color generateRandomColorNoOpacity() =>
      Color((Random().nextDouble() * 0.5 * 0xffffff).toInt()).withOpacity(0.95);

  static String colorToHex(Color color) =>
      '#${color.alpha.toRadixString(16).padLeft(2, '0')}${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}
