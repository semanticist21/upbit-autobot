import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class BetYourMoney extends StatefulWidget {
  const BetYourMoney({super.key});

  @override
  State<BetYourMoney> createState() => _BetYourMoneyState();
}

class _BetYourMoneyState extends State<BetYourMoney>
    with TickerProviderStateMixin {
  late FlutterGifController _controller = FlutterGifController(vsync: this);

  var _value = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.duration = const Duration(milliseconds: 300);
    _controller.addListener(changeValue);
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward(from: _value);
    _controller.repeat(min: 0, max: 4);

    return GifImage(
      width: double.infinity,
      height: double.infinity,
      controller: _controller,
      image: AssetImage("lib/assets/bet_your_money.gif"),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeValue() {
    _value = _controller.value;
  }
}
