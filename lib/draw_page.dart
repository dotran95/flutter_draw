// ignore_for_file: unused_local_variable, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';

enum DrawStatus { ready, drawing, drag }

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final List<Offset> points = [];
  final List<Offset> items = [];
  DrawStatus status = DrawStatus.ready;
  double dragDx = 0;
  double dragDy = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[50],
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: Container(
                  color: Colors.amber[50],
                  height: double.infinity,
                  width: double.infinity,
                  child: items.isNotEmpty
                      ? CustomPaint(
                          foregroundPainter: DrawPath(items),
                          child: Container(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  switch (status) {
                    case DrawStatus.ready:
                      setState(() {
                        status = DrawStatus.drawing;
                      });
                      break;
                    default:
                      setState(() {
                        points.clear();
                        items.clear();
                        status = DrawStatus.ready;
                      });
                  }
                },
                child: Center(child: Text(status == DrawStatus.ready ? 'Draw' : 'Cancel')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onPanStart(DragStartDetails details) {
    switch (status) {
      case DrawStatus.drag:
        setState(() {
          dragDx = details.localPosition.dx;
          dragDy = details.localPosition.dy;
        });
        break;
      default:
    }
  }

  onPanUpdate(DragUpdateDetails details) {
    switch (status) {
      case DrawStatus.drawing:
        onDrawing(details.globalPosition);
        break;
      case DrawStatus.drag:
        setState(() {
          dragDx += details.delta.dx;
          dragDy += details.delta.dy;
          final index = items.indexWhere((element) => isInObject(element, dragDx, dragDy));
          if (index > -1) {
            items[index] = Offset(dragDx, dragDy);
          }
        });
        break;
      default:
    }
  }

  onPanEnd(DragEndDetails details) {
    switch (status) {
      case DrawStatus.drawing:
        onDrawEnded();
        setState(() {
          status = DrawStatus.drag;
        });
        break;
      case DrawStatus.drag:
        print(items.toString());
        break;
      default:
    }
  }

  onDrawing(Offset position) {
    points.add(position);
  }

  onDrawEnded() {
    final newPoints = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      if (i >= (points.length - 1)) {
        break;
      }

      if (newPoints.isEmpty) {
        newPoints.add(points[i]);
        continue;
      }
      final currentPoint = newPoints.last;
      final nextPoint = points[i + 1];
      final distance = (nextPoint - currentPoint).distance;

      print('Distan: $distance');

      if (distance >= 50) {
        newPoints.add(nextPoint);
      }
      setState(() {
        items.clear();
        items.addAll(newPoints);
      });
    }
    points.clear();
  }
}

class DrawPath extends CustomPainter {
  final List<Offset> points;

  DrawPath(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    List<Path> nodes = [];

    var paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    var linePaint = Paint()
      ..color = Colors.teal.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      var nodePath = Path();
      nodePath.addRect(Rect.fromCenter(center: point, width: 10, height: 10));
      nodes.add(nodePath);
      nodePath.close();

      final Offset previusPoint;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        continue;
      }
      previusPoint = points[i - 1];

      path.lineTo(point.dx, point.dy);

      if ((i + 1) == points.length) {
        path.lineTo(points[0].dx, points[0].dy);
      }
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, linePaint);

    for (var node in nodes) {
      canvas.drawPath(node, paint..color = Colors.black);
      node.close();
    }
    path.close();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

bool isInObject(Offset data, double dx, double dy) {
  Path tempPath = Path()..addOval(Rect.fromCenter(center: data, width: 25, height: 25));
  return tempPath.contains(Offset(dx, dy));
}
