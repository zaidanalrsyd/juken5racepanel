
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color accentColor;
  final IconData icon;
  final double? progress;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.accentColor,
    required this.icon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 78 || constraints.maxWidth < 115;

        final padding = compact ? 5.0 : 10.0;
        final iconSize = compact ? 19.0 : 25.0;
        final valueSize = compact ? 18.0 : 27.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFF090E14),
            borderRadius: BorderRadius.circular(compact ? 5 : 9),
            border: Border.all(
              color: const Color(0xFF34404D),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: iconSize,
              ),
              SizedBox(width: compact ? 5 : 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFE0E6ED),
                        fontSize: compact ? 9 : 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: compact ? 1 : 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: valueSize,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (unit.isNotEmpty) ...[
                            const SizedBox(width: 2),
                            Text(
                              unit,
                              style: TextStyle(
                                color: const Color(0xFFD3DAE3),
                                fontSize: compact ? 8 : 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (progress != null && !compact) ...[
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress!.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: const Color(0xFF26303B),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
