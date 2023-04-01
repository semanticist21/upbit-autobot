import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbit_autobot/components/alert.dart';
import 'package:upbit_autobot/components/casino_roulette.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/components/pop_text.dart';
import 'package:upbit_autobot/components/triangle.dart';
import 'package:upbit_autobot/model/color_info.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';
import 'package:upbit_autobot/provider.dart';

import '../client/client.dart';
import '../model/template.dart';
import '3d_button.dart';
import 'bet_your_money.dart';
import 'fire.dart';

class CasinoDialog extends StatefulWidget {
  @override
  _CasinoDialogState createState() => _CasinoDialogState();
}

class _CasinoDialogState extends State<CasinoDialog> {
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

  var _isSoundOn = true;

  late SharedPreferences _pref;
  var casionoRoulette = CasionoRoulette();
  var _prefKey = 'soundOn';

  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  var _bgPlayer = AudioPlayer();
  var _leverPlayer = AudioPlayer();
  var _wheelPlayer = AudioPlayer();

  var _bgPath = 'background.wav';
  var _leverPath = 'lever.wav';
  var _wheelPath = 'wheel.wav';

  @override
  void initState() {
    _initPref();
    super.initState();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _leverPlayer.dispose();
    _wheelPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context, listen: true);

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
                  child: ScaffoldMessenger(
                      key: _scaffoldMessengerKey,
                      child: Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                            leading: IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  cleanText();
                                  casionoRoulette.stateWidget.controller
                                      .resetAnimation();
                                  Navigator.of(context).pop();
                                },
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
                                      widthFactor: 1.0,
                                      heightFactor: 1.0,
                                      child: Row(children: [
                                        Expanded(
                                            flex: 10,
                                            child: Stack(children: [
                                              const Fire(),
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: casionoRoulette,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.2,
                                                      0,
                                                      0,
                                                      0),
                                                  child: TriangleDiagram())
                                            ])),
                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                                color: Colors.black,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: BetYourMoney()),
                                                    Expanded(
                                                        flex: 12,
                                                        child:
                                                            Column(children: [
                                                          Expanded(
                                                              child: Center(
                                                            child: _firstText !=
                                                                    ''
                                                                ? PopUpText(
                                                                    text:
                                                                        _firstText,
                                                                    coinNm: _firstMarketCoinNm
                                                                        .replaceAll(
                                                                            'KRW-',
                                                                            '')
                                                                        .toLowerCase())
                                                                : SizedBox(),
                                                          )),
                                                          Expanded(
                                                              child: Center(
                                                            child: _secondText !=
                                                                    ''
                                                                ? PopUpText(
                                                                    text:
                                                                        _secondText,
                                                                    coinNm: _secondMarketCoinNm
                                                                        .replaceAll(
                                                                            'KRW-',
                                                                            '')
                                                                        .toLowerCase())
                                                                : SizedBox(),
                                                          )),
                                                          Expanded(
                                                              child: Center(
                                                            child: _thirdText !=
                                                                    ''
                                                                ? PopUpText(
                                                                    text:
                                                                        _thirdText,
                                                                    coinNm: _thirdMarketCoinNm
                                                                        .replaceAll(
                                                                            'KRW-',
                                                                            '')
                                                                        .toLowerCase())
                                                                : SizedBox(),
                                                          )),
                                                          Expanded(
                                                              child: Center(
                                                            child: _fourthText !=
                                                                    ''
                                                                ? PopUpText(
                                                                    text:
                                                                        _fourthText,
                                                                    coinNm: _fourthMarketCoinNm
                                                                        .replaceAll(
                                                                            'KRW-',
                                                                            '')
                                                                        .toLowerCase())
                                                                : SizedBox(),
                                                          )),
                                                          Expanded(
                                                              child: Center(
                                                            child: _fifthText !=
                                                                    ''
                                                                ? PopUpText(
                                                                    text:
                                                                        _fifthText,
                                                                    coinNm: _fifthMarketCoinNm
                                                                        .replaceAll(
                                                                            'KRW-',
                                                                            '')
                                                                        .toLowerCase())
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
                                                              SizedBox(
                                                                  width: 10),
                                                              Button3D(
                                                                  style:
                                                                      StyleOf3dButton(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.1,
                                                                    height: 90,
                                                                    backColor:
                                                                        Colors.red[
                                                                            900]!,
                                                                    topColor:
                                                                        Colors.red[
                                                                            400]!,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.15,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.08,
                                                                  onPressed:
                                                                      () {
                                                                    if (_isRouletteOnGoing) {
                                                                      return;
                                                                    }
                                                                    cleanText();
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                          FontAwesomeIcons
                                                                              .gun,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              double.infinity),
                                                                      Text('리셋',
                                                                          style:
                                                                              TextStyle(fontSize: 20))
                                                                    ],
                                                                  )),
                                                              GestureDetector(
                                                                  onTapDown:
                                                                      (details) {
                                                                    _doTapDown();
                                                                  },
                                                                  onTapUp:
                                                                      (details) async {
                                                                    await _doTapUp();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.13,
                                                                    height: double
                                                                        .infinity,
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: AssetImage(_isPressed
                                                                                ? 'assets/down.png'
                                                                                : 'assets/up.png'),
                                                                            fit: BoxFit
                                                                                .fill,
                                                                            filterQuality: FilterQuality
                                                                                .high,
                                                                            isAntiAlias:
                                                                                true),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                  ))
                                                            ])))
                                                  ],
                                                )))
                                      ])))),
                          Expanded(
                              flex: 6,
                              child: Row(children: [
                                Row(children: [
                                  SizedBox(width: 10),
                                  Icon(Icons.radio, size: 15),
                                  SizedBox(width: 10),
                                  Text('소리 끄기'),
                                  Checkbox(
                                      value: !_isSoundOn,
                                      onChanged: (event) async {
                                        _isSoundOn = !_isSoundOn;
                                        if (_isSoundOn) {
                                          _bgPlayer.resume();
                                        } else {
                                          _bgPlayer.stop();
                                        }

                                        await _pref.setBool(
                                            _prefKey, _isSoundOn);
                                        print(_pref.getBool(_prefKey));
                                        setState(() {});
                                      })
                                ]),
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () => _doSaveBollinger(),
                                  child: Text('볼린저 밴드로 추가'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                    onPressed: () => _doSaveIchimoku(),
                                    child: Text('일목 아이템로 추가')),
                                SizedBox(width: 10),
                              ]))
                        ]),
                      )),
                ))));
  }

  Future<void> _initPref() async {
    _pref = await SharedPreferences.getInstance();
    _isSoundOn = _pref.getBool(_prefKey) ?? true;
    setState(() {});
    _setPlayers();
    _playBgSong();
  }

  void _setPlayers() {
    var bgSource = AssetSource(_bgPath);
    var leverSource = AssetSource(_leverPath);
    var wheelSoruce = AssetSource(_wheelPath);

    _bgPlayer.setSource(bgSource);
    _leverPlayer.setSource(leverSource);
    _wheelPlayer.setSource(wheelSoruce);

    _bgPlayer.setVolume(0.06);
    _leverPlayer.setVolume(0.2);
    _wheelPlayer.setVolume(0.2);
  }

  void _playBgSong() {
    if (!_isSoundOn) {
      return;
    }

    _bgPlayer.resume();
  }

  void _playLeverEffect() {
    if (!_isSoundOn) {
      return;
    }

    _leverPlayer.resume();
  }

  void _playWheelEffect() {
    if (!_isSoundOn) {
      return;
    }

    _wheelPlayer.resume();
  }

  Future<void> _doTapDown() async {
    if (_isRouletteOnGoing || _firstText != '') {
      return;
    }

    setState(() {
      _isPressed = true;
    });
    _playLeverEffect();
  }

  Future<void> _doTapUp() async {
    if (_firstText != '') {
      _scaffoldMessengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text('아이템을 초기화해야 재실행이 가능합니다.')));
    }
    if (_isRouletteOnGoing || _firstText != '') {
      return;
    }

    _isRouletteOnGoing = true;

    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _isPressed = false;
    });

    await _doStartRoullet();

    _isRouletteOnGoing = false;
  }

  Future<void> _doStartRoullet() async {
    if (_provider.volumeTopList.isEmpty) {
      await _provider.doVolumeItemRequest();
    }

    if (_provider.volumeTopList.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(
              text: '볼륨 아이템을 받을 수 없어 실패했습니다. \nAPI 관련 로그를 확인해주세요.'));

      _isRouletteOnGoing = false;
      return;
    }

    var usedIndexs = List<int>.empty(growable: true);

    _playWheelEffect();
    var index = await casionoRoulette.stateWidget.rollRoll(usedIndexs);
    usedIndexs.add(index);
    if (index < _provider.volumeTopList.length) {
      setState(() {
        _firstText = _provider.volumeTopList.elementAt(index)['coinKrName'];
        _firstMarketCoinNm =
            _provider.volumeTopList.elementAt(index)['marketName'];
      });
    }
    await Future.delayed(Duration(milliseconds: 600));

    _playWheelEffect();
    index = await casionoRoulette.stateWidget.rollRoll(usedIndexs);
    usedIndexs.add(index);

    if (index < _provider.volumeTopList.length) {
      setState(() {
        _secondText = _provider.volumeTopList.elementAt(index)['coinKrName'];
        _secondMarketCoinNm =
            _provider.volumeTopList.elementAt(index)['marketName'];
      });
    }
    await Future.delayed(Duration(milliseconds: 600));

    _playWheelEffect();
    index = await casionoRoulette.stateWidget.rollRoll(usedIndexs);
    usedIndexs.add(index);
    if (index < _provider.volumeTopList.length) {
      setState(() {
        _thirdText = _provider.volumeTopList.elementAt(index)['coinKrName'];
        _thirdMarketCoinNm =
            _provider.volumeTopList.elementAt(index)['marketName'];
      });
    }
    await Future.delayed(Duration(milliseconds: 600));

    _playWheelEffect();
    index = await casionoRoulette.stateWidget.rollRoll(usedIndexs);
    usedIndexs.add(index);
    if (index < _provider.volumeTopList.length) {
      setState(() {
        _fourthText = _provider.volumeTopList.elementAt(index)['coinKrName'];
        _fourthMarketCoinNm =
            _provider.volumeTopList.elementAt(index)['marketName'];
      });
    }
    await Future.delayed(Duration(milliseconds: 600));

    _playWheelEffect();
    index = await casionoRoulette.stateWidget.rollRoll(usedIndexs);
    usedIndexs.add(index);
    if (index < _provider.volumeTopList.length) {
      setState(() {
        _fifthText = _provider.volumeTopList.elementAt(index)['coinKrName'];
        _fifthMarketCoinNm =
            _provider.volumeTopList.elementAt(index)['marketName'];
      });
    }
  }

  Future<void> _doSaveBollinger() async {
    if (_isRouletteOnGoing) {
      return;
    }

    if (_fifthText == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(text: '먼저 룰렛을 돌려주세요.'));
      return;
    }
    var response = await RestApiClient().requestGet('template');
    var data = await RestApiClient.parseResponseData(response);

    if (data.isEmpty) {
      return;
    }

    if (_provider.itemsCollection.length >= 6) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialogCustom(text: '이미 저장된 아이템 개수가 너무 많습니다!'));
      return;
    }

    var template = TemplateModel.fromJson(data);

    if (template.bollingerTemplate == null ||
        template.bollingerTemplate!.coinMarKetName != 'save') {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(text: '저장된 템플릿이 없습니다.'));
      return;
    }

    _provider.bollingerItems
        .add(getBollinger(template.bollingerTemplate!, _firstMarketCoinNm));
    _provider.bollingerItems
        .add(getBollinger(template.bollingerTemplate!, _secondMarketCoinNm));
    _provider.bollingerItems
        .add(getBollinger(template.bollingerTemplate!, _thirdMarketCoinNm));
    _provider.bollingerItems
        .add(getBollinger(template.bollingerTemplate!, _fourthMarketCoinNm));
    _provider.bollingerItems
        .add(getBollinger(template.bollingerTemplate!, _fifthMarketCoinNm));

    cleanText();
    _scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text("저장 완료!")));
  }

  StrategyBollingerItemInfo getBollinger(
      StrategyBollingerItemInfo info, String marketName) {
    var newItem = StrategyBollingerItemInfo.from(
        ColorInfo(color: ColorInfo.generateRandomColor()),
        info.itemId,
        info.coinMarKetName,
        info.bollingerLength,
        info.bollingerMultiplier,
        info.purchaseCount,
        info.profitLinePercent,
        info.lossLinePercent,
        info.lastBoughtTimeStamp,
        info.desiredBuyAmount,
        info.candleBaseMinute);

    newItem.coinMarKetName = marketName;
    return newItem;
  }

  Future<void> _doSaveIchimoku() async {
    if (_isRouletteOnGoing) {
      return;
    }

    if (_fifthText == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(text: '먼저 룰렛을 돌려주세요.'));
      return;
    }
    var response = await RestApiClient().requestGet('template');
    var data = await RestApiClient.parseResponseData(response);

    if (data.isEmpty) {
      return;
    }

    if (_provider.itemsCollection.length >= 6) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialogCustom(text: '이미 저장된 아이템 개수가 너무 많습니다!'));
      return;
    }

    var template = TemplateModel.fromJson(data);

    if (template.ichimokuTemplate == null ||
        template.ichimokuTemplate!.coinMarKetName != 'save') {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(text: '저장된 템플릿이 없습니다.'));
      return;
    }

    _provider.ichimokuItems
        .add(getIchimoku(template.ichimokuTemplate!, _firstMarketCoinNm));
    _provider.ichimokuItems
        .add(getIchimoku(template.ichimokuTemplate!, _secondMarketCoinNm));
    _provider.ichimokuItems
        .add(getIchimoku(template.ichimokuTemplate!, _thirdMarketCoinNm));
    _provider.ichimokuItems
        .add(getIchimoku(template.ichimokuTemplate!, _fourthMarketCoinNm));
    _provider.ichimokuItems
        .add(getIchimoku(template.ichimokuTemplate!, _fifthMarketCoinNm));

    cleanText();
    _scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text("저장 완료!")));
  }

  StrategyIchimokuItemInfo getIchimoku(
      StrategyIchimokuItemInfo info, String marketName) {
    var newItem = StrategyIchimokuItemInfo.from(
        ColorInfo(color: ColorInfo.generateRandomColor()),
        info.itemId,
        info.coinMarKetName,
        info.conversionLine,
        info.purchaseCount,
        info.profitLinePercent,
        info.lossLinePercent,
        info.lastBoughtTimeStamp,
        info.desiredBuyAmount,
        info.candleBaseMinute);

    newItem.coinMarKetName = marketName;
    return newItem;
  }

  void cleanText() {
    _firstText = '';
    _firstMarketCoinNm = '';

    _secondText = '';
    _secondMarketCoinNm = '';

    _thirdText = '';
    _thirdMarketCoinNm = '';

    _fourthText = '';
    _fourthMarketCoinNm = '';

    _fifthText = '';
    _fifthMarketCoinNm = '';
    setState(() {});
  }
}
