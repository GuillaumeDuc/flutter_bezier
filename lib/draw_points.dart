import 'dart:ui';

import 'package:flutter/material.dart';

class DrawPoints extends CustomPainter {
  List<Offset> _offsets = List.empty();
  DrawPoints(List<Offset> offsets) {
    _offsets = offsets;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color(0xff63aa65)
      ..strokeCap = StrokeCap.round //rounded points
      ..strokeWidth = 10;
    //draw points on canvas
    canvas.drawPoints(PointMode.points, _offsets, paint1);
  }

  @override
  bool shouldRepaint(DrawPoints oldDelegate) {
    return true;
  }
}
