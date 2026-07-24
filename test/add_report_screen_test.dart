import 'package:ballegh_app/core/theme/app_theme.dart';
import 'package:ballegh_app/screens/add_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen() {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AddReportScreen(),
    );
  }

  void usePhoneSize(WidgetTester tester, [Size size = const Size(390, 844)]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('تعرض شاشة إضافة البلاغ كاملة دون overflow', (tester) async {
    usePhoneSize(tester, const Size(360, 800));
    await tester.pumpWidget(buildScreen());

    expect(find.text('إضافة بلاغ'), findsOneWidget);
    expect(
      find.text(
        'أضف تفاصيل واضحة عن الضرر أو الاحتياج المدني لمساعدتنا في تنظيم ومتابعة البلاغات.',
      ),
      findsOneWidget,
    );
    expect(find.text('تنبيه مهم'), findsOneWidget);
    expect(
      find.text(
        'التطبيق مخصص لتنظيم البلاغات المدنية، وليس بديلاً عن خدمات الطوارئ. عند وجود خطر مباشر تواصل مع الجهات المتاحة.',
      ),
      findsOneWidget,
    );
    expect(find.text('ما نوع المشكلة؟'), findsOneWidget);
    expect(find.text('الطرق والأنقاض'), findsOneWidget);
    expect(find.text('المياه والصرف الصحي'), findsOneWidget);
    expect(find.text('الكهرباء'), findsOneWidget);
    expect(find.text('أضرار المباني'), findsOneWidget);
    expect(find.text('احتياجات إغاثية'), findsOneWidget);
    expect(find.text('النفايات والصحة العامة'), findsOneWidget);
    expect(find.text('أخرى'), findsOneWidget);
    expect(find.text('أضف صورة للمشكلة'), findsOneWidget);
    expect(find.text('عنوان البلاغ'), findsOneWidget);
    expect(find.text('وصف المشكلة'), findsOneWidget);
    expect(find.text('موقع المشكلة'), findsOneWidget);
    expect(find.text('إرسال البلاغ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('يعرض أخطاء التحقق عند إرسال نموذج فارغ', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildScreen());

    await tester.ensureVisible(find.byKey(const Key('submit-report')));
    await tester.tap(find.byKey(const Key('submit-report')));
    await tester.pump();

    expect(find.text('يرجى اختيار نوع المشكلة'), findsOneWidget);
    expect(find.text('يرجى إدخال عنوان البلاغ'), findsOneWidget);
    expect(find.text('يرجى إدخال وصف المشكلة'), findsOneWidget);
    expect(find.text('البيانات جاهزة'), findsNothing);
  });

  testWidgets('يعرض تأكيد النجاح عند صحة البيانات', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildScreen());

    await tester.tap(find.byKey(const Key('category-roadsAndRubble')));
    await tester.ensureVisible(find.byKey(const Key('report-title-field')));
    await tester.enterText(
      find.byKey(const Key('report-title-field')),
      'حفرة كبيرة في الشارع الرئيسي',
    );
    await tester.ensureVisible(
      find.byKey(const Key('report-description-field')),
    );
    await tester.enterText(
      find.byKey(const Key('report-description-field')),
      'توجد حفرة عميقة تعيق حركة المركبات وتحتاج إلى إصلاح سريع.',
    );
    await tester.ensureVisible(find.byKey(const Key('submit-report')));
    await tester.tap(find.byKey(const Key('submit-report')));
    await tester.pumpAndSettle();

    expect(find.text('تم حفظ البلاغ'), findsOneWidget);
    expect(
      find.text(
        'تم التحقق من بيانات البلاغ، وسيتم حفظها بعد ربط قاعدة البيانات.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('تعرض رسائل مؤقتة لأزرار الصور والموقع', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildScreen());

    final cameraAction = find.byKey(const Key('camera-placeholder'));
    await tester.ensureVisible(cameraAction);
    await tester.tap(cameraAction);
    await tester.pump();
    expect(find.text('سيتم ربط الصور في مرحلة لاحقة'), findsOneWidget);

    final galleryAction = find.byKey(const Key('gallery-placeholder'));
    await tester.tap(galleryAction);
    await tester.pump();
    expect(find.text('سيتم ربط الصور في مرحلة لاحقة'), findsOneWidget);

    final locationAction = find.byKey(const Key('location-placeholder'));
    await tester.ensureVisible(locationAction);
    await tester.tap(locationAction);
    await tester.pump();
    expect(find.text('سيتم ربط الموقع في مرحلة لاحقة'), findsOneWidget);
    expect(find.text('لم يتم تحديد الموقع'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
