import 'package:flutter/material.dart';

import '../models/report.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category});

  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      ReportCategory.roadsAndRubble => (
        Icons.construction_rounded,
        const Color(0xFF126B61),
      ),
      ReportCategory.waterAndSanitation => (
        Icons.water_drop_outlined,
        const Color(0xFF2D7DBB),
      ),
      ReportCategory.electricity => (
        Icons.electric_bolt_rounded,
        const Color(0xFFD98A00),
      ),
      ReportCategory.buildingDamage => (
        Icons.domain_disabled_outlined,
        const Color(0xFF8A6552),
      ),
      ReportCategory.reliefNeeds => (
        Icons.volunteer_activism_outlined,
        const Color(0xFF7A5CA8),
      ),
      ReportCategory.wasteAndPublicHealth => (
        Icons.health_and_safety_outlined,
        const Color(0xFF4D8372),
      ),
      ReportCategory.other => (
        Icons.category_outlined,
        const Color(0xFF60706C),
      ),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 25),
    );
  }
}
