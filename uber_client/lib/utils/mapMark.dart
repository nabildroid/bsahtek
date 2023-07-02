// singalaton class
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMark {
  Map<String, BitmapDescriptor> draws = {};

  static final MapMark instance = MapMark._internal();

  factory MapMark() {
    return instance;
  }

  MapMark._internal();

  Future<BitmapDescriptor> minNum(int n) async {
    int roof = 0;

    if (n < 10) {
      roof = 5;
    } else if (n < 50) {
      roof = 10;
    } else if (n < 100) {
      roof = 50;
    }

    if (!draws.containsKey("g_$roof")) {
      final bytes = await _createCanvas([
        _drawDefaultCircle,
        (canvas, width) => _drawDefaultCircleText("$roof+", canvas, width),
      ]);
      draws["g_$roof"] = BitmapDescriptor.fromBytes(bytes);
    }

    return draws["g_$roof"]!;
  }

  void _drawDefaultCircleText(String text, Canvas canvas, int width) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: width + 0.0,
    );

    final offset = Offset(width / 2 - textPainter.size.width / 2,
        width / 2 - textPainter.size.height / 2);

    textPainter.paint(canvas, offset);
  }

  void _drawDefaultCircle(Canvas canvas, int width) {
    final paint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = Colors.white.withOpacity(.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final center = Offset(width / 2, width / 2);

    canvas.drawCircle(center, width / 2 - 8, paint);

    canvas.drawArc(Rect.fromCircle(center: center, radius: width / 2 - 8), 0,
        2 * pi, false, paintBorder);
  }

  Future<Uint8List> _createCanvas(
    List<Function(Canvas, int)> draws, {
    int width = 100,
  }) async {
    final r = PictureRecorder();

    Canvas canvas = Canvas(r);
    for (var draw in draws) {
      draw(canvas, width);
    }

    final p = r.endRecording();
    final i = await p.toImage(width, width);
    final b = await i.toByteData(format: ImageByteFormat.png);
    return b!.buffer.asUint8List();
  }
}
