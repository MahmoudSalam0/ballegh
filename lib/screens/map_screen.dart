import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../database/database_helper.dart';
import '../models/report.dart';
import '../models/report_coordinates.dart';
import '../widgets/status_chip.dart';
import 'report_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.refreshVersion});

  final int refreshVersion;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackCenter = LatLng(31.95, 35.2);

  final _mapController = MapController();

  List<Report> _reports = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _hasTileLoadError = false;
  int _loadRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshVersion != oldWidget.refreshVersion) {
      _loadReports();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final request = ++_loadRequest;

    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      final reports = await DatabaseHelper.instance.getAllReports();
      final locatedReports = reports.where((report) {
        return ReportCoordinates.areValid(report.latitude, report.longitude);
      }).toList();

      if (!mounted || request != _loadRequest) {
        return;
      }

      setState(() {
        _reports = locatedReports;
        _isLoading = false;
        _hasLoadError = false;
      });

      _fitReports(locatedReports);
    } catch (_) {
      if (!mounted || request != _loadRequest) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  void _fitReports(List<Report> reports) {
    if (reports.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final points = reports
          .map((report) => LatLng(report.latitude!, report.longitude!))
          .toList();

      if (points.length == 1) {
        _mapController.move(points.first, 15);
        return;
      }

      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.fromLTRB(48, 80, 48, 120),
          maxZoom: 16,
        ),
      );
    });
  }

  Future<void> _openDetails(Report report) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ReportDetailsScreen(report: report),
      ),
    );

    if (mounted) {
      await _loadReports();
    }
  }

  void _showReportSummary(Report report) {
    final location = report.location.trim();
    final hasLocationText =
        location.isNotEmpty && location != 'لم يتم تحديد الموقع';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        report.title,
                        style: Theme.of(sheetContext).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _CategoryChip(category: report.category),
                          StatusChip(status: report.status),
                        ],
                      ),
                      if (hasLocationText) ...[
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                location,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await _openDetails(report);
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('عرض التفاصيل'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTileError() {
    if (_hasTileLoadError || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasTileLoadError) {
        setState(() {
          _hasTileLoadError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخريطة'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadReports,
            tooltip: 'تحديث البلاغات على الخريطة',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasLoadError
            ? _MapLoadError(onRetry: _loadReports)
            : _reports.isEmpty
            ? const _EmptyMapState()
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _fallbackCenter,
                      initialZoom: 8,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ballegh_app',
                        errorTileCallback: (tile, error, stackTrace) {
                          _handleTileError();
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          for (final report in _reports)
                            Marker(
                              point: LatLng(
                                report.latitude!,
                                report.longitude!,
                              ),
                              width: 52,
                              height: 52,
                              child: _ReportMarker(
                                onTap: () => _showReportSummary(report),
                              ),
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
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Card(
                      color: AppColors.surface.withValues(alpha: 0.94),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          '${_reports.length} بلاغ على الخريطة',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                  if (_hasTileLoadError)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      left: 12,
                      child: Card(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer.withValues(alpha: 0.94),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text(
                            'تعذر تحميل بعض أجزاء الخريطة. تحقق من الاتصال بالإنترنت ثم أعد المحاولة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ReportMarker extends StatelessWidget {
  const _ReportMarker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'عرض ملخص البلاغ',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.report_problem_rounded,
            color: AppColors.accent,
            size: 27,
          ),
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
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        category.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد بلاغات محددة على الخريطة',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا البلاغات التي تحتوي على إحداثيات موقع صالحة.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLoadError extends StatelessWidget {
  const _MapLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل بلاغات الخريطة',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('يرجى المحاولة مرة أخرى.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
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
