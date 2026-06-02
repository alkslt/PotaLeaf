import 'package:flutter/material.dart';

/// Draws animated green corner brackets (4 L-shaped corners) for the scanner overlay.
class ScannerOverlayPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;
  final double animationValue; // 0.0 to 1.0 for glow pulsing

  ScannerOverlayPainter({
    this.color = const Color(0xFF51A612),
    this.cornerLength = 32,
    this.strokeWidth = 4,
    this.borderRadius = 16,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6 + (0.4 * animationValue))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow effect behind brackets
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2 * animationValue)
      ..strokeWidth = strokeWidth + 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // Top-left corner
    _drawCorner(canvas, paint, glowPaint, cl, 0, 0, 0, 0, cl);
    // Top-right corner
    _drawCorner(canvas, paint, glowPaint, w - cl, 0, w, 0, w, cl);
    // Bottom-left corner
    _drawCorner(canvas, paint, glowPaint, 0, h - cl, 0, h, cl, h);
    // Bottom-right corner
    _drawCorner(canvas, paint, glowPaint, w, h - cl, w, h, w - cl, h);
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Paint glowPaint,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    // Draw glow first
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), glowPaint);
    canvas.drawLine(Offset(x2, y2), Offset(x3, y3), glowPaint);
    // Draw sharp brackets on top
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    canvas.drawLine(Offset(x2, y2), Offset(x3, y3), paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
