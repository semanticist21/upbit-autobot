import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';
import 'package:upbit_autobot/provider.dart';

class CasinoDialog extends StatefulWidget {
  @override
  _CasinoDialogState createState() => _CasinoDialogState();
}

class _CasinoDialogState extends State<CasinoDialog>
    with SingleTickerProviderStateMixin {
  late RouletteController _controller = RouletteController(
      group: RouletteGroup([
        RouletteUnit.text('빈\n아이템',
            color: Colors.red, textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: Colors.green, textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: Colors.amber, textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: Colors.purple, textStyle: TextStyle(fontSize: 20)),
      ]),
      vsync: this);
  late AppProvider _provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);
    _initRouletteGroup();

    return Dialog(
        child: FractionallySizedBox(
      widthFactor: 0.6,
      heightFactor: 0.7,
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            SizedBox(
                width: 300,
                height: 300,
                child: Roulette(controller: _controller))
          ],
        )),
      ),
    ));
  }

  Future<void> _initRouletteGroup() async {
    // if (_provider.volumeTopList.isEmpty) {
    //   await _provider.doVolumeItemRequest(_provider.volumeTopList);
    // }

    // if (_provider.volumeTopList.isEmpty) {
    //   return;
    // }
  }
}
