import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/provider.dart';

import 'buy_item.dart';

class BuyItemList extends StatefulWidget {
  BuyItemList({super.key});
  final _BuyItemListState _state = _BuyItemListState();

  @override
  State<BuyItemList> createState() => _state;
}

class _BuyItemListState extends State<BuyItemList> {
  AppProvider _provider = AppProvider();
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppProvider>(context, listen: true);
    if (_isInit) {
      _provider.doCoinBalanceGetRequest(_provider.boughtItems);
      _isInit = false;
    }

    return SliverList.builder(
        itemCount: _provider.boughtItems.length,
        itemBuilder: (context, index) {
          return BuyItem(coinBalance: _provider.boughtItems.elementAt(index));
        });
  }
}
