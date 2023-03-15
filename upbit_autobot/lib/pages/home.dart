import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    width: 300,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            59, 130, 246, 0.8),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  Icon(
                                                    FontAwesomeIcons.wonSign,
                                                    size: 15,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text("나의 잔고")
                                                ]),
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
                                            const SizedBox(height: 10),
                                            const SizedBox(
                                                width: double.infinity,
                                                height: 30,
                                                child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '2,411,300',
                                                          style: TextStyle(
                                                              fontSize: 25),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'KRW',
                                                          style: TextStyle(
                                                              fontSize: 25),
                                                        )
                                                      ],
                                                    ))),
                                          ],
                                        ))),
                                SizedBox(height: 15),
                                Container(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 300,
                                  height: 400,
                                )
                              ],
                            ))))),
            Expanded(
                flex: 2,
                child:
                    Container(color: Theme.of(context).colorScheme.onPrimary))
          ],
        ));
  }
}
