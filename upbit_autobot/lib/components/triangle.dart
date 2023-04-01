import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.yellow;
    Path path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(TrianglePainter oldDelegate) => false;
}

class TriangleDiagram extends StatelessWidget {
  const TriangleDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 25,
      child: CustomPaint(
        painter: TrianglePainter(),
      ),
    );
  }
}
