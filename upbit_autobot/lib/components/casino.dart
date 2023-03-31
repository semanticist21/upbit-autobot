import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:metaballs/metaballs.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/model/color_info.dart';
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
            color: ColorInfo.generateRandomColor(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: ColorInfo.generateRandomColor(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: ColorInfo.generateRandomColor(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('빈\n아이템',
            color: ColorInfo.generateRandomColor(),
            textStyle: TextStyle(fontSize: 20)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DraggableCard(
            child: FractionallySizedBox(
                widthFactor: 0.6,
                heightFactor: 0.7,
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15)),
                  child: Scaffold(
                      backgroundColor: Color.fromARGB(255, 0, 0, 0),
                      appBar: AppBar(
                          leading: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                              splashRadius: 15),
                          title: Row(children: [
                            Icon(
                              FontAwesomeIcons.fire,
                              color: Colors.red,
                              size: 15,
                            ),
                            SizedBox(width: 10),
                            Text('랜덤 룰렛, 당신의 포지션 행운에 맡기세요 ! (5개 생성)',
                                style: TextStyle(fontSize: 15))
                          ])),
                      body: Metaballs(
                        effect: MetaballsEffect.follow(
                          growthFactor: 2,
                          smoothing: 1,
                          radius: 0.5,
                        ),
                        gradient: LinearGradient(
                            colors: [
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                              ColorInfo.generateRandomColor(),
                            ],
                            begin: Alignment.bottomRight,
                            tileMode: TileMode.mirror,
                            end: Alignment.topLeft),
                        metaballs: 80,
                        animationDuration: const Duration(milliseconds: 200),
                        speedMultiplier: 2,
                        bounceStiffness: 5,
                        minBallRadius: 10,
                        maxBallRadius: 45,
                        glowRadius: 0.8,
                        glowIntensity: 1,
                        child: Column(children: [
                          Expanded(
                              flex: 30,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.transparent,
                                  child: FractionallySizedBox(
                                      child: Row(children: [
                                    Expanded(
                                        flex: 10,
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Roulette(
                                              controller: _controller,
                                              style: RouletteStyle(
                                                  dividerColor:
                                                      Colors.transparent,
                                                  dividerThickness: 1,
                                                  centerStickerColor:
                                                      Colors.grey,
                                                  centerStickSizePercent: 0.08),
                                            ))),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                            color: Colors.black,
                                            child: Column(
                                              children: [],
                                            )))
                                  ])))),
                          Expanded(
                              flex: 6,
                              child: Container(
                                  color: const Color.fromRGBO(
                                      250, 250, 250, 0.95)))
                        ]),
                      )),
                ))));
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
