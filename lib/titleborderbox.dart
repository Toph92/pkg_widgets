import 'package:flutter/material.dart';

class TitleBorderBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double borderWidth;
  final TextStyle titleStyle;

  const TitleBorderBox({
    super.key,
    required this.title,
    required this.child,
    this.borderColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.borderRadius = 8.0,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.borderWidth = 1.5,
    this.titleStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  });

  @override
  Widget build(BuildContext context) {
    // On va mesurer la taille du texte pour le CustomPainter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;

    return CustomPaint(
      painter: TitledBorderPainter(
        title: title,
        borderColor: borderColor,
        titleStyle: titleStyle,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        textWidth: textWidth,
        textHeight: textHeight,
        borderWidth: borderWidth,
      ),
      child: Padding(
        padding: contentPadding.copyWith(
          top: contentPadding.top /*+ textHeight / 2*/,
        ),
        child: child,
      ),
    );
  }
}

class TitledBorderPainter extends CustomPainter {
  final String title;
  final Color borderColor;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final double borderRadius;
  final double textWidth;
  final double textHeight;
  final double borderWidth;

  TitledBorderPainter({
    required this.title,
    required this.borderColor,
    required this.titleStyle,
    required this.backgroundColor,
    required this.borderRadius,
    required this.textWidth,
    required this.textHeight,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Position du texte (le titre)
    const double textLeftPosition = 20.0;
    const double textPadding = 4.0; // Espace autour du texte
    const double titleVerticalPosition = 0;

    // Dessiner le fond
    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(backgroundRRect, bgPaint);

    // Dessiner la bordure avec un espace pour le texte
    final Path borderPath = Path();

    // Commencer depuis le coin supérieur gauche
    borderPath.moveTo(borderRadius, titleVerticalPosition);

    // Ligne jusqu'au début de l'espace pour le texte
    borderPath.lineTo(textLeftPosition - textPadding, titleVerticalPosition);

    // Sauter l'espace du texte
    borderPath.moveTo(
      textLeftPosition + textWidth + textPadding,
      titleVerticalPosition,
    );

    // Ligne jusqu'au coin supérieur droit
    borderPath.lineTo(size.width - borderRadius, titleVerticalPosition);

    // Arc pour le coin supérieur droit
    borderPath.arcToPoint(
      Offset(size.width, borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    // Ligne droite descendante côté droit
    borderPath.lineTo(size.width, size.height - borderRadius);

    // Arc pour le coin inférieur droit
    borderPath.arcToPoint(
      Offset(size.width - borderRadius, size.height),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    // Ligne du bas
    borderPath.lineTo(borderRadius, size.height);

    // Arc pour le coin inférieur gauche
    borderPath.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    // Ligne gauche ascendante
    borderPath.lineTo(0, borderRadius);

    // Arc pour le coin supérieur gauche
    borderPath.arcToPoint(
      Offset(borderRadius, titleVerticalPosition),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    canvas.drawPath(borderPath, borderPaint);

    // Dessiner le texte du titre
    final TextSpan textSpan = TextSpan(text: title, style: titleStyle);

    final TextPainter painter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, Offset(textLeftPosition, -textHeight / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Exemple d'utilisation
