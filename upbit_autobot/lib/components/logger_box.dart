
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/provider.dart';

class LoggerBox extends StatefulWidget {
  const LoggerBox({super.key});

  @override
  State<LoggerBox> createState() => _LoggerBoxState();
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
      _provider.startLoggerGetByWebSocket();
      _isInit = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _provider.scrollController.animateTo(
          _provider.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut);
    });

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
              color: const Color.fromRGBO(66, 66, 66, 0.9),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Spacer(),
                const SizedBox(width: 50),
                const Icon(FontAwesomeIcons.clockRotateLeft, size: 15),
                const SizedBox(width: 10),
                const Text("로그",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      _provider.loggerText = '';
                      setState(() {});
                    },
                    icon: const Icon(FontAwesomeIcons.trash, size: 13)),
                const SizedBox(width: 5)
              ])),
          Expanded(
              child: SingleChildScrollView(
            controller: _provider.scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            scrollDirection: Axis.vertical,
            child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SelectableText(
                  _provider.loggerText,
                  // enabled: true,
                  textAlign: TextAlign.left,
                  maxLines: null,
                  // readOnly: true,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Arial'),
                  // decoration: InputDecoration(border: InputBorder.none),
                )),
          ))
        ]));
  }
}
