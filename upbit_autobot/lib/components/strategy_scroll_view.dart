import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/components/strategy_item.dart';
import 'package:upbit_autobot/model/strategy_item_info.dart';

import '../client/client.dart';
import '../provider.dart';
import 'add_dialog.dart';

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
                onPressed: () => _doItemRequest(_provider),
                icon: const Icon(FontAwesomeIcons.arrowsRotate),
                iconSize: 20,
                padding: EdgeInsets.zero,
                splashRadius: 15,
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Builder(builder: (context) {
                          return const AddDialog();
                        });
                      }).then((value) => _addnewList(_provider, value));
                },
                icon: const Icon(FontAwesomeIcons.plus),
                iconSize: 20,
                padding: EdgeInsets.zero,
                splashRadius: 15,
              ),
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

  void _addnewList(AppProvider provider, value) {
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

  Future<void> _saveItems(AppProvider provider) async {
    setState(() => _visible = true);

    var items = provider.items;
    var data = items.map((element) => element.toJson()).toList();
    var result = RestApiClient.encodeData({'items': data});

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
