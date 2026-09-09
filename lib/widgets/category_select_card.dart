import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report.dart';

/// Maps each [ReportCategory] to its optimized WebP background image.
///
/// Kept in one place so the category selection cards in both the add and edit
/// report screens share the same mapping instead of duplicating branch logic.
extension ReportCategoryImage on ReportCategory {
  String get imageAsset => switch (this) {
    ReportCategory.roadsAndRubble => 'assets/images/categories/roads.webp',
    ReportCategory.waterAndSanitation => 'assets/images/categories/water.webp',
    ReportCategory.electricity => 'assets/images/categories/electricity.webp',
    ReportCategory.buildingDamage => 'assets/images/categories/buildings.webp',
    ReportCategory.reliefNeeds => 'assets/images/categories/relief.webp',
    ReportCategory.wasteAndPublicHealth =>
      'assets/images/categories/waste.webp',
    ReportCategory.other => 'assets/images/categories/other.webp',
  };
}

/// A category choice card that uses the category image as its background with a
/// dark gradient overlay so the white Arabic label stays readable.
class CategorySelectCard extends StatelessWidget {
  const CategorySelectCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final ReportCategory category;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: category.label,
      child: Material(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  category.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.primary),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xD9081A17)],
                      stops: [0.3, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      category.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                if (selected)
                  const PositionedDirectional(
                    top: 6,
                    start: 6,
                    child: _SelectedBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
    );
  }
}
