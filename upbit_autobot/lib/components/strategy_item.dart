import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/provider.dart';

class StrategyItem extends StatefulWidget {
  const StrategyItem({super.key, required this.itemKey, required this.item});
  final ValueKey itemKey;
  final StrategyItemInfo item;

  @override
  State<StrategyItem> createState() => _StrategyItemState();
}

class _StrategyItemState extends State<StrategyItem> {
  bool _isHover = false;
  final GlobalKey cardKey = GlobalKey();
  late AppProvider _provider;
  bool _isPurchased = false;

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context);
    _isPurchased = widget.item.lastBoughtTimeStamp.isEmpty ? false : true;
    return SizedBox(
        key: widget.key,
        width: double.infinity,
        height: 300,
        child: Listener(
            onPointerDown: (event) {
              if (event.kind == PointerDeviceKind.mouse &&
                  event.buttons == kSecondaryButton) {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      event.position.dx,
                      event.position.dy,
                      MediaQuery.of(context).size.width - event.position.dx,
                      MediaQuery.of(context).size.height - event.position.dy,
                    ),
                    items: [
                      PopupMenuItem(
                          child: const Center(child: Text('삭제')),
                          onTap: () {
                            var hashId = widget.item.itemId;
                            for (var i = 0; i < _provider.items.length; i++) {
                              var item = _provider.items[i];
                              if (item.itemId == hashId) {
                                _provider.removeItemFromItems(i);
                                break;
                              }
                            }
                          })
                    ]);
              }
            },
            child: _getItem()));
  }

  Widget _getItem() {
    return MouseRegion(
        onEnter: (_) => setState(() => _isHover = true),
        onExit: (_) => setState(() => _isHover = false),
        child: Opacity(
            opacity: _isHover ? 0.8 : 1.0,
            child: Card(
              color: widget.item.color.color,
              elevation: 10,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              shadowColor: Colors.black45,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('마켓 ID : '),
                  Text(widget.item.coinMarKetName),
                ]),
                const Divider(),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: IntrinsicHeight(
                            child: Row(
                          children: [
                            Expanded(
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('볼린저 길이 : '),
                                            Text(widget.item.bollingerLength
                                                .toString())
                                          ])),
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('볼린저 곱 : '),
                                            Text(widget.item.bollingerMultiplier
                                                .toString())
                                          ])),
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('카운트 : '),
                                            Text(widget.item.purchaseCount
                                                .toString())
                                          ])),
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('기준 분봉 : '),
                                            Text(widget.item.candleBaseMinute
                                                .toString())
                                          ])),
                                ])),
                            const VerticalDivider(),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text('익절 기준 : '),
                                          Text(widget.item.profitLinePercent
                                              .toString()),
                                          const Text('%'),
                                        ])),
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text('손절 기준 : '),
                                          Text(widget.item.lossLinePercent
                                              .toString()),
                                          const Text('%')
                                        ])),
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text('수량 : '),
                                          Text(widget.item.desiredBuyAmount
                                              .toString()),
                                          const Text(' 개')
                                        ])),
                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text('구매 진행 여부 : '),
                                          Checkbox(
                                              splashRadius: 0,
                                              mouseCursor:
                                                  MouseCursor.uncontrolled,
                                              value: _isPurchased,
                                              onChanged: (value) {})
                                        ])),
                              ],
                            ))
                          ],
                        ))))
              ]),
            )));
  }
}
