import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:upbit_autobot/client/client.dart';

import '../animation/wave.dart';

class BalanceMonitor extends StatefulWidget {
  const BalanceMonitor({super.key});

  @override
  State<BalanceMonitor> createState() => _BalanceMonitorState();
}

class _BalanceMonitorState extends State<BalanceMonitor> {
  var _balance = '0';
  var _isInitial = true;

  @override
  Widget build(BuildContext context) {
    if (_isInitial) {
      DoBalanceRequest();
      _isInitial = false;
    }

    return Stack(children: [
      const Opacity(opacity: 0.4, child: Wave()),
      Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    SizedBox(width: 10),
                    Icon(
                      FontAwesomeIcons.wonSign,
                      size: 15,
                    ),
                    SizedBox(width: 8),
                    Text("업비트 나의 현금 잔고")
                  ]),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.arrowRotateLeft),
                    padding: EdgeInsets.zero,
                    iconSize: 15,
                    splashRadius: 15.0,
                  )
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            _balance,
                            style: TextStyle(fontSize: 25),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'KRW',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ))),
            ],
          ))
    ]);
  }

  Future<void> DoBalanceRequest() async {
    var result = await RestApiClient().requestGet("balance");

    Map<String, dynamic> parsedResult = parseResponseData(result);

    if (parsedResult.containsKey('balance')) {
      _balance = parsedResult['balance'];
      setState(() {});
      return;
    }
  }
}
