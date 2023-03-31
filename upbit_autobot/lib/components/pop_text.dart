import 'package:flutter/cupertino.dart';
import 'package:upbit_autobot/components/coin_image.dart';

class PopUpText extends StatefulWidget {
  final String text;
  final String coinNm;

  const PopUpText({super.key, required this.text, required this.coinNm});

  @override
  _PopUpTextState createState() => _PopUpTextState();
}

class _PopUpTextState extends State<PopUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (BuildContext context, double _val, Widget? child) {
        return Opacity(
          opacity: _val,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: 25,
                  height: 25,
                  child: CoinImage(coinNm: widget.coinNm)),
              SizedBox(width: 10),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    widget.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ))
            ]),
          ),
        );
      },
    );
  }
}
