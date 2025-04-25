import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TitleBorderBox extends StatelessWidget {
  final String? title;
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final double? borderWidth;
  final TextStyle? titleStyle;

  const TitleBorderBox({
    super.key,
    required this.child,
    this.title,
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
  })  : assert(borderWidth != null && borderWidth > 0,
            'Border width must be greater than 0'),
        assert(borderRadius != null && borderRadius >= 0,
            'Border radius must be greater than or equal to 0');

  factory TitleBorderBox.none() {
    return const TitleBorderBox(
      child: SizedBox(),
    );
  }

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
        borderColor: borderColor ?? Colors.blue,
        titleStyle: titleStyle ??
            const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
        backgroundColor: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? 8.0,
        textWidth: textWidth,
        textHeight: textHeight,
        borderWidth: borderWidth ?? 1.5,
      ),
      child: contentPadding != null
          ? Padding(
              padding: contentPadding!.copyWith(
                top: contentPadding!.top,
              ),
              child: child,
            )
          : child,
    );
  }
}

class TitledBorderPainter extends CustomPainter {
  final String? title;
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
  }) {
    if (title == null) {
      if (kDebugMode) {
        print(
            "if title is null or empty, may be a better idea to use Container() instead of TitleBorderBox()");
      }
    }
  }

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

    if (title != null && title!.isNotEmpty) {
      // Sauter l'espace du texte
      borderPath.moveTo(
        textLeftPosition + textWidth + textPadding,
        titleVerticalPosition,
      );
    }

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
    if (title == null || title!.isEmpty) return;
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
