import 'package:flutter/material.dart';

class AlertDialogCustom extends StatelessWidget {
  const AlertDialogCustom({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Row(children: [
          Icon(Icons.bubble_chart, size: 20),
          SizedBox(width: 10),
          Text('알림')
        ]),
        content: SizedBox(
            width: 350,
            height: 150,
            child: Column(children: [
              SizedBox(
                height: 120,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  child: Text(text),
                ),
              ),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: const Text('확인', style: TextStyle(fontSize: 17)),
                )
              ])
            ])));
  }
}
