import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  DraggableWidget({super.key, required this.childWidget});
  final Widget childWidget;

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = Offset(100, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: GestureDetector(
            onPanUpdate: (details) => position = position + details.delta,
            child: widget.childWidget));
  }
}
