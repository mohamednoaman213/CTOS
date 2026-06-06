import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CtosLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const CtosLogo({super.key, this.size = 80, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          const Text('CTOS', style: AppTextStyles.ctosTitle),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.42;
    final h = size.height * 0.42;

    // Diamond outer shape
    final diamondPath = Path()
      ..moveTo(cx, cy - h)
      ..lineTo(cx + w, cy)
      ..lineTo(cx, cy + h)
      ..lineTo(cx - w, cy)
      ..close();
    canvas.drawPath(diamondPath, paint);

    // Inner diamond (smaller)
    final innerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final innerW = w * 0.55;
    final innerH = h * 0.55;
    final innerPath = Path()
      ..moveTo(cx, cy - innerH)
      ..lineTo(cx + innerW, cy)
      ..lineTo(cx, cy + innerH)
      ..lineTo(cx - innerW, cy)
      ..close();
    canvas.drawPath(innerPath, innerPaint);

    // Vertical line from top to bottom
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - h), Offset(cx, cy + h), linePaint);

    // Arrow/pointer at bottom of inner diamond
    final arrowPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(cx - innerW * 0.3, cy + innerH * 0.2)
      ..lineTo(cx + innerW * 0.3, cy + innerH * 0.2)
      ..lineTo(cx, cy + innerH)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
