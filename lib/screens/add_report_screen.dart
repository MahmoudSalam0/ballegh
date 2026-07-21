import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AddReportScreen extends StatelessWidget {
  const AddReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة بلاغ')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'سيتم بناء نموذج البلاغ في مرحلة لاحقة',
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
      ),
    );
  }
}
