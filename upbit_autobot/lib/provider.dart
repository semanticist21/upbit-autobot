import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';

import 'client/client.dart';
import 'model/balance.dart';

class AppProvider extends ChangeNotifier {
  TextEditingController controller = TextEditingController();
  var _isInitRequest = true;

  List<CoinBalance> buyItems = new List.empty(growable: true);

  AppProvider._init() {
    controller.text = '';
  }
  static AppProvider _instance = AppProvider._init();

  factory AppProvider() {
    return _instance;
  }
  Future<void> doCoinBalanceRequest(List<CoinBalance> buyItems) async {
    var response = await RestApiClient().requestGet("balance/all");
    var parsedResult = parseResponseData(response);

    var key = 'balances';
    if (parsedResult.containsKey(key)) {
      List<dynamic> items = parsedResult[key];
      buyItems.clear();

      items.forEach((element) {
        var coinBalance = CoinBalance(
            coinName: element['coinName'],
            avgBuyPrice: element['avgBuyPrice'],
            balance: element['balance']);

        buyItems.add(coinBalance);
      });
    }

    notifyListeners();
  }

  Future<void> doLoggerRequest(TextEditingController controller) async {
    if (!_isInitRequest) {
      return;
    }
    _isInitRequest = false;
    var receivePort = ReceivePort();
    Isolate.spawn(updateLogger, receivePort.sendPort);

    receivePort.listen((message) {
      var text = controller.text;
      var newLog = '$text\n$message';
      controller.text = newLog;
      notifyListeners();
    });
  }
}

Future<void> updateLogger(SendPort sendPort) async {
  Timer.periodic(Duration(seconds: 10), (timer) async {
    var response = await RestApiClient().requestGet('logs');
    var data = parseWordData(response);
    sendPort.send(data);
  });
}
