import '../models/report.dart';
import '../models/report_coordinates.dart';

const _unsetLocationText = 'لم يتم تحديد الموقع';

String reportLocationText(Report report) {
  final location = report.location.trim();
  final hasLocationName = location.isNotEmpty && location != _unsetLocationText;

  if (hasLocationName) {
    return location;
  }

  if (ReportCoordinates.areValid(report.latitude, report.longitude)) {
    return 'تم تحديد الموقع على الخريطة';
  }

  return _unsetLocationText;
}
