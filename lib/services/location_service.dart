import 'package:geolocator/geolocator.dart';

import '../models/report_coordinates.dart';

enum CurrentLocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  failed,
}

class CurrentLocationResult {
  const CurrentLocationResult._({required this.status, this.coordinates});

  const CurrentLocationResult.success(ReportCoordinates coordinates)
    : this._(status: CurrentLocationStatus.success, coordinates: coordinates);

  const CurrentLocationResult.failure(CurrentLocationStatus status)
    : this._(status: status);

  final CurrentLocationStatus status;
  final ReportCoordinates? coordinates;
}

class LocationService {
  const LocationService();

  Future<CurrentLocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const CurrentLocationResult.failure(
          CurrentLocationStatus.serviceDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const CurrentLocationResult.failure(
          CurrentLocationStatus.permissionDenied,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const CurrentLocationResult.failure(
          CurrentLocationStatus.permissionDeniedForever,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!ReportCoordinates.areValid(position.latitude, position.longitude)) {
        return const CurrentLocationResult.failure(
          CurrentLocationStatus.failed,
        );
      }

      return CurrentLocationResult.success(
        ReportCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (_) {
      return const CurrentLocationResult.failure(CurrentLocationStatus.failed);
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
