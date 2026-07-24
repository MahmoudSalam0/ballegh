import 'package:ballegh_app/models/report_coordinates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('يتحقق من وجود الإحداثيات وصحة نطاقها', () {
    expect(ReportCoordinates.areValid(31.95, 35.2), isTrue);
    expect(ReportCoordinates.areValid(null, 35.2), isFalse);
    expect(ReportCoordinates.areValid(31.95, null), isFalse);
    expect(ReportCoordinates.areValid(91, 35.2), isFalse);
    expect(ReportCoordinates.areValid(31.95, 181), isFalse);
    expect(ReportCoordinates.areValid(double.nan, 35.2), isFalse);
    expect(ReportCoordinates.areValid(31.95, double.infinity), isFalse);
  });
}
