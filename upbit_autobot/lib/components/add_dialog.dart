import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/provider.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  var _coinMarketName = TextEditingController();
  var _bollingerLength = TextEditingController(text: '20');
  var _bollingerMultiplier = TextEditingController(text: '2');
  var _purchaseCount = TextEditingController(text: '3');
  var _profitLine = TextEditingController(text: '5');
  var _lossLine = TextEditingController(text: '5');

  final _coinMarketIdKey = GlobalKey<FormState>();
  final _optionFormKey = GlobalKey<FormState>();
  final _withSuffixFormKey = GlobalKey<FormState>();

  late AppProvider _provider;

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);

    return Dialog(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        shadowColor: Color.fromRGBO(66, 66, 66, 1.0),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey)),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Container(
            width: 300,
            height: 270,
            child: Column(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color.fromRGBO(66, 66, 66, 1.0),
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.paperclip, size: 15),
                              SizedBox(width: 20),
                              Form(
                                  key: _coinMarketIdKey,
                                  child: Container(
                                      width: 150,
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                      child: TextFormField(
                                        controller: _coinMarketName,
                                        textAlign: TextAlign.center,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '값을 입력하세요.';
                                          }
                                          if (!value.contains('-KRW')) {
                                            return '-KRW를 입력하세요.';
                                          }

                                          if (!value.endsWith('-KRW')) {
                                            return '-KRW를 입력하세요.';
                                          }

                                          var isDuplicate = false;

                                          _provider.items.forEach((element) {
                                            if (element.coinMarKetName ==
                                                value) {
                                              isDuplicate = true;
                                            }
                                          });

                                          if (isDuplicate) {
                                            return '동일 마켓이 존재합니다.';
                                          }

                                          if (_provider.items.length >= 10) {
                                            return '최대 전략 개수 10개';
                                          }
                                        },
                                        style: TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                            errorStyle: _errorTextStyle(),
                                            hintStyle: TextStyle(fontSize: 13),
                                            labelStyle: TextStyle(fontSize: 11),
                                            hintText: 'BTC-KRW'),
                                      ))),
                            ]),
                        Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(FontAwesomeIcons.x, size: 13))
                              ]),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color.fromRGBO(97, 97, 97, 1.0),
                      child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: IntrinsicHeight(
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
                                                        '구매 회수(최대 3회)'),
                                                  ])))),
                                  VerticalDivider(),
                                  Expanded(
                                      child: Container(
                                    color: Colors.transparent,
                                    child: Form(
                                        key: _withSuffixFormKey,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _getOptionWithSuffixForm(
                                                  _profitLine, "익절 기준"),
                                              _getOptionWithSuffixForm(
                                                  _lossLine, "손절 기준"),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        width: 40,
                                                        height: 20,
                                                        child:
                                                            FloatingActionButton
                                                                .small(
                                                          child: Text('저장',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          elevation: 5,
                                                          hoverColor:
                                                              const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  205,
                                                                  205,
                                                                  205),
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                          shape: ContinuousRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blueGrey)),
                                                          onPressed: () =>
                                                              _doSaveAction(
                                                                  context),
                                                        )),
                                                    SizedBox(width: 2),
                                                  ])
                                            ])),
                                  ))
                                ],
                              )))))),
            ])));
  }

  TextFormField _getOptionForm(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? '값을 입력하세요.' : null,
      decoration: InputDecoration(
          errorStyle: _errorTextStyle(),
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 11)),
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: false),
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
          var num = int.tryParse(value);
          if (num != null && num >= 50) {
            return '50 이하 입력하세요.';
          }
        },
        decoration: InputDecoration(
            errorStyle: _errorTextStyle(),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 11),
            suffixText: '%'),
        keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{1})?$'))
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

    if (count != null && count > 3) {
      count = 3;
    }

    var newModel = StrategyItemInfo.new(
      _coinMarketName.text,
      int.tryParse(_bollingerLength.text)!,
      int.tryParse(_bollingerMultiplier.text)!,
      count!,
      double.tryParse(_profitLine.text)!,
      double.tryParse(_profitLine.text)!,
    );

    Navigator.pop(context, newModel);
  }

  TextStyle _errorTextStyle() {
    return TextStyle(
      height: 0.5,
      fontSize: 10,
    );
  }
}
