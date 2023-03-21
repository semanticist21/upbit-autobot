import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:upbit_autobot/components/refresh_button.dart';

import '../animation/wave.dart';

class BalanceMonitor extends StatefulWidget {
  const BalanceMonitor({super.key});

  @override
  State<BalanceMonitor> createState() => _BalanceMonitorState();
}

class _BalanceMonitorState extends State<BalanceMonitor> {
  var _balance = '0';

  @override
  void initState() {
    super.initState();
    DoBalanceRequest();
  }

  @override
  Widget build(BuildContext context) {
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
                  RefreshButton(callback: () async {
                    await DoBalanceRequest();
                  })
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
    var result = await RestApiClient().requestGet("balance/krw");

    Map<String, dynamic> parsedResult = RestApiClient.parseResponseData(result);

    var key = 'balance';
    if (parsedResult.containsKey(key)) {
      _balance = parsedResult[key];
      setState(() {});
      return;
    }
  }
}
