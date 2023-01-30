// ignore_for_file: unused_local_variable, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final List<Offset> points = [];
  final List<Offset> items = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.amber[50],
        child: items.isNotEmpty
            ? CustomPaint(
                painter: DrawPath(items),
                child: Container(),
              )
            : const SizedBox.shrink(),
      ),
      onPanUpdate: (details) {
        points.add(details.globalPosition);
      },
      onPanEnd: (details) {
        print(points.length);
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
        print(items.length);
        points.clear();
      },
    );
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
    return false;
  }
}
