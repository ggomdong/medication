import 'package:flutter/material.dart';
import '../../constants/gaps.dart';
import '../../constants/sizes.dart';

Widget StatItem({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    width: 100,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Gaps.h4,
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Gaps.v4,
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: Sizes.size16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class StatItemAnimated extends StatelessWidget {
  final IconData icon;
  final String title;
  final double? rate;
  final Color color;

  const StatItemAnimated({
    super.key,
    required this.icon,
    required this.title,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              Gaps.h4,
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Gaps.v4,
          rate != null
              ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: rate!),
                duration: const Duration(milliseconds: 800),
                builder:
                    (context, value, _) => Text(
                      "${value.toStringAsFixed(2)} %",
                      style: TextStyle(
                        color: color,
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              )
              : Text(
                "-",
                style: TextStyle(
                  color: color,
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
  }
}
