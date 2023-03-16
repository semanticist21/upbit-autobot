import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../animation/wave.dart';
import '../items/items_buy_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hover = false;
  var _logController = TextEditingController();

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
                                        onEnter: (_) => setState(() {
                                              _hover = true;
                                            }),
                                        onExit: (_) => setState(() {
                                              _hover = false;
                                            }),
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
                                            child: Stack(children: [
                                              const Opacity(
                                                  opacity: 0.4, child: Wave()),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 10, 0),
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
                                                              FontAwesomeIcons
                                                                  .wonSign,
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
                                                            padding:
                                                                EdgeInsets.zero,
                                                            iconSize: 15,
                                                            splashRadius: 15.0,
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      const SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 45,
                                                          child: FittedBox(
                                                              fit: BoxFit
                                                                  .contain,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    '231,411,300',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    'KRW',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  )
                                                                ],
                                                              ))),
                                                    ],
                                                  ))
                                            ]))),
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
                                        // 위에 전략 부분분
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
                                                      SliverPadding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          sliver: SliverGrid(
                                                              delegate:
                                                                  SliverChildBuilderDelegate(
                                                                      (context,
                                                                          index) {
                                                                return Card(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          62,
                                                                          39,
                                                                          35,
                                                                          0.8),
                                                                  elevation: 10,
                                                                  shape: ContinuousRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15)),
                                                                  shadowColor:
                                                                      Colors
                                                                          .black45,
                                                                  child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SizedBox(
                                                                            height:
                                                                                5),
                                                                        Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text("마켓 ID : "),
                                                                              Text("BTC-KRW"),
                                                                            ]),
                                                                        Divider(),
                                                                        Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 5),
                                                                            child: IntrinsicHeight(
                                                                                child: Row(
                                                                              children: [
                                                                                Expanded(
                                                                                    flex: 1,
                                                                                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                      SizedBox(height: 5),
                                                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                        Text("볼린저 길이 : "),
                                                                                        Text("20")
                                                                                      ]),
                                                                                      SizedBox(height: 10),
                                                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                        Text("볼린저 곱 : "),
                                                                                        Text("2")
                                                                                      ]),
                                                                                      SizedBox(height: 10),
                                                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                        Text("카운트: "),
                                                                                        Text("3")
                                                                                      ]),
                                                                                    ])),
                                                                                VerticalDivider(),
                                                                                Expanded(
                                                                                    flex: 1,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        SizedBox(height: 5),
                                                                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                          Text("손절 기준 : "),
                                                                                          Text("5%")
                                                                                        ]),
                                                                                        SizedBox(height: 10),
                                                                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                          Text("익절 기준 : "),
                                                                                          Text("5%")
                                                                                        ]),
                                                                                      ],
                                                                                    )),
                                                                              ],
                                                                            )))
                                                                      ]),
                                                                );
                                                              }, childCount: 1),
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
