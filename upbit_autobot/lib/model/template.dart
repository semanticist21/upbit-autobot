import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';

class TemplateModel {
  StrategyBollingerItemInfo? bollingerTemplate;
  StrategyIchimokuItemInfo? ichimokuTemplate;

  TemplateModel(
      {required this.bollingerTemplate, required this.ichimokuTemplate});

  factory TemplateModel.fromJson(Map<String, dynamic> map) {
    return TemplateModel(
        bollingerTemplate:
            StrategyBollingerItemInfo.fromJson(map['bollingerTemplate']),
        ichimokuTemplate:
            StrategyIchimokuItemInfo.fromJson(map['ichimokuTemplate']));
  }

  Map<String, dynamic> toJson() {
    var dic = <String, dynamic>{};
    dic['bollingerTemplate'] = bollingerTemplate;
    dic['ichimokuTemplate'] = ichimokuTemplate;
    return dic;
  }
}
