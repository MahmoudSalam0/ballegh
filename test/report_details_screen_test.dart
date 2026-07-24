import 'package:ballegh_app/core/theme/app_theme.dart';
import 'package:ballegh_app/models/report.dart';
import 'package:ballegh_app/screens/report_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen(Report report) {
    return MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: ReportDetailsScreen(report: report),
    );
  }

  testWidgets('تعرض جميع تفاصيل البلاغ المتاحة للقراءة فقط', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final report = Report(
      id: 24,
      title: 'تضرر في الطريق الرئيسي',
      description:
          'يوجد تضرر واضح في الطريق يعيق مرور المركبات ويحتاج إلى معالجة.',
      category: ReportCategory.roadsAndRubble,
      location: 'شارع البلدية، غزة',
      latitude: 31.501234,
      longitude: 34.452345,
      imagePath: 'مسار/غير/موجود.jpg',
      createdAt: DateTime(2026, 7, 24, 14, 5),
      status: ReportStatus.inProgress,
    );

    await tester.pumpWidget(buildScreen(report));

    expect(find.text('تفاصيل البلاغ'), findsOneWidget);
    expect(find.text('بلاغ رقم ٢٤'), findsOneWidget);
    expect(find.text(report.title), findsOneWidget);
    expect(find.text('قيد المعالجة'), findsOneWidget);
    expect(find.text('الطرق والأنقاض'), findsOneWidget);
    expect(find.text(report.description), findsOneWidget);
    expect(find.text(report.location), findsOneWidget);
    expect(find.text('٢٤ يوليو ٢٠٢٦، ٢:٠٥ م'), findsOneWidget);
    expect(find.text('لا توجد صورة متاحة لهذا البلاغ'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('الإحداثيات'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('٣١.٥٠١٢٣٤'), findsOneWidget);
    expect(find.text('٣٤.٤٥٢٣٤٥'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('تخفي الرقم والإحداثيات عندما لا تكون موجودة', (tester) async {
    final report = Report(
      title: 'بلاغ دون رقم أو إحداثيات',
      description: 'وصف كامل لبلاغ لا يحتوي على رقم أو إحداثيات.',
      category: ReportCategory.other,
      location: 'لم يتم تحديد الموقع',
      createdAt: DateTime(2026, 1, 1, 9, 30),
      status: ReportStatus.newReport,
    );

    await tester.pumpWidget(buildScreen(report));

    expect(find.textContaining('بلاغ رقم'), findsNothing);
    expect(find.text('الإحداثيات'), findsNothing);
    expect(find.text('لا توجد صورة متاحة لهذا البلاغ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
