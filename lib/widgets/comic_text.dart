import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color? shadowColor;
  final Offset shadowOffset;
  final TextAlign textAlign;
  final TextStyle? additionalStyle;

  const ComicText({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.fillColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 5.0,
    this.shadowColor,
    this.shadowOffset = const Offset(3, 3),
    this.textAlign = TextAlign.center,
    this.additionalStyle,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: GoogleFonts.lilitaOne().fontFamily,
      letterSpacing: 1.0,
      height: 1.1,
    ).merge(additionalStyle);

    return Stack(
      children: [
        // Drop shadow (thick outline offset)
        if (shadowColor != null) ...[
          Transform.translate(
            offset: shadowOffset,
            child: Text(
              text,
              textAlign: textAlign,
              style: baseStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = shadowColor!,
              ),
            ),
          ),
          Transform.translate(
            offset: shadowOffset,
            child: Text(
              text,
              textAlign: textAlign,
              style: baseStyle.copyWith(
                color: shadowColor,
              ),
            ),
          ),
        ],

        // Main Black Stroke Outline
        Text(
          text,
          textAlign: textAlign,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),

        // Main Fill Color
        Text(
          text,
          textAlign: textAlign,
          style: baseStyle.copyWith(
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
