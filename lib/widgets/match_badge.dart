import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MatchBadge extends StatelessWidget {
  final int percent;
  const MatchBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forMatch(percent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 15, color: color),
          const SizedBox(width: 3),
          Text(
            '$percent% match',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
