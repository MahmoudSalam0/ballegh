import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report.dart';
import '../widgets/status_chip.dart';
import 'edit_report_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key, required this.report});

  final Report report;

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late Report _report;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Future<void> _openEditScreen() async {
    final updatedReport = await Navigator.of(context).push<Report>(
      MaterialPageRoute<Report>(
        builder: (context) => EditReportScreen(report: _report),
      ),
    );

    if (!mounted || updatedReport == null) {
      return;
    }

    setState(() {
      _report = updatedReport;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates =
        _report.latitude != null || _report.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البلاغ'),
        actions: [
          IconButton(
            key: const Key('edit-report-action'),
            onPressed: _report.id == null ? null : _openEditScreen,
            tooltip: 'تعديل البلاغ',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportHeader(report: _report),
                  const SizedBox(height: 16),
                  _ReportImage(imagePath: _report.imagePath),
                  const SizedBox(height: 16),
                  _DetailsCard(
                    title: 'وصف البلاغ',
                    icon: Icons.description_outlined,
                    child: Text(
                      _report.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailsCard(
                    title: 'معلومات البلاغ',
                    icon: Icons.info_outline_rounded,
                    child: Column(
                      children: [
                        _InformationRow(
                          icon: Icons.location_on_outlined,
                          label: 'الموقع',
                          value: _report.location,
                        ),
                        const Divider(height: 28),
                        _InformationRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'تاريخ الإنشاء',
                          value: _formatArabicDateTime(_report.createdAt),
                        ),
                      ],
                    ),
                  ),
                  if (hasCoordinates) ...[
                    const SizedBox(height: 16),
                    _CoordinatesCard(
                      latitude: _report.latitude,
                      longitude: _report.longitude,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.id != null) ...[
              Text(
                'بلاغ رقم ${_toArabicDigits(report.id.toString())}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              report.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(status: report.status),
                _CategoryChip(category: report.category),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportImage extends StatelessWidget {
  const _ReportImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();
    final file = path == null || path.isEmpty ? null : File(path);
    final imageExists = file != null && _fileExists(file);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageExists
            ? Image.file(
                file,
                fit: BoxFit.cover,
                semanticLabel: 'صورة البلاغ',
                errorBuilder: (context, error, stackTrace) =>
                    const _ImagePlaceholder(),
              )
            : const _ImagePlaceholder(),
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primary,
                  size: 29,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد صورة متاحة لهذا البلاغ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  const _CoordinatesCard({required this.latitude, required this.longitude});

  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      title: 'الإحداثيات',
      icon: Icons.my_location_rounded,
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          if (latitude != null)
            _CoordinateValue(
              label: 'خط العرض',
              value: latitude!.toStringAsFixed(6),
            ),
          if (longitude != null)
            _CoordinateValue(
              label: 'خط الطول',
              value: longitude!.toStringAsFixed(6),
            ),
        ],
      ),
    );
  }
}

class _CoordinateValue extends StatelessWidget {
  const _CoordinateValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            _toArabicDigits(value),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String _formatArabicDateTime(DateTime date) {
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'ص' : 'م';
  final value =
      '${date.day} ${months[date.month - 1]} ${date.year}، '
      '$hour:$minute $period';
  return _toArabicDigits(value);
}

String _toArabicDigits(String value) {
  return value.replaceAllMapped(
    RegExp(r'\d'),
    (match) => '٠١٢٣٤٥٦٧٨٩'[int.parse(match.group(0)!)],
  );
}
