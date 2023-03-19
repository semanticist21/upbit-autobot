import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RefreshButton extends StatefulWidget {
  RefreshButton({super.key, required this.callback});

  final Future<void> Function() callback;

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 1.0, end: 0.0).animate(_controller),
      filterQuality: FilterQuality.high,
      child: IconButton(
        onPressed: spinButton,
        icon: const Icon(FontAwesomeIcons.arrowRotateLeft),
        padding: EdgeInsets.zero,
        iconSize: 15,
        splashRadius: 15.0,
      ),
    );
  }

  Future<void> spinButton() async {
    if (_isSpinning) {
      return;
    }

    _isSpinning = true;
    _controller.forward();
    _controller.repeat();
    await widget.callback();
    _controller.reset();
    _isSpinning = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
