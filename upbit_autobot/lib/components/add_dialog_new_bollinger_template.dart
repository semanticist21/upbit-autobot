import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/template.dart';
import 'package:upbit_autobot/provider.dart';

import 'alert.dart';

class AddDialogNewBollingerTemplate extends StatefulWidget {
  const AddDialogNewBollingerTemplate({super.key});

  @override
  State<AddDialogNewBollingerTemplate> createState() =>
      _AddDialogNewBollingerTemplateState();
}

class _AddDialogNewBollingerTemplateState
    extends State<AddDialogNewBollingerTemplate>
    with SingleTickerProviderStateMixin {
  final _bollingerLength = TextEditingController(text: '20');
  final _bollingerMultiplier = TextEditingController(text: '2');
  final _purchaseCount = TextEditingController(text: '3');
  final _profitLine = TextEditingController(text: '5');
  final _lossLine = TextEditingController(text: '5');
  final _desiredBuyAmount = TextEditingController(text: '50000');
  final _minuteCandle = TextEditingController(text: '15');

  final _optionFormKey = GlobalKey<FormState>();
  final _withSuffixFormKey = GlobalKey<FormState>();

  late AppProvider _provider;
  final List<String> candles = ['1', '3', '5', '15', '30', '60', '240'];

  var _isCtrlKeyPressed = false;
  final _focusNode = FocusNode();
  final _zoomController = TransformationController();
  var _isTemplateSucessMarketVisible = false;
  final _isProgressVisible = false;

  @override
  void initState() {
    _initTextItems();
    super.initState();
  }

  @override
  void dispose() {
    _bollingerLength.dispose();
    _bollingerMultiplier.dispose();
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
            side: const BorderSide(color: Colors.transparent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DraggableCard(
            child: AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(milliseconds: 300),
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
                        child: SizedBox(
                          child: Column(children: [
                            Expanded(
                                flex: 1,
                                child: Container(
                                    color:
                                        const Color.fromRGBO(66, 66, 66, 0.9),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 15),
                                        const Icon(FontAwesomeIcons.lightbulb,
                                            size: 15),
                                        const SizedBox(width: 10),
                                        const Text('볼린저 밴드 템플릿 추가'),
                                        const Spacer(),
                                        const SizedBox(width: 5),
                                        Visibility(
                                            visible: _isProgressVisible,
                                            child: const SizedBox(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))),
                                        Tooltip(
                                            message: '줌 초기화',
                                            excludeFromSemantics: true,
                                            child: IconButton(
                                                onPressed: () => _zoomController
                                                    .value = Matrix4.identity(),
                                                icon: const Icon(
                                                    Icons.zoom_in_map),
                                                splashRadius: 15)),
                                        IconButton(
                                            onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    const AlertDialogCustom(
                                                        text:
                                                            '- 볼린저 하단 매수 전략을 가진 볼린저 밴드 아이템을 추가합니다.\n\n- 오더북 기준으로 가격이 하단보다 내려갈 시\n\t\t\t마켓 매수가 실행됩니다.\n(마켓 매수이므로 오차가 발생할 수 있습니다.)\n\n- 템플릿 저장버튼을 누르면 코인 마켓 이름을\n\t\t\t제외한 전략 정보가 저장됩니다.\n\n- Ctrl+마우스로 줌 확대 및 이동이 가능합니다.')),
                                            icon:
                                                const Icon(Icons.question_mark),
                                            splashRadius: 15),
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            icon: const Icon(Icons.close),
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
                                        physics: const BouncingScrollPhysics(
                                            parent:
                                                AlwaysScrollableScrollPhysics()),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                                      Icons
                                                                          .line_axis,
                                                                      '볼린저 길이 (최대 100)'),
                                                                  _getOptionForm(
                                                                    _bollingerLength,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .calculate_rounded,
                                                                      '볼린저 곱 (최대 100)'),
                                                                  _getOptionForm(
                                                                      _bollingerMultiplier),
                                                                  const SizedBox(
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
                                                  const SizedBox(width: 10),
                                                  VerticalDivider(
                                                    color: Colors.grey[600],
                                                    thickness: 0.5,
                                                  ),
                                                  const SizedBox(width: 10),
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
                                                                  const SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .emoji_emotions_outlined,
                                                                      '익절 기준 (%)'),
                                                                  _getOptionWithSuffixForm(
                                                                      _profitLine),
                                                                  const SizedBox(
                                                                      height:
                                                                          15),
                                                                  _getIconWithText(
                                                                      Icons
                                                                          .mood_bad,
                                                                      '손절 기준 (%)'),
                                                                  _getOptionWithSuffixForm(
                                                                      _lossLine),
                                                                  const SizedBox(
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
                                  const Spacer(),
                                  Visibility(
                                      visible: _isTemplateSucessMarketVisible,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )),
                                  const SizedBox(width: 2),
                                  ElevatedButton(
                                      onPressed: () => saveTemplate(context),
                                      child: const Text('템플릿 저장')),
                                  const SizedBox(width: 10),
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
      const SizedBox(width: 5),
      Text(
        text,
        textAlign: TextAlign.right,
        style: _labelTextStyle(),
      )
    ]);
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
    return const TextStyle(
        fontSize: 13,
        color: Color.fromRGBO(66, 66, 66, 1),
        fontWeight: FontWeight.w900);
  }

  Future<void> saveTemplate(BuildContext context) async {
    var newModel = _getResultWithverifiedText(true);
    if (newModel == null) {
      showDialog(
          context: context,
          builder: (context) =>
              const AlertDialogCustom(text: '입력 값이 올바르지 않아 저장에 실패했습니다.'));

      _isTemplateSucessMarketVisible = false;
      setState(() {});

      return;
    }

    newModel.coinMarKetName = 'save';
    var template =
        TemplateModel(bollingerTemplate: newModel, ichimokuTemplate: null);

    var map = template.toJson();
    var data = jsonEncode(map);

    var response = await RestApiClient().requestPost('template', data);

    if (response != null && response.statusCode == 200) {
      _isTemplateSucessMarketVisible = true;
      setState(() {});
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  StrategyBollingerItemInfo? _getResultWithverifiedText(bool isTemplateSaving) {
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
          builder: (context) =>
              const AlertDialogCustom(text: '최대 전략 개수는 10개 입니다.'));
      return null;
    }

    var count = int.tryParse(_purchaseCount.text);
    var length = int.tryParse(_bollingerLength.text);
    var multiplier = int.tryParse(_bollingerMultiplier.text);

    if (count != null && count > 99) {
      count = 99;
    }
    if (length != null && length > 100) {
      length = 100;
    }
    if (multiplier != null && multiplier > 100) {
      multiplier = 100;
    }
    return StrategyBollingerItemInfo(
        '',
        length!,
        multiplier!,
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

    if (template.bollingerTemplate == null ||
        template.bollingerTemplate!.coinMarKetName != 'save') {
      return;
    }
    _bollingerLength.text =
        template.bollingerTemplate!.bollingerLength.toString();
    _bollingerMultiplier.text =
        template.bollingerTemplate!.bollingerMultiplier.toString();
    _purchaseCount.text = template.bollingerTemplate!.purchaseCount.toString();
    _profitLine.text = template.bollingerTemplate!.profitLinePercent.toString();
    _lossLine.text = template.bollingerTemplate!.lossLinePercent.toString();
    _desiredBuyAmount.text =
        template.bollingerTemplate!.desiredBuyAmount.toString();
    _minuteCandle.text =
        template.bollingerTemplate!.candleBaseMinute.toString();

    setState(() {});
  }
}
