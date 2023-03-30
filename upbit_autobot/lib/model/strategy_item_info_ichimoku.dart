import 'dart:math';
import 'package:upbit_autobot/model/color_info.dart';
import 'package:crypto/crypto.dart';

class StrategyIchimokuItemInfo {
  late ColorInfo color;
  late String itemId;
  String coinMarKetName;
  int conversionLine;
  int purchaseCount;
  double profitLinePercent;
  double lossLinePercent;
  double desiredBuyAmount;
  int candleBaseMinute;
  // ISO8601
  late String lastBoughtTimeStamp;

  factory StrategyIchimokuItemInfo(
      String coinMarKetName,
      int conversionLine,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      double desiredAmount,
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
    model.itemId = _generateRandomString();
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
      double desiredAmount,
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
        desiredBuyAmount: double.tryParse(map['desiredBuyAmount'].toString())!,
        candleBaseMinute: map['candleBaseMinute']);

    model.color = map['color'] == ''
        ? ColorInfo(color: ColorInfo.generateRandomColor())
        : ColorInfo.fromHex(map['color']);
    model.itemId = map['itemId'];
    model.lastBoughtTimeStamp = map['lastBoughtTimeStamp'];

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

  static String _generateRandomString() {
    var random = Random();
    var randomBytes = List.generate(32, (index) => random.nextInt(256));
    var digest = sha256.convert(randomBytes);

    return digest.toString();
  }

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
    };
  }
}
