import 'package:flutter/widgets.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';

class TemplateModel {
  StrategyItemInfo? bollingerTemplate;
  StrategyIchimokuItemInfo? ichimokuTemplate;

  TemplateModel(
      {required this.bollingerTemplate, required this.ichimokuTemplate});

  factory TemplateModel.fromJson(Map<String, dynamic> map) {
    return TemplateModel(
        bollingerTemplate: map['bollingerTemplate'],
        ichimokuTemplate: map['ichimokuTemplate']);
  }

  Map<String, dynamic> toJson() {
    var dic = Map<String, dynamic>();
    dic['bollingerItem'] = this.bollingerTemplate;
    dic['ichomokuItem'] = this.ichimokuTemplate;
    return dic;
  }
}
