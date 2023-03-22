import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:upbit_autobot/model/log.dart';

import 'client/client.dart';
import 'model/balance.dart';
import 'model/strategy_item_info.dart';

class AppProvider extends ChangeNotifier {
  // TextEditingController loggerController = TextEditingController();
  var loggerText = '';
  var scrollController = ScrollController();
  var _isInitRequest = true;

  List<CoinBalance> boughtItems = new List.empty(growable: true);
  List<StrategyItemInfo> items = List.empty(growable: true);

  AppProvider._init() {}
  static AppProvider _instance = AppProvider._init();

  factory AppProvider() {
    return _instance;
  }

  Future<void> doCoinBalanceGetRequest(List<CoinBalance> buyItems) async {
    var response = await RestApiClient().requestGet("balance/all");
    var parsedResult = RestApiClient.parseResponseData(response);

    var key = 'balances';
    if (parsedResult.containsKey(key)) {
      List<dynamic> items = parsedResult[key];
      buyItems.clear();

      items.forEach((element) {
        var coinBalance = CoinBalance.fromJson(element);
        buyItems.add(coinBalance);
      });
    }

    notifyListeners();
  }

  void removeItemFromItems(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  Future<void> doItemsRequest() async {
    var response = await RestApiClient().requestGet('items');

    // data empty case
    if (response.body == 'null') {
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data['items'] == null) {
      return;
    }

    List<dynamic> sentItems = data['items'];
    items.clear();

    sentItems.forEach((el) => items.add(StrategyItemInfo.fromJson(el)));
    notifyListeners();
  }

  Future<void> doStartLoggerGetRequestCycle() async {
    if (!_isInitRequest) {
      return;
    }

    _isInitRequest = false;
    var receivePort = ReceivePort();
    await Isolate.spawn(_doUpdateLogger, receivePort.sendPort);

    receivePort.listen((message) {
      if (loggerText.length >= 10000) {
        var strings = loggerText.split('\n');
        strings = strings.sublist(2);
        loggerText = strings.join('\n');
      }

      var msgStr = message as String;
      var strs = msgStr.split('\n');

      strs = strs.map((element) => element.replaceFirst('T', ' ')).toList();
      msgStr = strs.join('\n');

      msgStr = msgStr.replaceAll('+0900', '');

      if (loggerText != '') {
        loggerText = '$loggerText$msgStr';
      } else {
        loggerText = '$msgStr';
      }

      notifyListeners();
    }, onError: (error) {
      print(error);
      receivePort.close();
    });
  }
}

Future<void> _doUpdateLogger(SendPort sendPort) async {
  var response = await RestApiClient().requestGet('logs');
  var data = RestApiClient.parseWordData(response);
  if (data.isNotEmpty) {
    sendPort.send(data);
  }

  await Timer.periodic(Duration(seconds: 2), (timer) async {
    try {
      var response = await RestApiClient().requestGet('logs');
      var data = RestApiClient.parseWordData(response);
      if (data.isNotEmpty) {
        sendPort.send(data);
      }
    } catch (_) {}
  });
}
