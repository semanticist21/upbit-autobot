import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class Fire extends StatefulWidget {
  const Fire({super.key});

  @override
  State<Fire> createState() => _FireState();
}

class _FireState extends State<Fire> with TickerProviderStateMixin {
  late FlutterGifController _controller = FlutterGifController(vsync: this);

  var _value = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.duration = const Duration(milliseconds: 7000);
    _controller.addListener(changeValue);
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward(from: _value);
    _controller.repeat(min: 0, max: 140);

    return GifImage(
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
        controller: _controller,
        image: AssetImage("assets/fire.gif"));
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
