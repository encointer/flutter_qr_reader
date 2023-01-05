import 'package:flutter/material.dart';

class QrScanBoxPainter extends CustomPainter {
  const QrScanBoxPainter({
    required this.animationValue,
    required this.isForward,
    this.boxLineColor,
  });

  final double animationValue;
  final bool isForward;
  final Color? boxLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = const BorderRadius.all(Radius.circular(12)).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRRect(
      borderRadius,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      // leftTop
      ..moveTo(0, 50)
      ..lineTo(0, 12)
      ..quadraticBezierTo(0, 0, 12, 0)
      ..lineTo(50, 0)
      // rightTop
      ..moveTo(size.width - 50, 0)
      ..lineTo(size.width - 12, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 12)
      ..lineTo(size.width, 50)
      // rightBottom
      ..moveTo(size.width, size.height - 50)
      ..lineTo(size.width, size.height - 12)
      ..quadraticBezierTo(size.width, size.height, size.width - 12, size.height)
      ..lineTo(size.width - 50, size.height)
      // leftBottom
      ..moveTo(50, size.height)
      ..lineTo(12, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 12)
      ..lineTo(0, size.height - 50);

    canvas
      ..drawPath(path, borderPaint)
      ..clipRRect(const BorderRadius.all(Radius.circular(12)).toRRect(Offset.zero & size));

    // 绘制横向网格
    final linePaint = Paint();
    final lineSize = size.height * 0.45;
    final leftPress = (size.height + lineSize) * animationValue - lineSize;
    linePaint
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [Colors.transparent, boxLineColor!],
        begin: isForward ? Alignment.topCenter : const Alignment(0, 2),
        end: isForward ? const Alignment(0, 0.5) : Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, leftPress, size.width, lineSize));
    for (var i = 0; i < size.height / 5; i++) {
      canvas.drawLine(
        Offset(
          i * 5.0,
          leftPress,
        ),
        Offset(i * 5.0, leftPress + lineSize),
        linePaint,
      );
    }
    for (var i = 0; i < lineSize / 5; i++) {
      canvas.drawLine(
        Offset(0, leftPress + i * 5.0),
        Offset(
          size.width,
          leftPress + i * 5.0,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(QrScanBoxPainter oldDelegate) => animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxPainter oldDelegate) => animationValue != oldDelegate.animationValue;
}
