import 'package:upbit_autobot/model/color_info.dart';

import '../components/helper/custom_converter.dart';

class StrategyBollingerItemInfo {
  late ColorInfo color;
  late String itemId;
  String coinMarKetName;
  int bollingerLength;
  int bollingerMultiplier;
  int purchaseCount;
  double profitLinePercent;
  double lossLinePercent;
  int desiredBuyAmount;
  int candleBaseMinute;
  // ISO8601
  late String lastBoughtTimeStamp;
  int index = -1;

  factory StrategyBollingerItemInfo(
      String coinMarKetName,
      int bollingerLength,
      int bollingerMultiplier,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      int desiredAmount,
      int minuteCandle) {
    var model = StrategyBollingerItemInfo.base(
        coinMarKetName: coinMarKetName,
        bollingerLength: bollingerLength,
        bollingerMultiplier: bollingerMultiplier,
        purchaseCount: purchaseCount,
        profitLinePercent: profitLinePercent,
        lossLinePercent: lossLinePercent,
        desiredBuyAmount: desiredAmount,
        candleBaseMinute: minuteCandle);

    model.color = ColorInfo(color: ColorInfo.generateRandomColor());
    model.itemId = CustomConverter.generateRandomString();
    model.lastBoughtTimeStamp = '';

    return model;
  }

  factory StrategyBollingerItemInfo.from(
      ColorInfo color,
      String itemId,
      String coinMarKetName,
      int bollingerLength,
      int bollingerMultiplier,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      String lastBoughtTimeStamp,
      int desiredAmount,
      int minuteCandle) {
    var model = StrategyBollingerItemInfo.base(
        coinMarKetName: coinMarKetName,
        bollingerLength: bollingerLength,
        bollingerMultiplier: bollingerMultiplier,
        purchaseCount: purchaseCount,
        profitLinePercent: profitLinePercent,
        lossLinePercent: lossLinePercent,
        desiredBuyAmount: desiredAmount,
        candleBaseMinute: minuteCandle);

    model.color = color;
    model.itemId = itemId;
    model.lastBoughtTimeStamp = lastBoughtTimeStamp;

    return model;
  }

  factory StrategyBollingerItemInfo.fromJson(Map<String, dynamic> map) {
    var model = StrategyBollingerItemInfo.base(
        coinMarKetName: map['coinMarketName'],
        bollingerLength: map['bollingerLength'],
        bollingerMultiplier: map['bollingerMultiplier'],
        purchaseCount: map['purchaseCount'],
        profitLinePercent:
            double.tryParse(map['profitLinePercent'].toString())!,
        lossLinePercent: double.tryParse(map['lossLinePercent'].toString())!,
        desiredBuyAmount: int.tryParse(map['desiredBuyAmount'].toString())!,
        candleBaseMinute: map['candleBaseMinute']);

    model.color = map['color'] == ''
        ? ColorInfo(color: ColorInfo.generateRandomColor())
        : ColorInfo.fromHex(map['color']);
    model.itemId = map['itemId'];
    model.lastBoughtTimeStamp = map['lastBoughtTimeStamp'];
    model.index = map['index'];

    return model;
  }

  StrategyBollingerItemInfo.base(
      {required this.coinMarKetName,
      required this.bollingerLength,
      required this.bollingerMultiplier,
      required this.purchaseCount,
      required this.profitLinePercent,
      required this.lossLinePercent,
      required this.desiredBuyAmount,
      required this.candleBaseMinute});

  Map<String, dynamic> toJson() {
    return {
      'color': color.hexCode,
      'itemId': itemId,
      'coinMarKetName': coinMarKetName,
      'bollingerLength': bollingerLength,
      'bollingerMultiplier': bollingerMultiplier,
      'purchaseCount': purchaseCount,
      'profitLinePercent': profitLinePercent,
      'lossLinePercent': lossLinePercent,
      'lastBoughtTimeStamp': lastBoughtTimeStamp,
      'desiredBuyAmount': desiredBuyAmount,
      'candleBaseMinute': candleBaseMinute,
      'index': index,
    };
  }
}
