import 'package:flutter/material.dart';
import 'package:upbit_autobot/components/coin_image.dart';
import 'package:upbit_autobot/model/balance.dart';

class BuyItem extends StatefulWidget {
  const BuyItem({super.key, required this.coinBalance});
  final CoinBalance coinBalance;

  @override
  State<BuyItem> createState() => _BuyItemState();
}

class _BuyItemState extends State<BuyItem> {
  var _isHover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
        child: MouseRegion(
            onEnter: (details) => setState(() => _isHover = true),
            onExit: (details) => setState(() => _isHover = false),
            child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: _isHover
                        ? Color.fromRGBO(60, 60, 60, 0.4)
                        : Color.fromRGBO(60, 60, 60, 0.6),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color.fromRGBO(36, 36, 36, 0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 8,
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 15),
                                  Container(
                                      width: 20,
                                      height: 20,
                                      child: CoinImage(
                                          coinNm: widget.coinBalance.coinName
                                              .toLowerCase())),
                                  SizedBox(width: 15),
                                  SizedBox(
                                      height: 25,
                                      width: 40,
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            widget.coinBalance.coinName,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          )))
                                ]))),
                    Expanded(
                        flex: 10,
                        child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  '평균 매수가',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(widget.coinBalance.avgBuyPrice),
                                Divider(),
                                Text('수량', style: TextStyle(fontSize: 12)),
                                Text(widget.coinBalance.balance),
                              ],
                            )))
                  ],
                ))));
  }
}
