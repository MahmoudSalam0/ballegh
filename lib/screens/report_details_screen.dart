import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../database/database_helper.dart';
import '../models/report.dart';
import '../models/report_coordinates.dart';
import '../services/report_image_storage.dart';
import '../utils/report_location_text.dart';
import '../widgets/report_image.dart';
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
  bool _isDeleting = false;

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

  Future<void> _confirmDelete() async {
    if (_isDeleting) {
      return;
    }

    final reportId = _report.id;
    if (reportId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('لا يمكن حذف بلاغ دون رقم معرّف')),
        );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final errorColor = Theme.of(context).colorScheme.error;

        return AlertDialog(
          icon: Icon(Icons.delete_outline_rounded, color: errorColor, size: 36),
          title: const Text('حذف البلاغ؟', textAlign: TextAlign.center),
          content: const Text(
            'سيتم حذف هذا البلاغ نهائيًا، ولا يمكن التراجع عن هذه العملية.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final deletedRows = await DatabaseHelper.instance.deleteReport(reportId);

      if (deletedRows != 1) {
        throw StateError('لم يتم حذف صف واحد');
      }

      await ReportImageStorage.instance.deleteManagedImage(_report.imagePath);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 36,
            ),
            title: const Text('تم حذف البلاغ', textAlign: TextAlign.center),
            content: const Text(
              'تم حذف البلاغ بنجاح.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسنًا'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isDeleting = false;
      });
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تعذر حذف البلاغ، يرجى المحاولة مرة أخرى'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _openExternalMap() async {
    if (!ReportCoordinates.areValid(_report.latitude, _report.longitude)) {
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${_report.latitude},${_report.longitude}',
    });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) {
        return;
      }

      if (!opened) {
        _showMapLaunchError();
      }
    } catch (_) {
      if (mounted) {
        _showMapLaunchError();
      }
    }
  }

  void _showMapLaunchError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('تعذر فتح الموقع في تطبيق الخرائط')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = ReportCoordinates.areValid(
      _report.latitude,
      _report.longitude,
    );

    return PopScope<bool>(
      canPop: !_isDeleting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل البلاغ'),
          actions: [
            IconButton(
              key: const Key('edit-report-action'),
              onPressed: _report.id == null || _isDeleting
                  ? null
                  : _openEditScreen,
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
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ReportImage(
                        imagePath: _report.imagePath,
                        borderRadius: 0,
                        placeholderText: 'لا توجد صورة متاحة لهذا البلاغ',
                      ),
                    ),
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
                            value: reportLocationText(_report),
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
                    const SizedBox(height: 16),
                    if (hasCoordinates)
                      _ReportLocationMapCard(
                        latitude: _report.latitude!,
                        longitude: _report.longitude!,
                        onOpenExternalMap: _openExternalMap,
                      )
                    else
                      const _NoReportLocationCard(),
                    if (_report.id != null) ...[
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        key: const Key('delete-report-action'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: _isDeleting ? null : _confirmDelete,
                        icon: _isDeleting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                            : const Icon(Icons.delete_outline_rounded),
                        label: Text(
                          _isDeleting ? 'جارٍ حذف البلاغ...' : 'حذف البلاغ',
                        ),
                      ),
                    ],
                  ],
                ),
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

class _ReportLocationMapCard extends StatelessWidget {
  const _ReportLocationMapCard({
    required this.latitude,
    required this.longitude,
    required this.onOpenExternalMap,
  });

  final double latitude;
  final double longitude;
  final VoidCallback onOpenExternalMap;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return _DetailsCard(
      title: 'موقع البلاغ',
      icon: Icons.map_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ballegh_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        child: const _DetailsLocationMarker(),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: _openOpenStreetMapCopyright,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قد لا تظهر بلاطات الخريطة عند عدم توفر اتصال بالإنترنت.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _CoordinateValue(
                label: 'خط العرض',
                value: latitude.toStringAsFixed(6),
              ),
              _CoordinateValue(
                label: 'خط الطول',
                value: longitude.toStringAsFixed(6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onOpenExternalMap,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('فتح في الخرائط'),
          ),
        ],
      ),
    );
  }
}

class _NoReportLocationCard extends StatelessWidget {
  const _NoReportLocationCard();

  @override
  Widget build(BuildContext context) {
    return const _DetailsCard(
      title: 'موقع البلاغ',
      icon: Icons.location_off_outlined,
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(child: Text('لم يتم تحديد موقع لهذا البلاغ')),
        ],
      ),
    );
  }
}

class _DetailsLocationMarker extends StatelessWidget {
  const _DetailsLocationMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on_rounded,
        color: AppColors.textPrimary,
        size: 28,
      ),
    );
  }
}

void _openOpenStreetMapCopyright() {
  unawaited(
    launchUrl(
      Uri.parse('https://www.openstreetmap.org/copyright'),
      mode: LaunchMode.externalApplication,
    ),
  );
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
