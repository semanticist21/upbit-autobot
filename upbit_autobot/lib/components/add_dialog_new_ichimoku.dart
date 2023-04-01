import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';
import 'package:upbit_autobot/model/template.dart';
import 'package:upbit_autobot/provider.dart';

import 'alert.dart';

class AddDialogNewIchimoku extends StatefulWidget {
  const AddDialogNewIchimoku({super.key});

  @override
  State<AddDialogNewIchimoku> createState() => _AddDialogNewIchimokuState();
}

class _AddDialogNewIchimokuState extends State<AddDialogNewIchimoku>
    with SingleTickerProviderStateMixin {
  final _coinMarketName = TextEditingController();
  final _conversionLineLength = TextEditingController(text: '20');
  final _purchaseCount = TextEditingController(text: '3');
  final _profitLine = TextEditingController(text: '5');
  final _lossLine = TextEditingController(text: '5');
  final _desiredBuyAmount = TextEditingController(text: '50000');
  final _minuteCandle = TextEditingController(text: '15');

  final _optionFormKey = GlobalKey<FormState>();
  final _withSuffixFormKey = GlobalKey<FormState>();

  late AppProvider _provider;
  final List<String> candles = ['1', '3', '5', '15', '30', '60', '240'];

  var _coinAmountEstimated = '';

  var _isCtrlKeyPressed = false;
  var _focusNode = FocusNode();
  var _zoomController = TransformationController();
  var _isTemplateSucessMarketVisible = false;
  var _isProgressVisible = false;

  @override
  void initState() {
    _initTextItems();
    super.initState();
  }

  @override
  void dispose() {
    _coinMarketName.dispose();
    _conversionLineLength.dispose();
    _purchaseCount.dispose();
    _profitLine.dispose();
    _lossLine.dispose();
    _desiredBuyAmount.dispose();
    _minuteCandle.dispose();
    _zoomController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);

    return Dialog(
        alignment: Alignment.center,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.transparent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DraggableCard(
            child: AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(milliseconds: 300),
                color: const Color.fromRGBO(250, 250, 250, 0.95),
                child: KeyboardListener(
                    onKeyEvent: (e) {
                      if (e.runtimeType.toString() == 'KeyDownEvent' &&
                          e.logicalKey == LogicalKeyboardKey.controlLeft) {
                        _isCtrlKeyPressed = true;
                        setState(() {});
                      }

                      if (e.runtimeType.toString() == 'KeyUpEvent' &&
                          e.logicalKey == LogicalKeyboardKey.controlLeft) {
                        _isCtrlKeyPressed = false;
                        setState(() {});
                      }
                    },
                    focusNode: _focusNode..requestFocus(),
                    child: FractionallySizedBox(
                        widthFactor: 0.7,
                        heightFactor: 0.87,
                        child: Container(
                          child: Column(children: [
                            Expanded(
                                flex: 1,
                                child: Container(
                                    color:
                                        const Color.fromRGBO(66, 66, 66, 0.9),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(FontAwesomeIcons.lightbulb,
                                            size: 15),
                                        SizedBox(width: 10),
                                        Text('일목균형표의 컨버젼 전략 아이템 추가'),
                                        Spacer(),
                                        SizedBox(width: 5),
                                        Visibility(
                                            visible: _isProgressVisible,
                                            child: SizedBox(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))),
                                        Tooltip(
                                            message: '랜덤 생성 추가(상위 볼륨 20개 중 랜덤)',
                                            child: IconButton(
                                                onPressed: () async {
                                                  _isProgressVisible = true;
                                                  setState(() {});

                                                  if (_provider
                                                      .volumeTopList.isEmpty) {
                                                    _provider
                                                        .doVolumeItemRequest(
                                                            _provider
                                                                .volumeTopList);

                                                    if (_provider.volumeTopList
                                                        .isEmpty) {
                                                      _isProgressVisible =
                                                          false;
                                                      setState(() {});
                                                      return;
                                                    }
                                                  }

                                                  var isDuplicate = true;
                                                  var maxCnt = (_provider
                                                          .volumeTopList
                                                          .length *
                                                      3);
                                                  var idx = 0;

                                                  while (isDuplicate) {
                                                    if (idx > maxCnt) {
                                                      break;
                                                    }

                                                    isDuplicate = false;

                                                    var random = Random()
                                                        .nextInt(_provider
                                                                .volumeTopList
                                                                .length -
                                                            1);

                                                    Map<String, dynamic> el =
                                                        _provider.volumeTopList
                                                            .elementAt(random);
                                                    var marketName =
                                                        el['marketName'];

                                                    _provider.itemsCollection
                                                        .forEach((element) {
                                                      if (element
                                                              is StrategyBollingerItemInfo &&
                                                          element.coinMarKetName ==
                                                              marketName) {
                                                        isDuplicate = true;
                                                      }

                                                      if (element
                                                              is StrategyIchimokuItemInfo &&
                                                          element.coinMarKetName ==
                                                              marketName) {
                                                        isDuplicate = true;
                                                      }
                                                    });

                                                    if (!isDuplicate) {
                                                      _coinMarketName.text =
                                                          marketName;
                                                      break;
                                                    }

                                                    idx++;
                                                  }

                                                  _isProgressVisible = false;
                                                  setState(() {});

                                                  _doSaveAction(context);
                                                },
                                                icon: Icon(
                                                    FontAwesomeIcons.dice,
                                                    size: 15),
                                                splashRadius: 15)),
                                        Tooltip(
                                            message: '줌 초기화',
                                            excludeFromSemantics: true,
                                            child: IconButton(
                                                onPressed: () => _zoomController
                                                    .value = Matrix4.identity(),
                                                icon: Icon(Icons.zoom_in_map),
                                                splashRadius: 15)),
                                        IconButton(
                                            onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialogCustom(
                                                        text:
                                                            '- 컨버젼(베이스) 라인 매수 전략을 가진 일목균형표 아이템을 추가합니다.\n\n- 오더북 기준으로 가격이 라인에 걸칠 시\n\t\t\t마켓 매수가 실행됩니다.\n(마켓 매수이므로 오차가 발생할 수 있습니다.)\n\n- 볼린저 밴드와 다르게 자주 조건이 만족되는\n\t\t\t경우가 많아 직접 차트를 보고 설정하길\n\t\t\t권합니다.\n\n- 템플릿 저장버튼을 누르면 코인 마켓 이름을\n\t\t\t제외한 전략 정보가 저장됩니다.\n\n- Ctrl+마우스로 줌 확대 및 이동이 가능합니다.')),
                                            icon: Icon(Icons.question_mark),
                                            splashRadius: 15),
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            icon: Icon(Icons.close),
                                            splashRadius: 15)
                                      ],
                                    ))),
                            Expanded(
                                flex: 5,
                                child: InteractiveViewer(
                                    scaleEnabled: _isCtrlKeyPressed,
                                    scaleFactor: 1100,
                                    transformationController: _zoomController,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        physics: BouncingScrollPhysics(
                                            parent:
                                                AlwaysScrollableScrollPhysics()),
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            child: IntrinsicHeight(
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                  Expanded(
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Form(
                                                            key: _optionFormKey,
                                                            child: Column(
                                                                children: [
                                                                  _getIconWithText(
                                                                      FontAwesomeIcons
                                                                          .tags,
                                                                      '선택 코인 마켓 (KRW)'),
                                                                  _getHeadForm(
                                                                      _coinMarketName),
                                                                  SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .line_axis,
                                                                      '컨버젼(베이스) 길이 (최대 200)'),
                                                                  _getOptionForm(
                                                                    _conversionLineLength,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .shopping_cart_checkout,
                                                                      '구매 회수(최대 99회)'),
                                                                  _getOptionForm(
                                                                      _purchaseCount),
                                                                ]),
                                                          ))),
                                                  SizedBox(width: 10),
                                                  VerticalDivider(
                                                    color: Colors.grey[600],
                                                    thickness: 0.5,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Form(
                                                            key:
                                                                _withSuffixFormKey,
                                                            child: Column(
                                                                children: [
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .watch_later,
                                                                      '기준 분봉(최대 240분)'),
                                                                  _getOptionFormForMinuteCandle(
                                                                      _minuteCandle),
                                                                  SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .emoji_emotions_outlined,
                                                                      '익절 기준 (%)'),
                                                                  _getOptionWithSuffixForm(
                                                                      _profitLine),
                                                                  SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .mood_bad,
                                                                      '손절 기준 (%)'),
                                                                  _getOptionWithSuffixForm(
                                                                      _lossLine),
                                                                  SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      FontAwesomeIcons
                                                                          .bagShopping,
                                                                      '구매 수량 (KRW)'),
                                                                  _getOptionWithSuffixFormWithKrw(
                                                                      _desiredBuyAmount)
                                                                ]),
                                                          ))),
                                                ])))))),
                            Expanded(
                                flex: 1,
                                child: SizedBox(
                                    child: Row(children: [
                                  SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: () => _estimateCoinAmount(),
                                    child: Row(children: [
                                      Icon(FontAwesomeIcons.coins, size: 13),
                                      SizedBox(width: 10),
                                      Text('구매 추정량 계산'),
                                    ]),
                                  ),
                                  // Text(_coinBuyEstimated),
                                  SizedBox(width: 10),
                                  SizedBox(
                                      width: 90,
                                      height: 30,
                                      child: FittedBox(
                                          child: _coinAmountEstimated == ''
                                              ? Text('')
                                              : Text('$_coinAmountEstimated 개',
                                                  style: _labelTextStyle()))),
                                  Spacer(),
                                  Visibility(
                                      visible: _isTemplateSucessMarketVisible,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )),
                                  SizedBox(width: 2),
                                  ElevatedButton(
                                      onPressed: () => SaveTemplate(),
                                      child: Text('템플릿 저장')),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                      onPressed: () => _doSaveAction(context),
                                      child: Text('확인')),

                                  SizedBox(width: 20)
                                ]))),
                          ]),
                        ))))));
  }

  Row _getIconWithText(
    IconData icon,
    String text,
  ) {
    return Row(children: [
      Icon(icon, color: Colors.black54, size: 15),
      SizedBox(width: 5),
      Text(
        text,
        textAlign: TextAlign.right,
        style: _labelTextStyle(),
      )
    ]);
  }

  TextFormField _getHeadForm(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      validator: (value) {
        if (value!.isEmpty) {
          return '값을 입력하세요.';
        }

        value = value.toUpperCase();
        if (!value.contains('KRW-')) {
          return 'KRW-를 입력하세요.';
        }

        if (!value.startsWith('KRW-')) {
          return 'KRW-를 입력하세요.';
        }

        if (value.length <= 4) {
          return '값이 너무 짧습니다.';
        }

        if (value.length >= 10) {
          return '값이 너무 깁니다.';
        }

        var isDuplicate = false;

        for (var element in _provider.bollingerItems) {
          if (element.coinMarKetName == value) {
            isDuplicate = true;
          }
        }

        for (var element in _provider.ichimokuItems) {
          if (element.coinMarKetName == value) {
            isDuplicate = true;
          }
        }

        if (isDuplicate) {
          return '동일 마켓이 존재합니다.';
        }

        return null;
      },
      style: _innerFormStyle(),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        errorStyle: _errorTextStyle(),
        hintStyle: TextStyle(
            fontSize: 13,
            color: const Color.fromRGBO(66, 66, 66, 0.6),
            fontWeight: FontWeight.w900),
        hintText: 'KRW-BTC',
      ),
    );
  }

  TextFormField _getOptionForm(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      validator: (value) => value!.isEmpty ? '값을 입력하세요.' : null,
      onTap: () => controller.selection = TextSelection(
          baseOffset: 0, extentOffset: controller.value.text.length),
      style: _innerFormStyle(),
      decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          errorStyle: _errorTextStyle(),
          labelStyle: const TextStyle(fontSize: 12)),
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  TextFormField _getOptionFormForMinuteCandle(
      TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      validator: (value) {
        if (value!.isEmpty) {
          return '값을 입력하세요.';
        }

        if (!candles.contains(value)) {
          return '분봉 값이 부적절합니다.';
        }

        return null;
      },
      onTap: () => controller.selection = TextSelection(
          baseOffset: 0, extentOffset: controller.value.text.length),
      style: _innerFormStyle(),
      decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          errorStyle: _errorTextStyle(),
          labelStyle: const TextStyle(fontSize: 12)),
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  TextFormField _getOptionWithSuffixForm(TextEditingController controller) {
    return TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        validator: (value) {
          if (value!.isEmpty) {
            return '값을 입력하세요.';
          }

          var num = double.tryParse(value);
          if (num != null && num >= 50) {
            if (num >= 50) {
              return '50 이하 입력하세요.';
            }
          }

          return null;
        },
        onTap: () => controller.selection = TextSelection(
            baseOffset: 0, extentOffset: controller.value.text.length),
        style: _innerFormStyle(),
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            errorStyle: _errorTextStyle(),
            labelStyle: const TextStyle(fontSize: 12),
            suffixText: '%',
            suffixStyle: TextStyle(fontSize: 15, color: Colors.grey[800])),
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?(\.)?(\d{0,1})?$'))
        ]);
  }

  TextFormField _getOptionWithSuffixFormWithKrw(
      TextEditingController controller) {
    return TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        validator: (value) {
          if (value!.isEmpty) {
            return '값을 입력하세요.';
          }

          var num = double.tryParse(value);
          if (num != null && num == 0) {
            return '0 이상 입력하세요.';
          }

          return null;
        },
        onTap: () => controller.selection = TextSelection(
            baseOffset: 0, extentOffset: controller.value.text.length),
        style: _innerFormStyle(),
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            errorStyle: _errorTextStyle(),
            labelStyle: const TextStyle(fontSize: 12),
            suffixText: '원',
            suffixStyle: TextStyle(fontSize: 15, color: Colors.grey[800])),
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?(\.)?(\d{0})?$'))
        ]);
  }

  void _doSaveAction(BuildContext context) {
    var newModel = _GetResultWithverifiedText(false);
    if (newModel == null) {
      return;
    }

    Navigator.pop(context, newModel);
  }

  TextStyle _errorTextStyle() {
    return const TextStyle(
      height: 0.5,
      fontSize: 10,
    );
  }

  TextStyle _labelTextStyle() {
    return const TextStyle(
        color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w700);
  }

  TextStyle _innerFormStyle() {
    return TextStyle(
        fontSize: 13,
        color: const Color.fromRGBO(66, 66, 66, 1),
        fontWeight: FontWeight.w900);
  }

  Future<void> _estimateCoinAmount() async {
    if (!_coinMarketName.text.contains('KRW-')) {
      return;
    }

    var coinMarketName = _coinMarketName.text;

    var response = await RestApiClient().requestGet('balance/$coinMarketName');

    var dataMap = await RestApiClient.parseResponseData(response);

    if (dataMap.containsKey('avgBuyPrice')) {
      var price = dataMap['avgBuyPrice'];
      var priceParsed = double.tryParse(price);

      if (priceParsed != null) {
        var desiredKrwAmountParsed = int.tryParse(_desiredBuyAmount.text);
        if (desiredKrwAmountParsed != null) {
          var result = desiredKrwAmountParsed / priceParsed;
          _coinAmountEstimated = result.toStringAsFixed(8);
          setState(() {});
        }
      }
    }
  }

  Future<void> SaveTemplate() async {
    var newModel = _GetResultWithverifiedText(true);
    if (newModel == null) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialogCustom(text: '입력 값이 올바르지 않아 저장에 실패했습니다.'));

      _isTemplateSucessMarketVisible = false;
      setState(() {});
      return;
    }

    newModel.coinMarKetName = 'save';
    var template =
        TemplateModel(bollingerTemplate: null, ichimokuTemplate: newModel);

    var map = template.toJson();
    var data = jsonEncode(map);

    var response = await RestApiClient().requestPost('template', data);

    if (response != null && response.statusCode == 200) {
      _isTemplateSucessMarketVisible = true;
      setState(() {});
    }
  }

  StrategyIchimokuItemInfo? _GetResultWithverifiedText(bool isTemplateSaving) {
    var isPass = true;

    if (_optionFormKey.currentState != null &&
        !_optionFormKey.currentState!.validate()) {
      isPass = false;
    }

    if (_withSuffixFormKey.currentState != null &&
        !_withSuffixFormKey.currentState!.validate()) {
      isPass = false;
    }

    if (!isPass) {
      return null;
    }

    if (!isTemplateSaving && _provider.itemsCollection.length >= 10) {
      showDialog(
          context: context,
          builder: (context) => AlertDialogCustom(text: '최대 전략 개수는 10개 입니다.'));
      return null;
    }

    var count = int.tryParse(_purchaseCount.text);
    var conversionLength = int.tryParse(_conversionLineLength.text);

    if (count != null && count > 99) {
      count = 99;
    }
    if (conversionLength != null && conversionLength > 200) {
      conversionLength = 200;
    }
    return StrategyIchimokuItemInfo(
        _coinMarketName.text.toUpperCase(),
        conversionLength!,
        count!,
        double.parse(_profitLine.text),
        double.parse(_lossLine.text),
        int.parse(_desiredBuyAmount.text),
        int.parse(_minuteCandle.text));
  }

  Future<void> _initTextItems() async {
    var response = await RestApiClient().requestGet('template');

    var data = await RestApiClient.parseResponseData(response);

    if (data.isEmpty) {
      return;
    }

    var template = TemplateModel.fromJson(data);

    if (template.ichimokuTemplate == null ||
        template.ichimokuTemplate!.coinMarKetName != 'save') {
      return;
    }
    _conversionLineLength.text =
        template.ichimokuTemplate!.conversionLine.toString();
    _purchaseCount.text = template.ichimokuTemplate!.purchaseCount.toString();
    _profitLine.text = template.ichimokuTemplate!.profitLinePercent.toString();
    _lossLine.text = template.ichimokuTemplate!.lossLinePercent.toString();
    _desiredBuyAmount.text =
        template.ichimokuTemplate!.desiredBuyAmount.toString();
    _minuteCandle.text = template.ichimokuTemplate!.candleBaseMinute.toString();

    setState(() {});
  }
}
