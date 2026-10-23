
import 'package:flutter/material.dart';

class RpmGauge extends StatelessWidget {
  final int rpm;
  final int maxRpm;
  final int redlineRpm;

  const RpmGauge({
    super.key,
    required this.rpm,
    this.maxRpm = 13000,
    this.redlineRpm = 11000,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 90;
        final safeMaxRpm = maxRpm > 0 ? maxRpm : 13000;
        final fraction = (rpm / safeMaxRpm).clamp(0.0, 1.0);
        final redlineFraction =
            (redlineRpm / safeMaxRpm).clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: compact ? 20 : 28,
              child: CustomPaint(
                painter: _RpmBarPainter(
                  fraction: fraction,
                  redlineFraction: redlineFraction,
                  compact: compact,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('0', compact),
                _label('2', compact),
                _label('4', compact),
                _label('6', compact),
                _label('8', compact),
                _label('10', compact),
                _label('13', compact, red: true),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _label(String value, bool compact, {bool red = false}) {
    return Text(
      value,
      style: TextStyle(
        color: red ? const Color(0xFFFF2638) : const Color(0xFFB8C0CA),
        fontSize: compact ? 8 : 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RpmBarPainter extends CustomPainter {
  final double fraction;
  final double redlineFraction;
  final bool compact;

  const _RpmBarPainter({
    required this.fraction,
    required this.redlineFraction,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Rect.fromLTWH(0, 2, size.width, size.height - 4);
    final radius = Radius.circular(compact ? 2 : 3);
    final roundedRect = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(
      roundedRect,
      Paint()..color = const Color(0xFF26303B),
    );

    const gradient = LinearGradient(
      colors: [
        Color(0xFFE9EEF4),
        Color(0xFFFFFFFF),
        Color(0xFFFFD21F),
        Color(0xFFFF9B22),
        Color(0xFFFF2638),
      ],
      stops: [0.0, 0.22, 0.52, 0.75, 1.0],
    );

    canvas.save();
    canvas.clipRRect(roundedRect);

    final activeWidth = rect.width * fraction;

    if (activeWidth > 0) {
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top, activeWidth, rect.height),
        Paint()..shader = gradient.createShader(rect),
      );
    }

    const divisions = 26;
    final tickPaint = Paint()
      ..color = const Color(0xFF071018).withValues(alpha: 0.8)
      ..strokeWidth = compact ? 1 : 1.4;

    for (int i = 0; i <= divisions; i++) {
      final x = rect.left + rect.width * i / divisions;
      final major = i % 4 == 0;

      canvas.drawLine(
        Offset(x, rect.top),
        Offset(
          x,
          major ? rect.bottom : rect.bottom - rect.height * 0.35,
        ),
        tickPaint,
      );
    }

    canvas.restore();

    final redlineX = rect.left + rect.width * redlineFraction;

    canvas.drawLine(
      Offset(redlineX, rect.top - 1),
      Offset(redlineX, rect.bottom + 1),
      Paint()
        ..color = const Color(0xFFFF2638)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RpmBarPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        redlineFraction != oldDelegate.redlineFraction ||
        compact != oldDelegate.compact;
  }
}
