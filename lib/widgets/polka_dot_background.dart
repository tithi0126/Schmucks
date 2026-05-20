import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<_TapPawPrint> _tapPawPrints = [];
  bool _showWalkingPaws = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200), // 3.2 seconds for a natural walking pace
    );
    _controller.repeat();
    _loadPreference();
  }

  void _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _showWalkingPaws = prefs.getBool('pref_walk_paws') ?? true;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDotColor = widget.dotColor ?? AppColors.forestGreen.withOpacity(0.07);
    final effectivePawColor = widget.pawColor ?? const Color(0xFF0C3827).withOpacity(0.06);

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          final now = DateTime.now();
          final randomAngle = ((now.millisecond % 360) * 3.14159) / 180.0;
          setState(() {
            _tapPawPrints.add(_TapPawPrint(
              position: details.localPosition,
              spawnTime: now,
              angle: randomAngle,
            ));
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final now = DateTime.now();
            _tapPawPrints.removeWhere((p) => now.difference(p.spawnTime).inMilliseconds > 1200);

            return CustomPaint(
              painter: _BackgroundPainter(
                dotColor: effectiveDotColor,
                spacing: widget.spacing,
                dotRadius: widget.dotRadius,
                pawColor: effectivePawColor,
                animationValue: _controller.value,
                tapPawPrints: List.from(_tapPawPrints),
                showWalkingPaws: _showWalkingPaws,
              ),
            );
          },
        ),
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
  final List<_TapPawPrint> tapPawPrints;
  final bool showWalkingPaws;

  _BackgroundPainter({
    required this.dotColor,
    required this.spacing,
    required this.dotRadius,
    required this.pawColor,
    required this.animationValue,
    required this.tapPawPrints,
    required this.showWalkingPaws,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw background tiny dog paw prints instead of simple polka dots
    final double miniPawSize = dotRadius * 12.0; // Increased size for bold, clear background paws
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawIconPaw(canvas, Offset(x, y), miniPawSize, dotColor);
      }
    }

    // 2. Draw floating coffee beans and hearts (Ambient background layer)
    final particlePaintColor = pawColor.withOpacity(pawColor.opacity * 0.4);
    for (var p in _particles) {
      double progressY = (p.yStartRatio - (animationValue * p.speed)) % 1.5 - 0.25;
      double y = size.height * progressY;
      double sway = sin(animationValue * p.swayFreq * 2 * 3.14159) * p.swayAmp;
      double x = size.width * p.xRatio + sway;
      double rotation = animationValue * p.rotationSpeed * 2 * 3.14159;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (p.type == 'bean') {
        _drawCoffeeBean(canvas, Offset.zero, p.size, particlePaintColor);
      } else {
        _drawHeart(canvas, Offset.zero, p.size, particlePaintColor);
      }
      canvas.restore();
    }

    // 3. Proper Stepping Walking Sequence (Reference: "Dog paws animation | Procreate tutorial")
    // Left and right paws take turns stepping forward. Already-placed footprints stay 100% static
    // on the ground (scrolling down), and only the active swinging paw moves in the air!
    if (showWalkingPaws) {
      const double stepDist = 120.0;
      const double cycleDist = 480.0; // Two left-right steps (4 steps total) for a perfectly periodic winding path
      final double yOffset = animationValue * cycleDist;
  
      // Draw visible steps on the screen range
      final int minIndex = -2;
      final int maxIndex = (size.height / stepDist).ceil() + 4;
  
      for (int k = minIndex; k <= maxIndex; k++) {
        final bool isRight = (k % 2 == 0);
        
        // Calculate target landing stance coordinates for step k
        final double stanceX = size.width * 0.5 + (isRight ? 38.0 : -38.0) + sin(k * 3.14159 / 2.0) * 16.0;
        final double stanceY = k * stepDist;
  
        // Calculate lift coordinates for step k-2 (same foot's previous step)
        final double oldX = size.width * 0.5 + (isRight ? 38.0 : -38.0) + sin((k - 2) * 3.14159 / 2.0) * 16.0;
        final double oldY = (k - 2) * stepDist;
  
        double drawX = stanceX;
        double drawY = stanceY;
        double pawScale = 1.0;
        double pawOpacity = 0.0; // Invisible by default if in the future
        double rippleProgress = -1.0;
  
        // Calculate dog's vertical position progress relative to this specific footprint
        final double relativeY = yOffset - stanceY;
  
        if (relativeY < -120.0) {
          // 🐾 FUTURE STEP: Dog hasn't reached it yet, so it is completely invisible
          continue;
        } else if (relativeY >= -120.0 && relativeY < 0.0) {
          // 🐾 SWING PHASE: This foot is currently lifting off from (oldX, oldY) and stepping forward to (stanceX, stanceY)
          final double p = (relativeY + 120.0) / 120.0; // swing progress: 0.0 (lift) -> 1.0 (landing)
          
          drawX = oldX + (stanceX - oldX) * p;
          drawY = oldY + (stanceY - oldY) * p;
          
          final double heightArc = sin(p * 3.14159);
          pawScale = 1.0 + 0.28 * heightArc; // Foot lifts high in the air (looks larger)
          pawOpacity = p; // Slowly materializes/fades in as it approaches the ground
        } else {
          // 🐾 STANCE PHASE: Foot has landed on the ground and stays 100% static at its stance coordinates!
          drawX = stanceX;
          drawY = stanceY;
          pawScale = 1.0;
          pawOpacity = 1.0; // Fully visible imprint on the ground
  
          // Landed shockwave ripple triggers immediately upon contact (relativeY: 0.0 -> 36.0)
          if (relativeY < 36.0) {
            rippleProgress = relativeY / 36.0;
          }
        }
  
        // Convert absolute ground coordinates to screen space by applying the infinite scroll offset
        final double screenY = size.height - (drawY - yOffset);
        final double screenX = drawX;
  
        // Render only if visible within screen bounds (plus drawing safety padding)
        if (screenY > -60 && screenY < size.height + 60) {
          // Fade out footprints smoothly as they reach the bottom of the screen
          double fadeFactor = 1.0;
          if (screenY > size.height - 180.0) {
            fadeFactor = ((size.height - screenY) / 180.0).clamp(0.0, 1.0);
          }
  
          final double finalOpacity = pawColor.opacity * pawOpacity * fadeFactor;
          if (finalOpacity > 0.0) {
            canvas.save();
            canvas.translate(screenX, screenY);
            
            // Natural rotation facing the path direction
            final double walkingAngle = isRight ? 0.12 : -0.12;
            canvas.rotate(walkingAngle);
  
            // Draw the chunky Procreate-style paw print (Matching Icons.pets_rounded)
            _drawIconPaw(canvas, Offset.zero, 78.0 * pawScale, pawColor.withOpacity(finalOpacity));
  
            // Draw the expanding impact ripple when the foot lands
            if (rippleProgress >= 0.0 && rippleProgress <= 1.0) {
              final ripplePaint = Paint()
                ..color = pawColor.withOpacity(pawColor.opacity * (1.0 - rippleProgress) * 0.45 * fadeFactor)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.8;
              canvas.drawCircle(Offset.zero, 78.0 * (1.0 + rippleProgress * 0.45), ripplePaint);
            }
  
            canvas.restore();
          }
        }
      }
    }

    // 4. Render User's interactive Tapped Paw Prints
    final now = DateTime.now();
    for (var tp in tapPawPrints) {
      final elapsedMs = now.difference(tp.spawnTime).inMilliseconds;
      if (elapsedMs > 1200) continue;

      double progress = elapsedMs / 1200.0;
      double tapOpacity = (1.0 - progress).clamp(0.0, 1.0);
      double tapScale = 1.0;
      
      if (elapsedMs < 150) {
        double tpRatio = elapsedMs / 150.0;
        tapScale = 1.6 - 0.6 * tpRatio;
      }

      canvas.save();
      canvas.translate(tp.position.dx, tp.position.dy);
      canvas.rotate(tp.angle);

      final interactivePawColor = const Color(0xFF0C3827).withOpacity(0.09 * tapOpacity);
      _drawIconPaw(canvas, Offset.zero, 64.0 * tapScale, interactivePawColor);

      if (elapsedMs < 150) {
        double rippleProgress = elapsedMs / 150.0;
        final ripplePaint = Paint()
          ..color = const Color(0xFF0C3827).withOpacity(0.12 * (1.0 - rippleProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(Offset.zero, 64.0 * (1.0 + rippleProgress * 0.6), ripplePaint);
      }
      canvas.restore();
    }
  }

  void _drawCoffeeBean(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.7, height: size),
      paint,
    );

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(color.opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.42);
    path.cubicTo(
      center.dx - size * 0.15, center.dy - size * 0.15,
      center.dx + size * 0.15, center.dy + size * 0.15,
      center.dx, center.dy + size * 0.42,
    );
    canvas.drawPath(path, linePaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size;
    final double height = size;
    
    final path = Path();
    path.moveTo(center.dx, center.dy - height * 0.25);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.6,
      center.dx - width * 0.7, center.dy + height * 0.1,
      center.dx, center.dy + height * 0.5,
    );
    path.cubicTo(
      center.dx + width * 0.7, center.dy + height * 0.1,
      center.dx + width * 0.5, center.dy - height * 0.6,
      center.dx, center.dy - height * 0.25,
    );
    canvas.drawPath(path, paint);
  }

  void _drawIconPaw(Canvas canvas, Offset center, double size, Color color) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(Icons.pets_rounded.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: Icons.pets_rounded.fontFamily,
          package: Icons.pets_rounded.fontPackage,
          color: color,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(size * 0.5, size * 0.5));
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.pawColor != pawColor ||
        oldDelegate.tapPawPrints != tapPawPrints;
  }
}

