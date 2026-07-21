import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البلاغات')),
      body: const _ReportsPlaceholder(),
    );
  }
}

class _ReportsPlaceholder extends StatelessWidget {
  const _ReportsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'سيتم إضافة قائمة البلاغات في المرحلة التالية',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
