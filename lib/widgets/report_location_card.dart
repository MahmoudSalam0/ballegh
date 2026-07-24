import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report_coordinates.dart';

class ReportLocationCard extends StatelessWidget {
  const ReportLocationCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.enabled,
    required this.onOpen,
    required this.onRemove,
  });

  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasLocation = ReportCoordinates.areValid(latitude, longitude);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'موقع المشكلة على الخريطة',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasLocation
                            ? 'تم تحديد موقع البلاغ'
                            : 'لم يتم تحديد موقع للبلاغ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: hasLocation
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: hasLocation
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 4),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${latitude!.toStringAsFixed(5)}, '
                            '${longitude!.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('open-location-picker'),
                  onPressed: enabled && !isLoading ? onOpen : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.map_outlined),
                  label: Text(hasLocation ? 'تغيير الموقع' : 'تحديد الموقع'),
                ),
                if (hasLocation)
                  TextButton.icon(
                    key: const Key('remove-report-location'),
                    onPressed: enabled && !isLoading ? onRemove : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.location_off_outlined),
                    label: const Text('إزالة الموقع'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
