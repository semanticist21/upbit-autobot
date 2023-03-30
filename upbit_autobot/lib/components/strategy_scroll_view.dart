import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/components/strategy_item.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';
import 'package:upbit_autobot/model/strategy_item_info_ichimoku.dart';

import '../client/client.dart';
import '../provider.dart';
import 'add_dialog_new_bollinger.dart';
import 'add_dialog_new_ichimoku.dart';

class StrategyScrollView extends StatefulWidget {
  const StrategyScrollView({super.key});

  @override
  State<StrategyScrollView> createState() => _StrategyScrollViewState();
}

class _StrategyScrollViewState extends State<StrategyScrollView> {
  late AppProvider _provider;
  bool _visible = false;
  bool _isinit = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of(context, listen: true);

    if (_isinit) {
      _provider.doBuyItemsRequest();
      _provider.startItemsManagementByWebSocket();
      _isinit = false;
    }

    return CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
            decelerationRate: ScrollDecelerationRate.fast),
        shrinkWrap: true,
        // 리스트 아이템들
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromRGBO(66, 66, 66, 0.9),
            actions: [
              Visibility(
                  visible: _visible,
                  child: const Center(
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator()),
                  )),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('화면 및 사용법 안내'),
                            content: const SizedBox(
                                width: 550,
                                height: 250,
                                child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(Icons.display_settings),
                                            SizedBox(width: 10),
                                            Text('화면 설명',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700))
                                          ]),
                                          SizedBox(height: 20),
                                          Text('해당 프로그램은 모든 기능이 무료로 제공됩니다.',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Text(
                                              '1. 왼쪽 화면에서 잔고, 구매 코인 목록 등을 확인할 수 있습니다.\n\t\t\t\t코인 구매, 매도 및 30초마다 갱신되며 버튼을 눌러 수동 갱신도 가능합니다.',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Text(
                                              '2. 오른쪽은 구매 매수 전략 아이템 및 구매 진행 여부를 나타냅니다.\n\t\t\t\t+ 버튼을 눌러 추가 후 확정하려면 오른쪽 저장을 누르면 됩니다.\n\t\t\t\t저장 전 상태로 돌리려면 리프레쉬 버튼을 누르세요.',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Text(
                                              '3. 추가된 아이템은 바로 매도/매수 감시에 들어가며 지정된 동작을 합니다.\n\t\t\t\t마지막 거래가 기준 설정된 볼린저밴드의 하단(혹은 일목선)에 닿으면\n\t\t\t\t매수합니다. \n\n\t\t\t\t구매 지정 회수 소진 및 손절/익절이 끝나면 리스트에서 자동 삭제됩니다.\n\t\t\t\t구매 중단 및 손절/익절 감지를 끝내려면 아이템 오른쪽 클릭 후 삭제하세요.',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 20),
                                          Divider(),
                                          SizedBox(height: 10),
                                          Text(
                                              '# 주의사항 : 마켓 매수/매도이므로 오더북 갭 및 익절/손절%에 주의하세요.\n\t\t\t\t가격이 너무 낮은 코인은 정해진 익절/손절%보다 높을 수 있습니다.',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Divider(),
                                          Row(children: [
                                            Icon(Icons.bar_chart),
                                            SizedBox(width: 10),
                                            Text('지표 설명',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700))
                                          ]),
                                          SizedBox(height: 10),
                                          Text(
                                              '- 볼린저 길이/곱 : 지표 기준 계산용, 하단선 계산에 사용됩니다.\n\n- 컨버젼 길이(일목) : 일목 지표에서 컨버젼/ 베이스 지표에서 사용되는\n\t\t\t(길이 내 최고점 + 길이 내 최저점) / 2 계산에 사용됩니다.\n\n- 카운트 : 구매 할 회수. 간격은 기준 분봉의 길이를 따름\n\t\t\t1분 봉의 경우 오차가 있을 수 있음.\n\t\t\t(?분 마다 볼밴 하단에 매수)\n\n- 기준 분봉 : 계산에 필요한 분봉기준, 1, 3, 5, 15, 30, 60, 240 택1\n\n- 손절/익절 기준 : 평균 매수가로부터 실현할 가격 입력. 0 입력 시 실행 안함.\n\t\t(가령, 손절 5%, 익절 0% 설정 시, -5%가 되지 않는 이상 계속 들고 있습니다.)\n\n- 수량 : 코인 수량. 매수 진행은 원화 기준이므로 실제 실행 물량과 다를 수 있음.\n\n- 진행 여부 : 구매 시 체크되며, 구매 회수 0 및 익절/손절 완료시 아이템 삭제됨.\n\t\t(익절/손절 감시 진행시에는 구매 회수 0에도 삭제되지 않음)\n\n\n 문의 : semanticist0@gmail.com',
                                              style: TextStyle(fontSize: 15)),
                                        ]))),
                            actions: [
                              MaterialButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('닫기'),
                              ),
                            ],
                          ));
                },
                icon: const Icon(Icons.question_mark_outlined, size: 23),
                splashRadius: 15,
              ),
              IconButton(
                onPressed: () => _doItemRequest(_provider),
                icon: const Icon(FontAwesomeIcons.arrowsRotate),
                iconSize: 20,
                padding: EdgeInsets.zero,
                splashRadius: 15,
              ),
              Listener(
                  onPointerDown: (event) {
                    if (event.kind == PointerDeviceKind.mouse &&
                        event.buttons == kPrimaryMouseButton) {
                      showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            event.position.dx,
                            event.position.dy,
                            MediaQuery.of(context).size.width -
                                event.position.dx,
                            MediaQuery.of(context).size.height -
                                event.position.dy,
                          ),
                          items: [
                            PopupMenuItem(
                              child: const Center(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.bar_chart_sharp),
                                    SizedBox(width: 20),
                                    Text('볼린저밴드 아이템 추가')
                                  ])),
                              onTap: () async {
                                await Future.delayed(
                                    Duration(milliseconds: 100));
                                showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Builder(builder: (context) {
                                            return const AddDialogNewBollinger();
                                          });
                                        })
                                    .then((value) =>
                                        _addNewList(_provider, value));
                              },
                            ),
                            PopupMenuItem(
                              child: const Center(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.cloud_circle_sharp),
                                    SizedBox(width: 20),
                                    Text('일목 구름대 아이템 추가')
                                  ])),
                              onTap: () async {
                                await Future.delayed(
                                    Duration(milliseconds: 100));
                                showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Builder(builder: (context) {
                                            return const AddDialogNewIchimoku();
                                          });
                                        })
                                    .then((value) =>
                                        _addNewListIchimoku(_provider, value));
                              },
                            )
                          ]);
                    }
                  },
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.plus),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    splashRadius: 15,
                  )),
              IconButton(
                onPressed: () => _saveItems(_provider),
                icon: const Icon(
                  FontAwesomeIcons.solidFloppyDisk,
                ),
                iconSize: 20,
                padding: EdgeInsets.zero,
                splashRadius: 15,
              ),
            ],
          ),
          // 아이템 있는 부분
          SliverPadding(
              padding: const EdgeInsets.all(5),
              sliver: SliverGrid.builder(
                  itemCount: _provider.items.length,
                  itemBuilder: (context, index) {
                    return StrategyItem(
                      itemKey: ValueKey(index),
                      item: _provider.items[index],
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  )))
        ]);
  }

  void _addNewList(AppProvider provider, value) {
    if (value.runtimeType != StrategyItemInfo) {
      return;
    }

    provider.items.add(value as StrategyItemInfo);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut));

    setState(() {});
  }

  void _addNewListIchimoku(AppProvider provider, value) {
    if (value.runtimeType != StrategyIchimokuItemInfo) {
      return;
    }

    provider.ichimokuItems.add(value as StrategyIchimokuItemInfo);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut));

    setState(() {});
  }

  Future<void> _saveItems(AppProvider provider) async {
    setState(() => _visible = true);

    var items = provider.items;
    var data = items.map((element) => element.toJson()).toList();
    var bollingerItemDic = {'items': data};
    var ichimokuItemDic = {'items': List.empty()};

    var result = RestApiClient.encodeData(
        {'bollingerItems': bollingerItemDic, 'ichimokuItems': ichimokuItemDic});

    await RestApiClient().requestPost('items', result);
    await provider.doBuyItemsRequest();

    setState(() => _visible = false);
  }

  Future<void> _doItemRequest(AppProvider provider) async {
    setState(() => _visible = true);
    await provider.doBuyItemsRequest();
    setState(() => _visible = false);
  }
}
