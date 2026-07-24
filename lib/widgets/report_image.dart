import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ReportImage extends StatelessWidget {
  const ReportImage({
    super.key,
    required this.imagePath,
    this.aspectRatio = 16 / 9,
    this.borderRadius = 16,
    this.placeholderText = 'لا توجد صورة متاحة',
  });

  final String? imagePath;
  final double aspectRatio;
  final double borderRadius;
  final String placeholderText;

  @override
  Widget build(BuildContext context) {
    final value = imagePath?.trim();
    final file = value == null || value.isEmpty ? null : File(value);
    final imageExists = file != null && _fileExists(file);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: imageExists
            ? Image.file(
                file,
                fit: BoxFit.cover,
                semanticLabel: 'صورة البلاغ',
                errorBuilder: (context, error, stackTrace) =>
                    _ReportImagePlaceholder(text: placeholderText),
              )
            : _ReportImagePlaceholder(text: placeholderText),
      ),
    );
  }

  bool _fileExists(File file) {
    try {
      return file.existsSync();
    } on FileSystemException {
      return false;
    }
  }
}

class _ReportImagePlaceholder extends StatelessWidget {
  const _ReportImagePlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary.withValues(alpha: 0.75),
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
