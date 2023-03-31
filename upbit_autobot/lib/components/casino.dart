import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';
import 'package:upbit_autobot/components/alert.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/components/pop_text.dart';
import 'package:upbit_autobot/model/color_info.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';
import 'package:upbit_autobot/provider.dart';

import 'bet_your_money.dart';
import 'fire.dart';

class CasinoDialog extends StatefulWidget {
  @override
  _CasinoDialogState createState() => _CasinoDialogState();
}

class _CasinoDialogState extends State<CasinoDialog>
    with TickerProviderStateMixin {
  late RouletteController _controller = RouletteController(
      group: RouletteGroup([
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: TextStyle(fontSize: 20)),
      ]),
      vsync: this);
  late AppProvider _provider;

  var _firstText = '';
  var _secondText = '';
  var _thirdText = '';
  var _fourthText = '';
  var _fifthText = '';

  var _firstMarketCoinNm = '';
  var _secondMarketCoinNm = '';
  var _thirdMarketCoinNm = '';
  var _fourthMarketCoinNm = '';
  var _fifthMarketCoinNm = '';

  var _isPressed = false;
  var _isRouletteOnGoing = false;

  bool _hasTried = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);
    if (!_hasTried) {
      _initRouletteGroup();
    }

    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DraggableCard(
            child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.9,
          child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15)),
              child: Scaffold(
                backgroundColor: Colors.black,
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
                body: Column(children: [
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
                                child: Stack(children: [
                                  Fire(),
                                  Container(
                                      padding: EdgeInsets.all(10),
                                      child: Roulette(
                                        controller: _controller,
                                        style: RouletteStyle(
                                            dividerColor: Colors.transparent,
                                            dividerThickness: 1,
                                            centerStickerColor: Colors.grey,
                                            centerStickSizePercent: 0.08),
                                      ))
                                ])),
                            Expanded(
                                flex: 7,
                                child: Container(
                                    color: Colors.black,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 3, child: BetYourMoney()),
                                        Divider(),
                                        Expanded(
                                            flex: 12,
                                            child: Column(children: [
                                              Expanded(
                                                  child: Center(
                                                child: _firstText != ''
                                                    ? PopUpText(
                                                        text: _firstText,
                                                        coinNm:
                                                            _firstMarketCoinNm)
                                                    : SizedBox(),
                                              )),
                                              Expanded(
                                                  child: Center(
                                                child: _firstText != ''
                                                    ? PopUpText(
                                                        text: _firstText,
                                                        coinNm:
                                                            _firstMarketCoinNm)
                                                    : SizedBox(),
                                              )),
                                              Expanded(
                                                  child: Center(
                                                child: _secondText != ''
                                                    ? PopUpText(
                                                        text: _secondText,
                                                        coinNm:
                                                            _secondMarketCoinNm)
                                                    : SizedBox(),
                                              )),
                                              Expanded(
                                                  child: Center(
                                                child: _thirdText != ''
                                                    ? PopUpText(
                                                        text: _thirdText,
                                                        coinNm:
                                                            _thirdMarketCoinNm)
                                                    : SizedBox(),
                                              )),
                                              Expanded(
                                                  child: Center(
                                                child: _firstText != ''
                                                    ? PopUpText(
                                                        text: _firstText,
                                                        coinNm:
                                                            _firstMarketCoinNm)
                                                    : SizedBox(),
                                              )),
                                            ])),
                                        Divider(),
                                        Expanded(
                                            flex: 4,
                                            child: Container(
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                  SizedBox(width: 10),
                                                  ElevatedButton(
                                                      onPressed: () =>
                                                          setState(() {
                                                            if (_isRouletteOnGoing) {
                                                              return;
                                                            }
                                                            _isPressed = false;
                                                          }),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              FontAwesomeIcons
                                                                  .gun,
                                                              size: 20),
                                                          SizedBox(
                                                              width: 10,
                                                              height: double
                                                                  .infinity),
                                                          Text('리셋',
                                                              style: TextStyle(
                                                                  fontSize: 20))
                                                        ],
                                                      )),
                                                  GestureDetector(
                                                      onTapDown: (details) {
                                                        setState(() {
                                                          if (_isRouletteOnGoing) {
                                                            return;
                                                          }
                                                          _isRouletteOnGoing =
                                                              true;
                                                          _isPressed = true;

                                                          _doStartRoullet();
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 110,
                                                        height: double.infinity,
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      _isPressed
                                                                          ? 'lib/assets/down.png'
                                                                          : 'lib/assets/up.png'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                        alignment:
                                                            Alignment.center,
                                                      ))
                                                ])))
                                      ],
                                    )))
                          ])))),
                  Expanded(
                      flex: 6,
                      child: Row(children: [
                        Row(children: [
                          Text('소리 끄기'),
                          SizedBox(width: 10),
                          Checkbox(value: true, onChanged: (event) {})
                        ]),
                        Spacer(),
                        ElevatedButton(
                            onPressed: () {}, child: Text('볼린저 밴드로 추가')),
                        ElevatedButton(
                            onPressed: () {}, child: Text('일목 아이템로 추가')),
                      ]))
                ]),
              )),
        )));
  }

  Future<void> _initRouletteGroup() async {
    if (_provider.volumeTopList.isEmpty && !_hasTried) {
      await _provider.doVolumeItemRequest(_provider.volumeTopList);
      _hasTried = true;
    }
  }

  Future<void> _doStartRoullet() async {
    if (_provider.volumeTopList.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(
              text: '볼륨 아이템을 받을 수 없어 실패했습니다. \nAPI 관련 로그를 확인해주세요.'));

      _isRouletteOnGoing = false;
      _isPressed = false;
      setState(() {});

      return;
    }

    _controller.group = RouletteGroup(_getUnitItem());

    var map = Map<String, bool>();
    _provider.itemsCollection.forEach((element) {
      if (element is StrategyBollingerItemInfo) {
        map[element.coinMarKetName] = true;
      }

      if (element is StrategyIchimokuItemInfo) {
        map[element.coinMarKetName] = true;
      }
    });

    await _rollRoll(map, _firstText, _firstMarketCoinNm);
    await Future.delayed(Duration(seconds: 1));
    await _rollRoll(map, _secondText, _secondMarketCoinNm);
    await Future.delayed(Duration(seconds: 1));
    await _rollRoll(map, _thirdText, _thirdMarketCoinNm);
    await Future.delayed(Duration(seconds: 1));
    await _rollRoll(map, _fourthText, _fourthMarketCoinNm);
    await Future.delayed(Duration(seconds: 1));
    await _rollRoll(map, _fifthText, _fifthMarketCoinNm);

    _isRouletteOnGoing = false;
    setState(() {});
  }

  Future<void> _rollRoll(
    Map<String, bool> map,
    String text,
    String marketText,
  ) async {
    var randomValue = Random().nextInt(_provider.volumeTopList.length - 1);
    while (
        map.containsKey(_provider.volumeTopList[randomValue]['marketName'])) {
      randomValue = Random().nextInt(_provider.volumeTopList.length - 1);
    }

    await _controller.rollTo(randomValue);
    text = _provider.volumeTopList[randomValue]['coinKrName'];
    marketText = _provider.volumeTopList[randomValue]['marketName'];
    setState(() {});
  }

  List<RouletteUnit> _getUnitItem() {
    List<RouletteUnit> list = List.empty(growable: true);

    _provider.volumeTopList.forEach((element) {
      List<String> chunks = [];
      var str = element['coinKrName'];

      for (int i = 0; i < str.length; i += 2) {
        if (i + 2 >= str.length) {
          String chunk = str.substring(i, str.length);
          chunks.add(chunk);
          break;
        }

        String chunk = str.substring(i, i + 2);
        chunks.add(chunk);
      }

      String spacedText = chunks.join("\n");

      var unit = RouletteUnit(
          color: ColorInfo.generateRandomColorNoOpacity(),
          weight: 1.0,
          text: spacedText,
          textStyle: TextStyle(fontSize: 10));

      list.add(unit);
    });

    return list;
  }
}
