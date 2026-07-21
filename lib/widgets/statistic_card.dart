import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.horizontal = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 21),
    );
    final valueText = Text(
      value,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    );
    final titleText = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.35,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: horizontal
            ? Row(
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(child: titleText),
                  const SizedBox(width: 12),
                  valueText,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(height: 14),
                  valueText,
                  const SizedBox(height: 4),
                  titleText,
                ],
              ),
      ),
    );
  }
}
