import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../animation/wave.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Row(
          children: [
            Expanded(
                flex: 1,
                child: SizedBox(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast,
                          parent: AlwaysScrollableScrollPhysics()),
                      child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //위의 부분
                                Container(
                                    width: 300,
                                    height: 120,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            59, 130, 246, 0.8),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Stack(children: [
                                      const Opacity(
                                          opacity: 0.4, child: Wave()),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(children: [
                                                    SizedBox(width: 10),
                                                    Icon(
                                                      FontAwesomeIcons.wonSign,
                                                      size: 15,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text("업비트 나의 현금 잔고")
                                                  ]),
                                                  Spacer(),
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                        FontAwesomeIcons
                                                            .arrowRotateLeft),
                                                    padding: EdgeInsets.zero,
                                                    iconSize: 15,
                                                    splashRadius: 15.0,
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              const SizedBox(
                                                  width: double.infinity,
                                                  height: 45,
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(width: 10),
                                                          Text(
                                                            '2,411,300',
                                                            style: TextStyle(
                                                                fontSize: 25),
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            'KRW',
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          )
                                                        ],
                                                      ))),
                                            ],
                                          ))
                                    ])),
                                const SizedBox(height: 15),
                                // 아래 시작 부분
                                Container(
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(97, 97, 97, 0.8),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: 300,
                                    height: 550,
                                    child: CustomScrollView(
                                        physics: BouncingScrollPhysics(
                                            decelerationRate:
                                                ScrollDecelerationRate.fast),
                                        shrinkWrap: true,
                                        clipBehavior: Clip.antiAlias,
                                        slivers: [
                                          SliverAppBar(
                                            floating: true,
                                            stretch: true,
                                            expandedHeight: 60,
                                            automaticallyImplyLeading: false,
                                            flexibleSpace: FlexibleSpaceBar(
                                              title: Container(
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                    Icon(
                                                      FontAwesomeIcons.coins,
                                                      size: 15,
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      '나의 구매 목록',
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: Icon(
                                                          FontAwesomeIcons
                                                              .arrowRotateLeft),
                                                      padding: EdgeInsets.zero,
                                                      iconSize: 15,
                                                      splashRadius: 15.0,
                                                      onPressed: () {},
                                                    )
                                                  ])),
                                              titlePadding: EdgeInsets.fromLTRB(
                                                  20, 20, 5, 20),
                                              expandedTitleScale: 1.1,
                                            ),
                                            shape: ContinuousRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          _getSilverPaddingItem(),
                                          _getSilverPaddingItem(),
                                          _getSilverPaddingItem(),
                                          _getSilverPaddingItem(),
                                          _getSilverPaddingItem(),
                                          SliverToBoxAdapter(
                                              child: SizedBox(height: 20))
                                        ]))
                              ])),
                    ))),
            Expanded(
                flex: 2,
                child:
                    Container(color: Theme.of(context).colorScheme.onPrimary))
          ],
        ));
  }

  SliverPadding _getSilverPaddingItem() {
    return SliverPadding(
        padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
        sliver: SliverToBoxAdapter(
            child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
              color: Color.fromRGBO(60, 60, 60, 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color.fromRGBO(36, 36, 36, 0.3))),
        )));
  }
}
