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
  double profitLine;
  double lossLine;
  // ISO8601
  late String lastBoughtTimeStamp;

  factory StrategyItemInfo.new(
      String coinMarKetName,
      int bollingerLength,
      int bollingerMultiplier,
      int purchaseCount,
      double profitLine,
      double lossLine) {
    var model = StrategyItemInfo.base(
        coinMarKetName: coinMarKetName,
        bollingerLength: bollingerLength,
        bollingerMultiplier: bollingerMultiplier,
        purchaseCount: purchaseCount,
        profitLine: profitLine,
        lossLine: lossLine);

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
      double profitLine,
      double lossLine,
      String lastBoughtTimeStamp) {
    var model = StrategyItemInfo.base(
        coinMarKetName: coinMarKetName,
        bollingerLength: bollingerLength,
        bollingerMultiplier: bollingerMultiplier,
        purchaseCount: purchaseCount,
        profitLine: profitLine,
        lossLine: lossLine);

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
        profitLine: double.tryParse(map['profitLine'].toString())!,
        lossLine: double.tryParse(map['lossLine'].toString())!);

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
      required this.profitLine,
      required this.lossLine});

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
      'profitLine': profitLine,
      'lossLine': lossLine,
      'lastBoughtTimeStamp': lastBoughtTimeStamp,
    };
  }

  StrategyItemInfo fromJson(Map<String, dynamic> json) {
    var colorHex = json['color'];
    var itemId = json['itemId'];
    var coinMarKetName = json['coinMarKetName'];
    var bollingerLength = json['bollingerLength'];
    var bollingerMultiplier = json['bollingerMultiplier'];
    var purchaseCount = json['purchaseCount'];
    var profitLine = json['profitLine'];
    var lossLine = json['lossLine'];
    var timestamp = json['timestamp'];

    var result = StrategyItemInfo.from(
        color,
        itemId,
        coinMarKetName,
        bollingerLength,
        bollingerMultiplier,
        purchaseCount,
        profitLine,
        lossLine,
        timestamp);

    return result;
  }
}
