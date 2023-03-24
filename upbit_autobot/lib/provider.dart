import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:upbit_autobot/components/converter.dart';

import 'client/client.dart';
import 'model/balance.dart';
import 'model/strategy_item_info.dart';

class AppProvider extends ChangeNotifier {
  // TextEditingController loggerController = TextEditingController();
  var loggerText = '';
  var scrollController = ScrollController();
  var _isInitRequest = true;

  var krwBalance = '0';

  List<CoinBalance> boughtItems = List.empty(growable: true);
  List<StrategyItemInfo> items = List.empty(growable: true);

  AppProvider._init();
  static final AppProvider _instance = AppProvider._init();

  factory AppProvider() {
    return _instance;
  }

  Future<void> doKrwBalanceRequest() async {
    var result = await RestApiClient().requestGet("balance/krw");

    Map<String, dynamic> parsedResult = RestApiClient.parseResponseData(result);

    var key = 'balance';
    if (parsedResult.containsKey(key)) {
      krwBalance = parsedResult[key];
      notifyListeners();
      return;
    }
  }

  Future<void> doCoinBalanceGetRequest(List<CoinBalance> boughtItems) async {
    var response = await RestApiClient().requestGet("balance/all");
    var parsedResult = RestApiClient.parseResponseData(response);

    var key = 'balances';
    if (parsedResult.containsKey(key)) {
      List<dynamic> items = parsedResult[key];
      boughtItems.clear();

      for (var element in items) {
        var coinBalance = CoinBalance.fromJson(element);
        boughtItems.add(coinBalance);
      }

      boughtItems.sort((a, b) {
        var aValue = double.parse(a.avgBuyPrice) * double.parse(a.balance);
        var bValue = double.parse(b.avgBuyPrice) * double.parse(b.balance);
        return aValue.compareTo(bValue);
      });
      notifyListeners();
    }
  }

  void removeItemFromItems(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  Future<void> doBuyItemsRequest() async {
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

    for (var el in sentItems) {
      items.add(StrategyItemInfo.fromJson(el));
    }
    notifyListeners();
  }

  Future<void> startLoggerGetByWebSocket() async {
    var socket = await RestApiClient().doConnectToWebSocket('socket/logs');
    socket.listen((event) {
      if (event.runtimeType == String) {
        // when logger too long.
        if (loggerText.length >= 30000) {
          loggerText = '로그 3만자 이상 초기화 됐습니다.';
        }

        var msgStr = event as String;
        var strs = msgStr.split('\n');

        strs = strs.map((element) => element.replaceFirst('T', ' ')).toList();
        msgStr = strs.join('\n');
        msgStr = msgStr.replaceAll('+0900', '');
        loggerText = '$loggerText$msgStr';
      }
      notifyListeners();
    });
  }

  Future<void> startItemsManagementByWebSocket() async {
    var socket = await RestApiClient().doConnectToWebSocket('socket/items');
    socket.listen((event) {
      if (event.runtimeType != String) {
        return;
      }

      var data = json.decode(event) as Map<String, dynamic>;

      if (data.containsKey('krwBalance') &&
          data['krwBalance']['balance'] != '') {
        krwBalance = data['krwBalance']['balance'];
      }

      if (data.containsKey('coinBalance') &&
          data['coinBalance']['balances'] != null) {
        List<dynamic> items = data['coinBalance']['balances'];
        boughtItems.clear();
        for (var element in items) {
          var coinBalance = CoinBalance.fromJson(element);
          boughtItems.add(coinBalance);

          notifyListeners();
        }
      }

      if (data.containsKey('item')) {
        var sentItem = StrategyItemInfo.fromJson(data['item']);
        if (sentItem.itemId != '') {
          for (var i = 0; i < items.length; i++) {
            if (items[i].itemId == sentItem.itemId) {
              items[i] = sentItem;
              break;
            }
          }
        }
      }

      if (data.containsKey('DeletedItemId') && data['DeletedItemId'] != '') {
        for (var i = 0; i < items.length; i++) {
          if (items[i].itemId == data['DeletedItemId']) {
            items.removeAt(i);
            break;
          }
        }
      }

      notifyListeners();
    });
  }

// no more use
  Future<void> startLoggerGetRequestCycle() async {
    if (!_isInitRequest) {
      return;
    }
    _isInitRequest = false;
    var receivePort = ReceivePort();
    await Isolate.spawn(_updateLogger, receivePort.sendPort);

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
        loggerText = msgStr;
      }

      notifyListeners();
    }, onError: (error) {
      receivePort.close();
    });
  }
}

Future<void> _updateLogger(SendPort sendPort) async {
  var response = await RestApiClient().requestGet('logs');
  var data = RestApiClient.parseWordData(response);
  if (data.isNotEmpty) {
    sendPort.send(data);
  }

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    try {
      var response = await RestApiClient().requestGet('logs');
      var data = RestApiClient.parseWordData(response);
      if (data.isNotEmpty) {
        sendPort.send(data);
      }
    } catch (_) {}
  });
}
