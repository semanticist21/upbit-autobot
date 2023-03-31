import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:upbit_autobot/components/converter.dart';
import 'package:upbit_autobot/components/draggable_card.dart';
import 'package:upbit_autobot/model/sell_item.dart';

import '../client/client.dart';

class SellListView extends StatefulWidget {
  const SellListView({super.key});

  @override
  State<SellListView> createState() => _SellListViewState();
}

class _SellListViewState extends State<SellListView> {
  late List<SellItem> _sellItem = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    doSellItemRequest(_sellItem);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DraggableCard(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.65,
            child: Scaffold(
                appBar: AppBar(
                  title: Row(children: [
                    Icon(
                      Icons.sell_sharp,
                      size: 18,
                    ),
                    SizedBox(width: 15),
                    Text('판매 감시 중인 아이템 목록', style: TextStyle(fontSize: 15)),
                  ]),
                  leading: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 15),
                        IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back),
                            splashRadius: 15)
                      ]),
                ),
                body: _sellItem.length != 0
                    ? getWhenItemExists()
                    : getWhenItemEmpty()),
          ),
        ));
  }

  Widget getWhenItemEmpty() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.no_sim_sharp, size: 100),
        SizedBox(height: 10),
        Text('감시 아이템이 없습니다.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))
      ])),
    );
  }

  Widget getWhenItemExists() {
    return Container(
      padding: EdgeInsets.all(5),
      color: Color.fromRGBO(250, 250, 250, 0.95),
      child: ListView.builder(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: _sellItem.length,
          itemBuilder: (context, index) {
            return getListItem(_sellItem[index]);
          }),
    );
  }

  Widget getListItem(SellItem item) {
    var volume = item.executedVolume;
    var avgBuy = Converter.currencyFormatDouble(item.avgBuyPrice);
    var profit = Converter.currencyFormatDouble(item.profitTargetPrice);
    var loss = Converter.currencyFormatDouble(item.lossTargetPrice);

    return Card(
        color: const Color.fromRGBO(75, 75, 75, 1),
        child: Container(
          height: 150,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Row(children: [
                    Icon(FontAwesomeIcons.tag, size: 15),
                    SizedBox(width: 10),
                    Text('마켓 ID : '),
                    Text(item.coinMarketName)
                  ]),
                  Spacer(),
                  Row(children: [
                    Icon(FontAwesomeIcons.bagShopping, size: 15),
                    SizedBox(width: 10),
                    Text('매수 볼륨 : '),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 110,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text('$volume 개')))
                  ])
                ],
              ),
              Divider(),
              SizedBox(height: 10),
              Row(
                children: [
                  Row(children: [
                    Icon(Icons.linear_scale_sharp, size: 15),
                    SizedBox(width: 10),
                    Text('평단가 : '),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 220,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text('$avgBuy 원')))
                  ])
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Row(children: [
                    Icon(FontAwesomeIcons.plane, size: 15),
                    SizedBox(width: 10),
                    Text('익절 목표가 : '),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 220,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text('$profit 원')))
                  ])
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Row(children: [
                    Icon(FontAwesomeIcons.bomb, size: 15),
                    SizedBox(width: 10),
                    Text('손절 실행가 : '),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 240,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text('$loss 원')))
                  ])
                ],
              )
            ],
          ),
        ));
  }

  Future<void> doSellItemRequest(List<SellItem> sellItemList) async {
    var response = await RestApiClient().requestGet('items/sell');
    var data = await RestApiClient.parseResponseListData(response);
    data.forEach((element) {
      var sellItem = SellItem.fromJson(element);
      sellItemList.add(sellItem);
    });
    setState(() {});
  }
}
