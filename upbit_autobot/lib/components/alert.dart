import 'package:flutter/material.dart';

class AlertDialog extends StatelessWidget {
  const AlertDialog({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(text: text);
  }
}
