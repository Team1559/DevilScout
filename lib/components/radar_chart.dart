import 'dart:math' show cos, sin, pi, min;

import 'package:flutter/material.dart';

class RadarChartFeature {
  final double value;
  final String? label;

  const RadarChartFeature({
    required this.value,
    this.label,
  });
}

class RadarChart extends StatelessWidget {
  final List<RadarChartFeature> features;
  final double max;

  final TextStyle? labelTextStyle;
  final double tickSize;

  final Color axisColor;
  final Color tickColor;
  final Color graphColor;
  final Color graphStrokeColor;
  final double graphStrokeWidth;
  final double tickWidth;

  const RadarChart({
    super.key,
    required this.max,
    required this.features,
    this.graphColor = Colors.green,
    this.graphStrokeColor = Colors.greenAccent,
    this.graphStrokeWidth = 4,
    this.tickWidth = 1,
    this.tickSize = 4,
    this.labelTextStyle,
    this.axisColor = Colors.transparent,
    this.tickColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadarChartPainter(widget: this),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  static const halfPi = pi / 2;
  static const scaleFactor = 0.8;

  final RadarChart widget;

  RadarChartPainter({super.repaint, required this.widget});

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(center.dx, center.dy);
    double scale = radius / widget.max;
    double angle = 2 * pi / widget.features.length;

    _drawAxis(canvas, center, radius * scaleFactor);
    _drawTicks(canvas, center, radius * scaleFactor, scale * scaleFactor);
    _drawGraph(
        canvas, center, radius * scaleFactor, scale * scaleFactor, angle);
    _drawLabels(canvas, center, radius);
  }

  void _drawAxis(Canvas canvas, Offset center, double radius) {
    double angle = 2 * pi / widget.features.length;

    widget.features.asMap().forEach((index, feature) {
      double xAngle = cos(angle * index - halfPi);
      double yAngle = sin(angle * index - halfPi);

      Offset featureOffset = Offset(
        center.dx + radius * xAngle,
        center.dy + radius * yAngle,
      );

      canvas.drawLine(
        center,
        featureOffset,
        Paint()
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..color = widget.axisColor
          ..strokeWidth = 1,
      );
    });
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, double scale) {
    if (widget.tickSize == 0) return;

    List<String> tickLabels =
        List.generate(widget.max.ceil() + 1, (index) => index.toString());

    Path path = Path();

    tickLabels.asMap().forEach((index, tick) {
      double tickRadius = scale * index;
      double sliceSize = 2 * pi / widget.features.length;

      for (int i = 0; i <= widget.features.length; i++) {
        double cosine = cos(sliceSize * i - RadarChartPainter.halfPi);
        double sine = sin(sliceSize * i - RadarChartPainter.halfPi);
        double x = tickRadius * cosine + center.dx;
        double y = tickRadius * sine + center.dy;
        path.moveTo(x + sine * widget.tickSize, y - cosine * widget.tickSize);
        path.lineTo(x - sine * widget.tickSize, y + cosine * widget.tickSize);
      }
    });

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..color = widget.tickColor
        ..strokeWidth = widget.tickWidth,
    );
  }

  void _drawGraph(
    Canvas canvas,
    Offset center,
    double radius,
    double scale,
    double angle,
  ) {
    Path path = Path()
      ..moveTo(center.dx, center.dy - scale * widget.features[0].value);

    for (int i = 1; i < widget.features.length; i++) {
      double scaledValue = scale * widget.features[i].value;
      path.lineTo(
        center.dx + scaledValue * cos(angle * i - pi / 2),
        center.dy + scaledValue * sin(angle * i - pi / 2),
      );
    }
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..color = widget.graphColor
          ..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..color = widget.graphStrokeColor
        ..strokeWidth = widget.graphStrokeWidth,
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    double anglePerSlice = 2 * pi / widget.features.length;

    widget.features.asMap().forEach((index, feature) {
      if (feature.label == null) return;

      TextPainter painter = TextPainter(
        text: TextSpan(text: feature.label, style: widget.labelTextStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      double angle = anglePerSlice * index;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -radius * 0.9);

      if (angle > halfPi && angle < 3 * halfPi) {
        canvas.rotate(pi);
      }

      painter.paint(
        canvas,
        Offset(-painter.width / 2, -painter.height / 2),
      );

      canvas.restore();
    });
  }
}
