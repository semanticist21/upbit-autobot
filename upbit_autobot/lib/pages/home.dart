import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../animation/wave.dart';
import '../components/balance_monitor.dart';
import '../components/items_buy_list.dart';
import '../components/items_strategy.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _logController = TextEditingController();

  bool _hover = false;
  var _balance = '0';

  @override
  Widget build(BuildContext context) {
    _logController.text =
        '[18:13:10] TRX 코인 매수 완료.\n[18:13:10] TRX 코인 매수량 13000 개.';
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    color: Theme.of(context).colorScheme.background,
                    height: double.infinity,
                    width: double.infinity,
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: SingleChildScrollView(
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
                                    MouseRegion(
                                        onEnter: (_) =>
                                            setState(() => _hover = true),
                                        onExit: (_) =>
                                            setState(() => _hover = false),
                                        child: Container(
                                            width: 300,
                                            height: 120,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                                color: _hover
                                                    ? const Color.fromRGBO(
                                                        59, 130, 246, 0.5)
                                                    : const Color.fromRGBO(
                                                        59, 130, 246, 0.8),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: BalanceMonitor())),
                                    const SizedBox(height: 15),
                                    // 아래 시작 부분
                                    Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(97, 97, 97, 0.8),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        width: 300,
                                        height: 400,
                                        child: ScrollConfiguration(
                                            behavior:
                                                ScrollConfiguration.of(context)
                                                    .copyWith(scrollbars: true),
                                            child: CustomScrollView(
                                                physics: BouncingScrollPhysics(
                                                    decelerationRate:
                                                        ScrollDecelerationRate
                                                            .fast),
                                                shrinkWrap: true,
                                                clipBehavior: Clip.antiAlias,
                                                slivers: [
                                                  SliverAppBar(
                                                    floating: true,
                                                    stretch: true,
                                                    expandedHeight: 60,
                                                    automaticallyImplyLeading:
                                                        false,
                                                    flexibleSpace:
                                                        FlexibleSpaceBar(
                                                      title: Container(
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .coins,
                                                              size: 15,
                                                            ),
                                                            SizedBox(width: 15),
                                                            Text(
                                                              '나의 구매 목록',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            IconButton(
                                                              icon: Icon(
                                                                  FontAwesomeIcons
                                                                      .arrowRotateLeft),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              iconSize: 15,
                                                              splashRadius:
                                                                  15.0,
                                                              onPressed: () {},
                                                            )
                                                          ])),
                                                      titlePadding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 20, 5, 20),
                                                      expandedTitleScale: 1.1,
                                                    ),
                                                    shape:
                                                        ContinuousRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                  ),
                                                  BuyListItem(),
                                                  SliverToBoxAdapter(
                                                      child:
                                                          SizedBox(height: 20))
                                                ])))
                                  ])),
                        )))),
            // 오른쪽 화면
            Expanded(
                flex: 2,
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color.fromRGBO(41, 41, 41, 0.8),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: true),
                          child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                  decelerationRate:
                                      ScrollDecelerationRate.fast),
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth,
                                    maxHeight: constraints.maxHeight,
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(children: [
                                        // 위에 전략 부분
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: CustomScrollView(
                                                    physics: BouncingScrollPhysics(
                                                        decelerationRate:
                                                            ScrollDecelerationRate
                                                                .fast),
                                                    shrinkWrap: true,
                                                    // 리스트 아이템들
                                                    slivers: [
                                                      SliverAppBar(
                                                        pinned: true,
                                                        automaticallyImplyLeading:
                                                            false,
                                                        backgroundColor:
                                                            Color.fromRGBO(66,
                                                                66, 66, 0.9),
                                                        actions: [
                                                          IconButton(
                                                            onPressed: () {},
                                                            icon: Icon(
                                                                FontAwesomeIcons
                                                                    .plus),
                                                            iconSize: 20,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            splashRadius: 15,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {},
                                                            icon: Icon(
                                                              FontAwesomeIcons
                                                                  .solidFloppyDisk,
                                                            ),
                                                            iconSize: 20,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            splashRadius: 15,
                                                          ),
                                                        ],
                                                      ),
                                                      // 아이템 있는 부분
                                                      SliverPadding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          sliver: SliverGrid
                                                              .builder(
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return StrategyItems(
                                                                      itemKey:
                                                                          ValueKey(
                                                                              index),
                                                                    );
                                                                  },
                                                                  gridDelegate:
                                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                                    crossAxisCount:
                                                                        2,
                                                                    childAspectRatio:
                                                                        2,
                                                                    crossAxisSpacing:
                                                                        5,
                                                                    mainAxisSpacing:
                                                                        5,
                                                                  )))
                                                    ]))),
                                        SizedBox(height: 10),
                                        // 로그 부분
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Column(children: [
                                                  Container(
                                                      height: 30,
                                                      color: Color.fromRGBO(
                                                          66, 66, 66, 0.9),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                FontAwesomeIcons
                                                                    .clockRotateLeft,
                                                                size: 15),
                                                            SizedBox(width: 15),
                                                            Text("로그",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500))
                                                          ])),
                                                  Expanded(
                                                      child:
                                                          SingleChildScrollView(
                                                    physics: BouncingScrollPhysics(
                                                        parent:
                                                            AlwaysScrollableScrollPhysics()),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        child: TextFormField(
                                                          controller:
                                                              _logController,
                                                          enabled: true,
                                                          maxLines: null,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                        )),
                                                  ))
                                                ])))
                                      ])))));
                    })))
          ],
        ));
  }
}
