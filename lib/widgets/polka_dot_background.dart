import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PolkaDotBackground extends StatelessWidget {
  final Color? dotColor;
  final double spacing;
  final double dotRadius;

  const PolkaDotBackground({
    super.key,
    this.dotColor,
    this.spacing = 28.0,
    this.dotRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = dotColor ?? AppColors.forestGreen.withOpacity(0.07);
    
    return Positioned.fill(
      child: CustomPaint(
        painter: _PolkaDotPainter(
          dotColor: effectiveColor,
          spacing: spacing,
          dotRadius: dotRadius,
        ),
      ),
    );
  }
}

class _PolkaDotPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  _PolkaDotPainter({
    required this.dotColor,
    required this.spacing,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