class _TapPawPrint {
  final Offset position;
  final DateTime spawnTime;
  final double angle;

  _TapPawPrint({
    required this.position,
    required this.spawnTime,
    required this.angle,
  });
}

class _FloatingParticle {
  final double xRatio;
  final double yStartRatio;
  final double speed;
  final double size;
  final String type; // 'bean' or 'heart'
  final double swayFreq;
  final double swayAmp;
  final double rotationSpeed;

  const _FloatingParticle({
    required this.xRatio,
    required this.yStartRatio,
    required this.speed,
    required this.size,
    required this.type,
    required this.swayFreq,
    required this.swayAmp,
    required this.rotationSpeed,
  });
}

const List<_FloatingParticle> _particles = [
  _FloatingParticle(xRatio: 0.12, yStartRatio: 1.05, speed: 0.7, size: 14.0, type: 'bean', swayFreq: 3.5, swayAmp: 18.0, rotationSpeed: 1.5),
  _FloatingParticle(xRatio: 0.28, yStartRatio: 1.25, speed: 0.9, size: 16.0, type: 'heart', swayFreq: 4.2, swayAmp: 22.0, rotationSpeed: -1.2),
  _FloatingParticle(xRatio: 0.45, yStartRatio: 1.15, speed: 0.6, size: 15.0, type: 'bean', swayFreq: 2.8, swayAmp: 14.0, rotationSpeed: 2.0),
  _FloatingParticle(xRatio: 0.62, yStartRatio: 1.35, speed: 0.8, size: 18.0, type: 'heart', swayFreq: 5.0, swayAmp: 25.0, rotationSpeed: -1.8),
  _FloatingParticle(xRatio: 0.78, yStartRatio: 1.10, speed: 1.0, size: 13.0, type: 'bean', swayFreq: 3.8, swayAmp: 16.0, rotationSpeed: 1.0),
  _FloatingParticle(xRatio: 0.90, yStartRatio: 1.30, speed: 0.7, size: 15.0, type: 'heart', swayFreq: 4.0, swayAmp: 20.0, rotationSpeed: -0.8),
  _FloatingParticle(xRatio: 0.22, yStartRatio: 1.45, speed: 0.8, size: 14.0, type: 'bean', swayFreq: 3.2, swayAmp: 19.0, rotationSpeed: 1.4),
  _FloatingParticle(xRatio: 0.70, yStartRatio: 1.50, speed: 0.6, size: 16.0, type: 'heart', swayFreq: 4.6, swayAmp: 24.0, rotationSpeed: -2.2),
];
