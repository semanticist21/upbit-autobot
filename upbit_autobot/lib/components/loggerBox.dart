import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/provider.dart';

class LoggerBox extends StatefulWidget {
  LoggerBox({super.key});
  final _LoggerBoxState _state = _LoggerBoxState();

  @override
  State<LoggerBox> createState() => _state;
}

class _LoggerBoxState extends State<LoggerBox> {
  late AppProvider _provider;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppProvider>(context, listen: true);
    if (_isInit) {
      _provider.doLoggerRequest(_provider.controller);
      _isInit = false;
    }

    return Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Container(
              height: 30,
              color: Color.fromRGBO(66, 66, 66, 0.9),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(FontAwesomeIcons.clockRotateLeft, size: 15),
                SizedBox(width: 15),
                Text("로그",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal))
              ])),
          Expanded(
              child: SingleChildScrollView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            scrollDirection: Axis.vertical,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  controller: _provider.controller,
                  enabled: true,
                  maxLines: null,
                  readOnly: true,
                  style: TextStyle(fontSize: 12),
                  decoration: InputDecoration(border: InputBorder.none),
                )),
          ))
        ]));
  }
}
