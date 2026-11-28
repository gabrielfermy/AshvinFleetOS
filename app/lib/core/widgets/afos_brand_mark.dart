import 'package:flutter/material.dart';
import '../theme/afos_colors.dart';
import '../theme/afos_typography.dart';

/// Official Vector Brand Mark for Ashvin FleetOS (AFOS)
/// Renders the AF Monogram (Route ribbon + Shield security contour)
class AfosBrandMark extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool compact;
  final Color? color;

  const AfosBrandMark({
    super.key,
    this.size = 36.0,
    this.showWordmark = true,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final monogram = CustomPaint(
      size: Size(size, size),
      painter: _AfMonogramPainter(
        primaryColor: color ?? AfosColors.primaryNavy,
        accentColor: color ?? AfosColors.jogjaTeal,
      ),
    );

    if (!showWordmark) {
      return monogram;
    }

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          monogram,
          const SizedBox(width: 8),
          Text(
            'AFOS',
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w800,
              color: color ?? AfosColors.primaryNavy,
              letterSpacing: 0.8,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        monogram,
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Ashvin ',
                  style: TextStyle(
                    fontSize: size * 0.46,
                    fontWeight: FontWeight.w800,
                    color: color ?? AfosColors.primaryNavy,
                    letterSpacing: -0.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'FleetOS',
                      style: TextStyle(
                        color: color ?? AfosColors.jogjaTeal,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AfosColors.jogjaTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'AFOS',
                  style: AfosTypography.bookingCode.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AfosColors.jogjaTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CustomPainter rendering the AF shield & road perspective ribbon
class _AfMonogramPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _AfMonogramPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Shield Perimeter Background (Subtle)
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.85, h * 0.05, w * 0.95, h * 0.25, w * 0.95, h * 0.55)
      ..cubicTo(w * 0.95, h * 0.82, w * 0.65, h * 0.96, w * 0.5, h * 1.0)
      ..cubicTo(w * 0.35, h * 0.96, w * 0.05, h * 0.82, w * 0.05, h * 0.55)
      ..cubicTo(w * 0.05, h * 0.25, w * 0.15, h * 0.05, w * 0.5, h * 0.05)
      ..close();

    final shieldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(shieldPath, shieldPaint);

    // 2. Highway / Route Ribbon (Representing letter A & F)
    final routePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Left diagonal road path (Leg of 'A')
    final roadLeft = Path()
      ..moveTo(w * 0.48, h * 0.22)
      ..lineTo(w * 0.56, h * 0.22)
      ..lineTo(w * 0.35, h * 0.78)
      ..lineTo(w * 0.24, h * 0.78)
      ..close();
    canvas.drawPath(roadLeft, routePaint);

    // Center crossbar & Right top hook (Bar of 'A' and arms of 'F')
    final fBarTop = Path()
      ..moveTo(w * 0.45, h * 0.34)
      ..lineTo(w * 0.76, h * 0.34)
      ..lineTo(w * 0.76, h * 0.43)
      ..lineTo(w * 0.42, h * 0.43)
      ..close();

    final fBarMid = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.68, h * 0.52)
      ..lineTo(w * 0.68, h * 0.61)
      ..lineTo(w * 0.34, h * 0.61)
      ..close();

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(fBarTop, whitePaint);
    canvas.drawPath(fBarMid, whitePaint);

    // Dynamic Route Centerline Dash (Precision indicator)
    final dashPaint = Paint()
      ..color = AfosColors.warmAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.52, h * 0.66),
      Offset(w * 0.56, h * 0.74),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AfMonogramPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor || oldDelegate.accentColor != accentColor;
  }
}
