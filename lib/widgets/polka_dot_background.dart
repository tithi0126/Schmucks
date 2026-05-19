import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PolkaDotBackground extends StatefulWidget {
  final Color? dotColor;
  final double spacing;
  final double dotRadius;
  final Color? pawColor;

  const PolkaDotBackground({
    super.key,
    this.dotColor,
    this.spacing = 28.0,
    this.dotRadius = 2.0,
    this.pawColor,
  });

  @override
  State<PolkaDotBackground> createState() => _PolkaDotBackgroundState();
}

class _PolkaDotBackgroundState extends State<PolkaDotBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500), // 4.5 seconds loop for the walking path cycle
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDotColor = widget.dotColor ?? AppColors.forestGreen.withOpacity(0.07);
    // Use soft pink paws on pink detail backgrounds, or dark forest green paws on cream backgrounds
    final effectivePawColor = widget.pawColor ?? const Color(0xFF0C3827).withOpacity(0.06);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BackgroundPainter(
              dotColor: effectiveDotColor,
              spacing: widget.spacing,
              dotRadius: widget.dotRadius,
              pawColor: effectivePawColor,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;
  final Color pawColor;
  final double animationValue;

  _BackgroundPainter({
    required this.dotColor,
    required this.spacing,
    required this.dotRadius,
    required this.pawColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw polka dots
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // 2. Draw walking dog paw prints (Snoopy footprints)
    // We define a diagonal crawling path with 6 steps across the viewport
    final steps = [
      _PawStep(xRatio: 0.15, yRatio: 0.82, angle: -0.25), // Step 1
      _PawStep(xRatio: 0.35, yRatio: 0.70, angle: 0.15),  // Step 2
      _PawStep(xRatio: 0.24, yRatio: 0.55, angle: -0.2),  // Step 3
      _PawStep(xRatio: 0.44, yRatio: 0.42, angle: 0.25),  // Step 4
      _PawStep(xRatio: 0.33, yRatio: 0.28, angle: -0.15), // Step 5
      _PawStep(xRatio: 0.53, yRatio: 0.15, angle: 0.2),   // Step 6
    ];

    // Total animation cycle is split across these steps
    for (int i = 0; i < steps.length; i++) {
      double startT = i * 0.13; // steps are spaced: 0.0, 0.13, 0.26, 0.39, 0.52, 0.65
      double endT = startT + 0.09; // each step takes 9% of cycle to fully fade in
      
      double stepOpacity = 0.0;
      if (animationValue > startT) {
        if (animationValue < endT) {
          // Fading in
          stepOpacity = (animationValue - startT) / (endT - startT);
        } else if (animationValue < 0.85) {
          // Fully visible
          stepOpacity = 1.0;
        } else {
          // All steps fade out together from 0.85 to 0.96
          stepOpacity = (0.96 - animationValue).clamp(0.0, 0.11) / 0.11;
        }
      }

      if (stepOpacity > 0.0) {
        final double x = size.width * steps[i].xRatio;
        final double y = size.height * steps[i].yRatio;
        
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(steps[i].angle);
        
        _drawPawPrint(canvas, Offset.zero, 25.0, pawColor.withOpacity(pawColor.opacity * stepOpacity));
        
        canvas.restore();
      }
    }
  }

  void _drawPawPrint(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Central main pad (rounded squarish triangle)
    final Path mainPadPath = Path();
    mainPadPath.moveTo(center.dx - size * 0.22, center.dy + size * 0.1);
    mainPadPath.quadraticBezierTo(center.dx - size * 0.32, center.dy + size * 0.35, center.dx, center.dy + size * 0.38);
    mainPadPath.quadraticBezierTo(center.dx + size * 0.32, center.dy + size * 0.35, center.dx + size * 0.22, center.dy + size * 0.1);
    mainPadPath.quadraticBezierTo(center.dx, center.dy + size * 0.18, center.dx - size * 0.22, center.dy + size * 0.1);
    canvas.drawPath(mainPadPath, paint);

    // 4 toe pads arranged in a beautiful curved arc
    // Left outer toe
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-size * 0.26, -size * 0.08), width: size * 0.15, height: size * 0.22),
      paint,
    );
    // Left inner toe
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-size * 0.09, -size * 0.19), width: size * 0.17, height: size * 0.24),
      paint,
    );
    // Right inner toe
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(size * 0.09, -size * 0.19), width: size * 0.17, height: size * 0.24),
      paint,
    );
    // Right outer toe
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(size * 0.26, -size * 0.08), width: size * 0.15, height: size * 0.22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.pawColor != pawColor;
  }
}

class _PawStep {
  final double xRatio;
  final double yRatio;
  final double angle;

  _PawStep({
    required this.xRatio,
    required this.yRatio,
    required this.angle,
  });
}
