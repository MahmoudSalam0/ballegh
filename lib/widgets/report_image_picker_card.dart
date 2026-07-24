import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import 'report_image.dart';

class ReportImagePickerCard extends StatelessWidget {
  const ReportImagePickerCard({
    super.key,
    required this.imagePath,
    required this.isLoading,
    required this.enabled,
    required this.onChoose,
    required this.onRemove,
  });

  final String? imagePath;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  bool get _hasImage => imagePath?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled && !isLoading ? onChoose : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'صورة البلاغ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Stack(
                alignment: Alignment.center,
                children: [
                  ReportImage(
                    imagePath: imagePath,
                    borderRadius: 14,
                    placeholderText: 'اضغط لاختيار صورة للبلاغ',
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                _hasImage
                    ? 'يمكنك استبدال الصورة الحالية أو إزالتها.'
                    : 'يمكنك التقاط صورة أو اختيار صورة من المعرض.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('choose-report-image'),
                    onPressed: enabled && !isLoading ? onChoose : null,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(_hasImage ? 'استبدال الصورة' : 'اختيار صورة'),
                  ),
                  if (_hasImage)
                    TextButton.icon(
                      key: const Key('remove-report-image'),
                      onPressed: enabled && !isLoading ? onRemove : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('إزالة الصورة'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<ImageSource?> showReportImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة صورة للبلاغ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const Key('pick-image-camera'),
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              key: const Key('pick-image-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار صورة من المعرض'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('إلغاء'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}
