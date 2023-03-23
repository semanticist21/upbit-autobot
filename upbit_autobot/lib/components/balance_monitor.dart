import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/components/converter.dart';
import 'package:upbit_autobot/components/refresh_button.dart';
import 'package:upbit_autobot/provider.dart';

import '../animation/wave.dart';

class BalanceMonitor extends StatefulWidget {
  const BalanceMonitor({super.key});

  @override
  State<BalanceMonitor> createState() => _BalanceMonitorState();
}

class _BalanceMonitorState extends State<BalanceMonitor> {
  late AppProvider _provider;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context, listen: true);

    if (_isInit) {
      doBalanceRequest(_provider);
      _isInit = false;
    }

    return Stack(children: [
      const Opacity(opacity: 0.4, child: Wave()),
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    SizedBox(width: 10),
                    Icon(
                      FontAwesomeIcons.wonSign,
                      size: 15,
                    ),
                    SizedBox(width: 8),
                    Text("업비트 나의 현금 잔고")
                  ]),
                  const Spacer(),
                  RefreshButton(callback: () async {
                    await doBalanceRequest(_provider);
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
                          const SizedBox(width: 10),
                          Text(
                            Converter.currencyFormat(
                                double.parse(_provider.krwBalance).toInt()),
                            style: const TextStyle(fontSize: 25),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'KRW',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ))),
            ],
          ))
    ]);
  }

  Future<void> doBalanceRequest(AppProvider provider) async {
    await _provider.doKrwBalanceRequest();
  }
}
