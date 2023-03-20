import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  var _coinMarketId = TextEditingController();
  var _bollingerLength = TextEditingController(text: '20');
  var _bollingerMultiplier = TextEditingController(text: '2');
  var _count = TextEditingController(text: '3');
  var _profitLine = TextEditingController(text: '5');
  var _lossLine = TextEditingController(text: '5');

  final _coinMarketIdKey = GlobalKey<FormState>();
  final _optionFormKey = GlobalKey<FormState>();
  final _withSuffixFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                                      height: 80,
                                      width: 100,
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                      child: TextFormField(
                                        controller: _coinMarketId,
                                        textAlign: TextAlign.center,
                                        validator: (value) =>
                                            value!.isEmpty ? '값을 입력하세요.' : null,
                                        decoration: InputDecoration(
                                            errorStyle: _errorTextStyle(),
                                            hintStyle: TextStyle(fontSize: 13),
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
                                                    _bollingerLength, '볼린저 길이'),
                                                _getOptionForm(
                                                    _bollingerMultiplier,
                                                    '볼린저 곱'),
                                                _getOptionForm(_count, '구매 회수'),
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
                                                    child: FloatingActionButton
                                                        .small(
                                                      child: Text('저장',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                      elevation: 5,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                      shape:
                                                          ContinuousRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blueGrey)),
                                                      onPressed: _doSaveAction,
                                                    )),
                                                SizedBox(width: 2),
                                              ])
                                        ])),
                              ))
                            ],
                          ))))),
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
        validator: (value) => value!.isEmpty ? '값을 입력하세요.' : null,
        decoration: InputDecoration(
            errorStyle: _errorTextStyle(),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 11),
            suffixText: '%'),
        keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly]);
  }

  void _doSaveAction() {
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
  }

  TextStyle _errorTextStyle() {
    return TextStyle(
      height: 0.5,
      fontSize: 10,
    );
  }
}
