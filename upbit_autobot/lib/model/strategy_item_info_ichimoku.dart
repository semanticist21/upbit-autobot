import 'package:upbit_autobot/components/helper/custom_converter.dart';
import 'package:upbit_autobot/model/color_info.dart';

class StrategyIchimokuItemInfo {
  late ColorInfo color;
  late String itemId;
  String coinMarKetName;
  int conversionLine;
  int purchaseCount;
  double profitLinePercent;
  double lossLinePercent;
  int desiredBuyAmount;
  int candleBaseMinute;
  // ISO8601
  late String lastBoughtTimeStamp;
  int index = -1;

  factory StrategyIchimokuItemInfo(
      String coinMarKetName,
      int conversionLine,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      int desiredAmount,
      int minuteCandle) {
    var model = StrategyIchimokuItemInfo.base(
        coinMarKetName: coinMarKetName,
        conversionLine: conversionLine,
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

  factory StrategyIchimokuItemInfo.from(
      ColorInfo color,
      String itemId,
      String coinMarKetName,
      int conversionLine,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      String lastBoughtTimeStamp,
      int desiredAmount,
      int minuteCandle) {
    var model = StrategyIchimokuItemInfo.base(
        coinMarKetName: coinMarKetName,
        conversionLine: conversionLine,
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

  factory StrategyIchimokuItemInfo.fromJson(Map<String, dynamic> map) {
    var model = StrategyIchimokuItemInfo.base(
        coinMarKetName: map['coinMarketName'],
        conversionLine: map['conversionLine'],
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

  StrategyIchimokuItemInfo.base(
      {required this.coinMarKetName,
      required this.conversionLine,
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
      'conversionLine': conversionLine,
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
