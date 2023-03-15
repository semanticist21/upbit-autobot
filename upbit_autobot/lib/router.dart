import 'package:flutter/material.dart';

Route<dynamic> generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case 'home':
      return MaterialPageRoute(builder: (_) => Container());

    default:
      return MaterialPageRoute(builder: (_) => Container());
  }
}
