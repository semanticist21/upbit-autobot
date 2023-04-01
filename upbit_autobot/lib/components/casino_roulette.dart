import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';

import '../model/color_info.dart';
import '../model/strategy_item_info.dart';
import '../model/strategy_item_info_ichimoku.dart';
import '../provider.dart';

class CasionoRoulette extends StatefulWidget {
  CasionoRoulette({super.key});
  final stateWidget = _CasionoRouletteState();

  @override
  // ignore: no_logic_in_create_state
  State<CasionoRoulette> createState() => stateWidget;
}

class _CasionoRouletteState extends State<CasionoRoulette>
    with SingleTickerProviderStateMixin {
  late AppProvider _provider;
  var _hasTried = false;

  List<Color> colorInfos =
      List.generate(20, (_) => ColorInfo.generateRandomColorNoOpacity());

  final alreadyGenerateDic = <String, bool>{};

  late RouletteController controller = RouletteController(
      group: RouletteGroup([
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: const TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: const TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: const TextStyle(fontSize: 20)),
        RouletteUnit.text('아이템\n없음',
            color: ColorInfo.generateRandomColorNoOpacity(),
            textStyle: const TextStyle(fontSize: 20)),
      ]),
      vsync: this);

  Map<String, bool> map = {};

  @override
  void initState() {
    super.initState();
    alreadyGenerateDic.clear();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context, listen: false);

    if (!_hasTried) {
      _initRouletteGroup();
      mapReset();
    }

    return Roulette(
      controller: controller,
      style: const RouletteStyle(
          dividerColor: Colors.transparent,
          dividerThickness: 1,
          centerStickerColor: Colors.black,
          centerStickSizePercent: 0.08),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initRouletteGroup() async {
    if (_provider.volumeTopList.isEmpty) {
      await _provider.doVolumeItemRequest();
      _hasTried = true;
    }

    var item = _getUnitItem();
    if (item.isNotEmpty) {
      controller.group = RouletteGroup(_getUnitItem());
      setState(() {});
    }
  }

  List<RouletteUnit> _getUnitItem() {
    List<RouletteUnit> list = List.empty(growable: true);
    var index = 0;
    for (var element in _provider.volumeTopList) {
      List<String> chunks = [];
      var str = element['coinKrName'];

      if (str.length != 3) {
        for (int i = 0; i < str.length; i += 2) {
          if (i + 2 >= str.length) {
            String chunk = str.substring(i, str.length);
            chunks.add(chunk);
            break;
          }

          String chunk = str.substring(i, i + 2);
          chunks.add(chunk);
        }
      } else {
        chunks.add(str);
      }

      String spacedText = chunks.join("\n");

      var unit = RouletteUnit(
          color: colorInfos[index],
          weight: 1,
          text: spacedText,
          textStyle: const TextStyle(fontSize: 10));

      list.add(unit);
      index++;
    }

    setState(() {});

    return list;
  }

  Future<int> rollRoll(List<int> usedIndexs) async {
    var randomValue = Random().nextInt(_provider.volumeTopList.length - 1);

    while (map
            .containsKey(_provider.volumeTopList[randomValue]['marketName']) ||
        usedIndexs.contains(randomValue) ||
        alreadyGenerateDic
            .containsKey(_provider.volumeTopList[randomValue]['marketName'])) {
      randomValue = Random().nextInt(_provider.volumeTopList.length - 1);
    }

    await controller.rollTo(randomValue,
        duration: const Duration(milliseconds: 2000), minRotateCircles: 2);

    return randomValue;
  }

  void mapReset() {
    map.clear();
    map = <String, bool>{};
    for (var element in _provider.itemsCollection) {
      if (element is StrategyBollingerItemInfo) {
        map[element.coinMarKetName] = true;
      }

      if (element is StrategyIchimokuItemInfo) {
        map[element.coinMarKetName] = true;
      }
    }
  }
}
