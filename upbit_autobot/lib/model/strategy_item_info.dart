import 'dart:math';
import 'package:upbit_autobot/model/color_info.dart';
import 'package:crypto/crypto.dart';

class StrategyItemInfo {
  late ColorInfo color;
  late String itemId;
  String coinMarKetName;
  int bollingerLength;
  int bollingerMultiplier;
  int purchaseCount;
  double profitLinePercent;
  double lossLinePercent;
  double desiredBuyAmount;
  int candleBaseMinute;
  // ISO8601
  late String lastBoughtTimeStamp;

  factory StrategyItemInfo.new(
      String coinMarKetName,
      int bollingerLength,
      int bollingerMultiplier,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      double desiredAmount,
      int minuteCandle) {
    var model = StrategyItemInfo.base(
        coinMarKetName: coinMarKetName,
        bollingerLength: bollingerLength,
        bollingerMultiplier: bollingerMultiplier,
        purchaseCount: purchaseCount,
        profitLinePercent: profitLinePercent,
        lossLinePercent: lossLinePercent,
        desiredBuyAmount: desiredAmount,
        candleBaseMinute: minuteCandle);

    model.color = ColorInfo(color: ColorInfo.generateRandomColor());
    model.itemId = generateRandomString();
    model.lastBoughtTimeStamp = '';

    return model;
  }

  factory StrategyItemInfo.from(
      ColorInfo color,
      String itemId,
      String coinMarKetName,
      int bollingerLength,
      int bollingerMultiplier,
      int purchaseCount,
      double profitLinePercent,
      double lossLinePercent,
      String lastBoughtTimeStamp,
      double desiredAmount,
      int minuteCandle) {
    var model = StrategyItemInfo.base(
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

  factory StrategyItemInfo.fromJson(Map<String, dynamic> map) {
    var model = StrategyItemInfo.base(
        coinMarKetName: map['coinMarketName'],
        bollingerLength: map['bollingerLength'],
        bollingerMultiplier: map['bollingerMultiplier'],
        purchaseCount: map['purchaseCount'],
        profitLinePercent:
            double.tryParse(map['profitLinePercent'].toString())!,
        lossLinePercent: double.tryParse(map['lossLinePercent'].toString())!,
        desiredBuyAmount: double.tryParse(map['desiredBuyAmount'].toString())!,
        candleBaseMinute: map['candleBaseMinute']);

    model.color = ColorInfo.FromHex(map['color']);
    model.itemId = map['itemId'];
    model.lastBoughtTimeStamp = map['lastBoughtTimeStamp'];

    return model;
  }

  StrategyItemInfo.base(
      {required this.coinMarKetName,
      required this.bollingerLength,
      required this.bollingerMultiplier,
      required this.purchaseCount,
      required this.profitLinePercent,
      required this.lossLinePercent,
      required this.desiredBuyAmount,
      required this.candleBaseMinute});

  static String generateRandomString() {
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
      'bollingerLength': bollingerLength,
      'bollingerMultiplier': bollingerMultiplier,
      'purchaseCount': purchaseCount,
      'profitLinePercent': profitLinePercent,
      'lossLinePercent': lossLinePercent,
      'lastBoughtTimeStamp': lastBoughtTimeStamp,
      'desiredBuyAmount': desiredBuyAmount,
      'candleBaseMinute': candleBaseMinute,
    };
  }
}
