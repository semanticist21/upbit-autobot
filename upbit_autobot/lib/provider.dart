import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:upbit_autobot/customType/customList.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';

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

  MyCustomList<StrategyBollingerItemInfo> bollingerItems = MyCustomList();
  MyCustomList<StrategyIchimokuItemInfo> ichimokuItems = MyCustomList();
  // items for listview
  List<Object> itemsCollection = List.empty(growable: true);

  AppProvider._init() {
    bollingerItems.addInsertListener(_insertBollingerItemsToCollection);
    bollingerItems.addRemoveListener(_removeBollingerItemsToCollection);
    bollingerItems.addChangeListener(_changeBollingerItemsToCollection);
    bollingerItems.addCleanListener(_cleanCollection);
    ichimokuItems.addInsertListener(_insertIchimokuItemsToCollection);
    ichimokuItems.addRemoveListener(_removeIchimokuItemsToCollection);
    ichimokuItems.addChangeListener(_changeIchimokuItemsToCollection);
    ichimokuItems.addCleanListener(_cleanCollection);
  }
  static final AppProvider _instance = AppProvider._init();

  factory AppProvider() {
    return _instance;
  }

  void _insertBollingerItemsToCollection() {
    bollingerItems.last.Index = itemsCollection.length + 1;
    itemsCollection.add(bollingerItems.last);
    notifyListeners();
  }

  void _removeBollingerItemsToCollection(int index) {
    var toBeRemovedId = bollingerItems[index].itemId;
    for (var i = 0; i < itemsCollection.length; i++) {
      if (itemsCollection[i].runtimeType == StrategyBollingerItemInfo &&
          (itemsCollection[i] as StrategyBollingerItemInfo).itemId ==
              toBeRemovedId) {
        itemsCollection.removeAt(i);
        break;
      }
    }
    _reorderItemCollection();
    notifyListeners();
  }

  void _changeBollingerItemsToCollection() {
    var dic = Map<String, int>();
    for (var i = 0; i < itemsCollection.length; i++) {
      var item = itemsCollection[i];
      if (item.runtimeType == StrategyBollingerItemInfo) {
        dic[(item as StrategyBollingerItemInfo).itemId] = i;
      }
    }

    for (var bollingerItem in bollingerItems) {
      if (dic.containsKey(bollingerItem.itemId)) {
        bollingerItem.Index = dic[bollingerItem.itemId]!;
        itemsCollection[dic[bollingerItem.itemId]!] = bollingerItem;
      }
    }
    notifyListeners();
  }

  void _insertIchimokuItemsToCollection() {
    ichimokuItems.last.Index = itemsCollection.length + 1;
    itemsCollection.add(ichimokuItems.last);
    notifyListeners();
  }

  void _removeIchimokuItemsToCollection(int index) {
    var toBeRemovedId = ichimokuItems[index].itemId;
    for (var i = 0; i < itemsCollection.length; i++) {
      if (itemsCollection[i].runtimeType == StrategyIchimokuItemInfo &&
          (itemsCollection[i] as StrategyIchimokuItemInfo).itemId ==
              toBeRemovedId) {
        itemsCollection.removeAt(i);
        break;
      }
    }
    _reorderItemCollection();
    notifyListeners();
  }

  void _changeIchimokuItemsToCollection() {
    var dic = Map<String, int>();
    for (var i = 0; i < itemsCollection.length; i++) {
      var item = itemsCollection[i];
      if (item.runtimeType == StrategyIchimokuItemInfo) {
        dic[(item as StrategyIchimokuItemInfo).itemId] = i;
      }
    }

    for (var ichimokuItem in ichimokuItems) {
      if (dic.containsKey(ichimokuItem.itemId)) {
        ichimokuItem.Index = dic[ichimokuItem.itemId]!;
        itemsCollection[dic[ichimokuItem.itemId]!] = ichimokuItem;
      }
    }
    notifyListeners();
  }

  void _reorderItemCollection() {
    for (var i = 0; i < itemsCollection.length; i++) {
      if (itemsCollection[i].runtimeType == StrategyBollingerItemInfo) {
        (itemsCollection[i] as StrategyBollingerItemInfo).Index = i;
      }
      if (itemsCollection[i].runtimeType == StrategyIchimokuItemInfo) {
        (itemsCollection[i] as StrategyIchimokuItemInfo).Index = i;
      }
    }
  }

  void _cleanCollection() {
    if (bollingerItems.length == 0) {
      for (var i = 0; i < itemsCollection.length; i++) {
        print(itemsCollection.length);
        if (itemsCollection[i].runtimeType == StrategyBollingerItemInfo) {
          itemsCollection.removeAt(i);
          i--;
        }
      }
    }

    if (ichimokuItems.length == 0) {
      for (var i = 0; i < itemsCollection.length; i++) {
        if (itemsCollection[i].runtimeType == StrategyIchimokuItemInfo) {
          itemsCollection.removeAt(i);
          i--;
        }
      }
    }
  }

  Future<void> doKrwBalanceRequest() async {
    var result = await RestApiClient().requestGet("balance/krw");

    Map<String, dynamic> parsedResult =
        await RestApiClient.parseResponseData(result);

    var key = 'balance';
    if (parsedResult.containsKey(key)) {
      krwBalance = parsedResult[key];
      notifyListeners();
      return;
    }
  }

  Future<void> doCoinBalanceGetRequest(List<CoinBalance> boughtItems) async {
    var response = await RestApiClient().requestGet("balance/all");
    var parsedResult = await RestApiClient.parseResponseData(response);

    var key = 'balances';
    if (parsedResult.containsKey(key)) {
      List<dynamic> items = parsedResult[key];
      boughtItems.clear();

      for (var element in items) {
        var coinBalance = CoinBalance.fromJson(element);
        boughtItems.add(coinBalance);
      }

      boughtItems.sort((a, b) => _checkorder(b, a));
      notifyListeners();
    }
  }

  void removeItemFromItems(int index) {
    bollingerItems.removeAt(index);
    notifyListeners();
  }

  Future<void> doBuyItemsRequest() async {
    var response = await RestApiClient().requestGet('items');
    var bodyStr = 'null';
    if (response != null) {
      bodyStr = await response.transform(utf8.decoder).join();
    }

    // data empty case
    if (bodyStr == 'null') {
      return;
    }

    Map<String, dynamic> data = jsonDecode(bodyStr);
    if (data['bollingerItems'] != null &&
        data['bollingerItems']['items'] != null) {
      List<dynamic> sentItems = data['bollingerItems']['items'];
      bollingerItems.clear();

      for (var el in sentItems) {
        bollingerItems.add(StrategyBollingerItemInfo.fromJson(el));
      }
    }

    if (data['ichimokuItems'] != null &&
        data['ichimokuItems']['items'] != null) {
      List<dynamic> sentItems = data['ichimokuItems']['items'];
      ichimokuItems.clear();

      for (var el in sentItems) {
        ichimokuItems.add(StrategyIchimokuItemInfo.fromJson(el));
      }
    }

    _reorderItemCollection();
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
          boughtItems.sort((a, b) => _checkorder(b, a));
        }
      }

      if (data.containsKey('item')) {
        var sentItem = StrategyBollingerItemInfo.fromJson(data['item']);
        if (sentItem.itemId != '') {
          for (var i = 0; i < bollingerItems.length; i++) {
            if (bollingerItems[i].itemId == sentItem.itemId) {
              bollingerItems[i] = sentItem;
              break;
            }
          }
        }
      }

      if (data.containsKey('Ichimokuitems')) {
        var sentItem = StrategyIchimokuItemInfo.fromJson(data['ichimokuItem']);
        if (sentItem.itemId != '') {
          for (var i = 0; i < bollingerItems.length; i++) {
            if (ichimokuItems[i].itemId == sentItem.itemId) {
              ichimokuItems[i] = sentItem;
              break;
            }
          }
        }
      }

      if (data.containsKey('deleteItemId') && data['deleteItemId'] != '') {
        for (var i = 0; i < bollingerItems.length; i++) {
          if (bollingerItems[i].itemId == data['deleteItemId']) {
            bollingerItems.removeAt(i);
            break;
          }
        }

        for (var i = 0; i < ichimokuItems.length; i++) {
          if (ichimokuItems[i].itemId == data['deleteItemId']) {
            ichimokuItems.removeAt(i);
            break;
          }
        }
      }

      _reorderItemCollection();
      notifyListeners();
    });
  }

  static int _checkorder(CoinBalance a, CoinBalance b) {
    var aValue = double.parse(a.avgBuyPrice) * double.parse(a.balance);
    var bValue = double.parse(b.avgBuyPrice) * double.parse(b.balance);
    return aValue.compareTo(bValue);
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

  static Future<void> _updateLogger(SendPort sendPort) async {
    var response = await RestApiClient().requestGet('logs');
    var data = await RestApiClient.parseWordData(response);
    if (data.isNotEmpty) {
      sendPort.send(data);
    }

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        var response = await RestApiClient().requestGet('logs');
        var data = await RestApiClient.parseWordData(response);
        if (data.isNotEmpty) {
          sendPort.send(data);
        }
      } catch (_) {}
    });
  }
}
