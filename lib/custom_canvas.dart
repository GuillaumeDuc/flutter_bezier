import 'package:flutter/material.dart';
import 'draw_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomCanvas extends StatefulWidget {
  Function _setPoints = () => {};
  List<Offset> _offsets = [];

  CustomCanvas(Function setPoints, List<Offset> offsets, {Key? key})
      : super(key: key) {
    _setPoints = setPoints;
    _offsets = offsets;
  }

  @override
  _CustomCanvasState createState() => _CustomCanvasState();
}

class _CustomCanvasState extends State<CustomCanvas> {
  addPoint(BuildContext context, TapDownDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    List<Offset> off = widget._offsets;
    off.add(localOffset);
    widget._setPoints(off);
  }

  Offset getCasteljauPoint(double t, List<Offset> points) {
    List<Offset> beta = List.from(points);
    int n = beta.length;
    for (int j = 1; j < n; j++) {
      for (int k = 0; k < n - j; k++) {
        beta[k] = beta[k] * (1 - t) + beta[k + 1] * t;
      }
    }
    return beta[0];
  }

  onClickDrawLine() {
    List<Offset> bezierList = [];
    for (double t = 0; t <= 1; t += 0.01) {
      Offset tmp = getCasteljauPoint(t, widget._offsets);
      bezierList.add(tmp);
    }
    widget._setPoints(bezierList);
  }

  onClickClear() {
    List<Offset> list = [];
    widget._setPoints(list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      const Text(
        'Canvas',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, height: 2),
      ),
      Flexible(
          child: Builder(
        builder: (BuildContext context) => GestureDetector(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 4,
                ),
              ),
              child: RepaintBoundary(
                child: CustomPaint(
                  isComplex: true,
                  willChange: false,
                  painter: DrawPoints(widget._offsets),
                ),
              ),
            ),
          ),
          onTapDown: (details) => {addPoint(context, details)},
        ),
      )),
      Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: onClickDrawLine,
          child: const Text("Draw Line"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: onClickClear,
          child: const Text("Clear"),
        ),
      ),
    ]);
  }
}
