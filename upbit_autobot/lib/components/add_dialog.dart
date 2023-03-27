import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:upbit_autobot/components/converter.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/provider.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _coinMarketName = TextEditingController();
  final _bollingerLength = TextEditingController(text: '20');
  final _bollingerMultiplier = TextEditingController(text: '2');
  final _purchaseCount = TextEditingController(text: '3');
  final _profitLine = TextEditingController(text: '5');
  final _lossLine = TextEditingController(text: '5');
  final _desiredBuyAmount = TextEditingController(text: '1');
  final _minuteCandle = TextEditingController(text: '15');

  final _coinMarketIdKey = GlobalKey<FormState>();
  final _optionFormKey = GlobalKey<FormState>();
  final _withSuffixFormKey = GlobalKey<FormState>();

  late AppProvider _provider;
  final List<String> candles = ['1', '3', '5', '15', '30', '60', '240'];

  var _coinPriceCalcuationResult = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _coinMarketName.dispose();
    _bollingerLength.dispose();
    _bollingerMultiplier.dispose();
    _purchaseCount.dispose();
    _profitLine.dispose();
    _lossLine.dispose();
    _desiredBuyAmount.dispose();
    _minuteCandle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);

    return Dialog(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        shadowColor: const Color.fromRGBO(66, 66, 66, 1.0),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.grey)),
        elevation: 1,
        child: Container(
            padding: const EdgeInsets.all(1),
            width: 380,
            height: 370,
            child: Column(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color.fromRGBO(66, 66, 66, 1.0),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(FontAwesomeIcons.paperclip, size: 15),
                              const SizedBox(width: 20),
                              Form(
                                  key: _coinMarketIdKey,
                                  child: Container(
                                      width: 150,
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 15),
                                      child: TextFormField(
                                        controller: _coinMarketName,
                                        textAlign: TextAlign.center,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '값을 입력하세요.';
                                          }
                                          if (!value.contains('KRW-')) {
                                            return 'KRW-를 입력하세요.';
                                          }

                                          if (!value.startsWith('KRW-')) {
                                            return 'KRW-를 입력하세요.';
                                          }

                                          if (value.length >= 10) {
                                            return '값이 너무 깁니다.';
                                          }

                                          var isDuplicate = false;

                                          for (var element in _provider.items) {
                                            if (element.coinMarKetName ==
                                                value) {
                                              isDuplicate = true;
                                            }
                                          }

                                          if (isDuplicate) {
                                            return '동일 마켓이 존재합니다.';
                                          }

                                          if (_provider.items.length >= 10) {
                                            return '최대 전략 개수 10개';
                                          }

                                          return null;
                                        },
                                        style: const TextStyle(fontSize: 15),
                                        decoration: InputDecoration(
                                            errorStyle: _errorTextStyle(),
                                            hintStyle:
                                                const TextStyle(fontSize: 17),
                                            labelStyle:
                                                const TextStyle(fontSize: 11),
                                            hintText: 'KRW-BTC'),
                                      ))),
                            ]),
                        Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(FontAwesomeIcons.x,
                                        size: 13))
                              ]),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 5,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color.fromRGBO(97, 97, 97, 1.0),
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: IntrinsicHeight(
                                  child: SizedBox(
                                      height: 270,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                                  color: Colors.transparent,
                                                  child: Form(
                                                      key: _optionFormKey,
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            _getOptionForm(
                                                                _bollingerLength,
                                                                '볼린저 길이'),
                                                            _getOptionForm(
                                                                _bollingerMultiplier,
                                                                '볼린저 곱'),
                                                            _getOptionForm(
                                                                _purchaseCount,
                                                                '구매 회수(최대 10회)'),
                                                            _getOptionFormForMinuteCandle(
                                                                _minuteCandle,
                                                                '기준 분봉(최대 240분)'),
                                                          ])))),
                                          const VerticalDivider(),
                                          Expanded(
                                              child: Container(
                                            color: Colors.transparent,
                                            child: Form(
                                                key: _withSuffixFormKey,
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _getOptionWithSuffixForm(
                                                          _profitLine, '익절 기준'),
                                                      _getOptionWithSuffixForm(
                                                          _lossLine, '손절 기준'),
                                                      _getOptionWithSuffixFormUptoFourDigit(
                                                          _desiredBuyAmount,
                                                          '구매 수량(최소 0.0001 개)'),
                                                      Row(children: [
                                                        Tooltip(
                                                            excludeFromSemantics:
                                                                true,
                                                            message:
                                                                '구매 값 원화 계산(추정)',
                                                            child: IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (!_coinMarketName
                                                                      .text
                                                                      .contains(
                                                                          'KRW-')) {
                                                                    return;
                                                                  }

                                                                  var coinMarketName =
                                                                      _coinMarketName
                                                                          .text;

                                                                  var response =
                                                                      await RestApiClient()
                                                                          .requestGet(
                                                                              'balance/$coinMarketName');

                                                                  var dataMap =
                                                                      RestApiClient
                                                                          .parseResponseData(
                                                                              response);

                                                                  if (dataMap
                                                                      .containsKey(
                                                                          'avgBuyPrice')) {
                                                                    var price =
                                                                        dataMap[
                                                                            'avgBuyPrice'];
                                                                    var priceParsed =
                                                                        double.tryParse(
                                                                            price);

                                                                    if (priceParsed !=
                                                                        null) {
                                                                      var desiredBuyAmountParsed =
                                                                          double.tryParse(
                                                                              _desiredBuyAmount.text);
                                                                      if (desiredBuyAmountParsed !=
                                                                          null) {
                                                                        var result =
                                                                            priceParsed *
                                                                                desiredBuyAmountParsed;

                                                                        _coinPriceCalcuationResult =
                                                                            Converter.currencyFormat(result.toInt());
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .calculate,
                                                                  size: 30,
                                                                ))),
                                                        SizedBox(
                                                            width: 130,
                                                            height: 30,
                                                            child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: Text(
                                                                    _coinPriceCalcuationResult !=
                                                                            ''
                                                                        ? '$_coinPriceCalcuationResult 원'
                                                                        : '',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            8))))
                                                      ]),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            SizedBox(
                                                                width: 50,
                                                                height: 30,
                                                                child:
                                                                    FloatingActionButton
                                                                        .small(
                                                                  elevation: 5,
                                                                  hoverColor:
                                                                      const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          205,
                                                                          205,
                                                                          205),
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                                  shape: ContinuousRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      side: const BorderSide(
                                                                          color:
                                                                              Colors.blueGrey)),
                                                                  onPressed: () =>
                                                                      _doSaveAction(
                                                                          context),
                                                                  child: Text(
                                                                      '확인',
                                                                      style: TextStyle(
                                                                          color: Colors.grey[
                                                                              600],
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                )),
                                                            const SizedBox(
                                                                width: 2),
                                                          ])
                                                    ])),
                                          ))
                                        ],
                                      ))))))),
            ])));
  }

  TextFormField _getOptionForm(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? '값을 입력하세요.' : null,
      onTap: () => controller.selection = TextSelection(
          baseOffset: 0, extentOffset: controller.value.text.length),
      decoration: InputDecoration(
          errorStyle: _errorTextStyle(),
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 12)),
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  TextFormField _getOptionFormForMinuteCandle(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
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
      decoration: InputDecoration(
          errorStyle: _errorTextStyle(),
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 12)),
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  TextFormField _getOptionWithSuffixForm(
      TextEditingController controller, String labelText) {
    return TextFormField(
        controller: controller,
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
        decoration: InputDecoration(
            errorStyle: _errorTextStyle(),
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 12),
            suffixText: '%',
            suffixStyle: const TextStyle(fontSize: 15)),
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?(\.)?(\d{0,1})?$'))
        ]);
  }

  TextFormField _getOptionWithSuffixFormUptoFourDigit(
      TextEditingController controller, String labelText) {
    return TextFormField(
        controller: controller,
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
        decoration: InputDecoration(
            errorStyle: _errorTextStyle(),
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 12),
            suffixText: '개',
            suffixStyle: const TextStyle(fontSize: 15)),
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?(\.)?(\d{0,4})?$'))
        ]);
  }

  void _doSaveAction(BuildContext context) {
    var isPass = true;

    if (_coinMarketIdKey.currentState != null &&
        !_coinMarketIdKey.currentState!.validate()) {
      isPass = false;
    }

    if (_optionFormKey.currentState != null &&
        !_optionFormKey.currentState!.validate()) {
      isPass = false;
    }

    if (_withSuffixFormKey.currentState != null &&
        !_withSuffixFormKey.currentState!.validate()) {
      isPass = false;
    }

    if (!isPass) {
      return;
    }

    var count = int.tryParse(_purchaseCount.text);
    var length = int.tryParse(_bollingerLength.text);
    var multiplier = int.tryParse(_bollingerMultiplier.text);

    if (count != null && count > 10) {
      count = 10;
    }
    if (length != null && length > 100) {
      length = 100;
    }
    if (multiplier != null && multiplier > 100) {
      multiplier = 100;
    }

    var newModel = StrategyItemInfo(
        _coinMarketName.text.toUpperCase(),
        length!,
        multiplier!,
        count!,
        double.parse(_profitLine.text),
        double.parse(_lossLine.text),
        double.parse(_desiredBuyAmount.text),
        int.parse(_minuteCandle.text));

    Navigator.pop(context, newModel);
  }

  TextStyle _errorTextStyle() {
    return const TextStyle(
      height: 0.5,
      fontSize: 10,
    );
  }
}
