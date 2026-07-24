import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../models/report_coordinates.dart';
import '../services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _fallbackCenter = LatLng(31.95, 35.2);

  final _mapController = MapController();
  final _locationService = const LocationService();

  LatLng? _selectedPoint;
  bool _isLocating = false;
  bool _hasTileLoadError = false;

  @override
  void initState() {
    super.initState();

    if (ReportCoordinates.areValid(
      widget.initialLatitude,
      widget.initialLongitude,
    )) {
      _selectedPoint = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _useCurrentLocation();
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    final result = await _locationService.getCurrentLocation();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLocating = false;
    });

    switch (result.status) {
      case CurrentLocationStatus.success:
        final coordinates = result.coordinates!;
        final point = LatLng(coordinates.latitude, coordinates.longitude);
        setState(() {
          _selectedPoint = point;
        });
        _mapController.move(point, 16);
      case CurrentLocationStatus.serviceDisabled:
        await _showLocationSettingsDialog();
      case CurrentLocationStatus.permissionDenied:
        _showMessage(
          'تم رفض صلاحية الموقع. يمكنك اختيار نقطة يدويًا أو المحاولة مجددًا.',
        );
      case CurrentLocationStatus.permissionDeniedForever:
        await _showAppSettingsDialog();
      case CurrentLocationStatus.failed:
        _showMessage(
          'تعذر الحصول على موقعك الحالي. يمكنك اختيار نقطة على الخريطة يدويًا.',
        );
    }
  }

  Future<void> _showLocationSettingsDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.location_disabled_outlined,
            color: AppColors.accent,
            size: 36,
          ),
          title: const Text('خدمة الموقع متوقفة'),
          content: const Text(
            'فعّل GPS من إعدادات الموقع، أو تابع واختر نقطة على الخريطة يدويًا.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('متابعة دون GPS'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('فتح إعدادات الموقع'),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      if (!mounted) {
        return;
      }
      final opened = await _locationService.openLocationSettings();
      if (mounted && !opened) {
        _showMessage('تعذر فتح إعدادات الموقع');
      }
    }
  }

  Future<void> _showAppSettingsDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.no_accounts_outlined,
            color: Theme.of(context).colorScheme.error,
            size: 36,
          ),
          title: const Text('صلاحية الموقع مرفوضة نهائيًا'),
          content: const Text(
            'يمكنك المتابعة دون GPS أو فتح إعدادات التطبيق والسماح بالوصول إلى الموقع.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('متابعة دون GPS'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('فتح إعدادات التطبيق'),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      if (!mounted) {
        return;
      }
      final opened = await _locationService.openAppSettings();
      if (mounted && !opened) {
        _showMessage('تعذر فتح إعدادات التطبيق');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLocation() {
    final point = _selectedPoint;
    if (point == null) {
      _showMessage('اختر نقطة على الخريطة أولًا');
      return;
    }

    Navigator.of(context).pop(
      ReportCoordinates(latitude: point.latitude, longitude: point.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = _selectedPoint ?? _fallbackCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('تحديد موقع البلاغ')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: _selectedPoint == null ? 9 : 16,
                      onTap: (tapPosition, point) {
                        if (_isLocating) {
                          return;
                        }
                        setState(() {
                          _selectedPoint = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ballegh_app',
                        errorTileCallback: (tile, error, stackTrace) {
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
                        },
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              width: 52,
                              height: 52,
                              child: const _LocationMarker(),
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
                    left: 12,
                    child: IgnorePointer(
                      child: Card(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text(
                            'اضغط على الخريطة لتغيير نقطة البلاغ',
                            textAlign: TextAlign.center,
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
                            'تعذر تحميل الخريطة. تحقق من الإنترنت، ويمكنك الرجوع والمحاولة لاحقًا.',
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
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _selectedPoint == null
                          ? 'لم يتم اختيار نقطة بعد'
                          : 'الإحداثيات المحددة',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_selectedPoint != null) ...[
                      const SizedBox(height: 5),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${_selectedPoint!.latitude.toStringAsFixed(6)}, '
                          '${_selectedPoint!.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      key: const Key('use-current-location'),
                      onPressed: _isLocating ? null : _useCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(
                        _isLocating
                            ? 'جارٍ تحديد موقعك...'
                            : 'استخدام موقعي الحالي',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      key: const Key('confirm-report-location'),
                      onPressed: _isLocating ? null : _confirmLocation,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('تأكيد الموقع'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  const _LocationMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
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
        Icons.location_on_rounded,
        color: AppColors.textPrimary,
        size: 30,
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
