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
        title: Row(children: [
          Icon(Icons.bubble_chart, size: 20),
          SizedBox(width: 10),
          Text('알림')
        ]),
        content: Container(
            width: 350,
            height: 150,
            child: Column(children: [
              Container(
                height: 120,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  child: Text(text),
                ),
              ),
              Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('확인', style: TextStyle(fontSize: 17)),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                )
              ])
            ])));
  }
}
