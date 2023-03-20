import 'package:flutter/material.dart';
import 'dart:math' as math;

class StrategyItem extends StatefulWidget {
  StrategyItem({super.key, required this.itemKey});
  final ValueKey itemKey;

  @override
  State<StrategyItem> createState() => _StrategyItemState();
}

class _StrategyItemState extends State<StrategyItem> {
  bool _isHover = false;
  final _color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.8);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        key: widget.itemKey,
        builder: (context, constraints) {
          return SizedBox(
              key: widget.itemKey,
              width: double.infinity,
              height: 300,
              child: MouseRegion(
                  onEnter: (_) => setState(() => _isHover = true),
                  onExit: (_) => setState(() => _isHover = false),
                  child: Opacity(
                      opacity: _isHover ? 0.8 : 1.0,
                      child: Card(
                        color: _color,
                        elevation: 10,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.black45,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("마켓 ID : "),
                                    Text("BTC-KRW"),
                                  ]),
                              Divider(),
                              Expanded(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: IntrinsicHeight(
                                          child: Row(
                                        children: [
                                          Expanded(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text("볼린저 길이 : "),
                                                      Text("20")
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text("볼린저 곱 : "),
                                                      Text("2")
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text("카운트: "),
                                                      Text("3")
                                                    ]),
                                              ])),
                                          VerticalDivider(),
                                          Expanded(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text("손절 기준 : "),
                                                    Text("5%")
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text("익절 기준 : "),
                                                    Text("5%")
                                                  ]),
                                            ],
                                          ))
                                        ],
                                      ))))
                            ]),
                      ))));
        });
  }
}
