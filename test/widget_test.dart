import 'package:ballegh_app/app.dart';
import 'package:ballegh_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('يعرض الصفحة الرئيسية بهوية بلّغ العربية', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BalleghApp());

    expect(find.text('بلّغ'), findsOneWidget);
    expect(find.text('معاً لمكان أفضل'), findsOneWidget);
    expect(find.text('شاهدت ضرراً أو احتياجاً في منطقتك؟'), findsOneWidget);
    expect(find.text('إجمالي البلاغات'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
    expect(find.text('أنقاض تغلق مدخل شارع سكني'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('البلاغات'), findsOneWidget);
    expect(find.text('الخريطة'), findsOneWidget);

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName);
    expect(assetNames, contains('assets/images/ballegh.jpeg'));
    expect(assetNames, contains('assets/images/ballegh2.jpeg'));

    final textContext = tester.element(find.text('معاً لمكان أفضل'));
    expect(Directionality.of(textContext), TextDirection.rtl);
    expect(Theme.of(textContext).colorScheme.primary, AppColors.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('يتنقل بين الصفحات ويفتح شاشة إضافة البلاغ', (tester) async {
    await tester.pumpWidget(const BalleghApp());

    await tester.tap(find.text('أضف بلاغاً'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'أضف تفاصيل واضحة عن الضرر أو الاحتياج المدني لمساعدتنا في تنظيم ومتابعة البلاغات.',
      ),
      findsOneWidget,
    );

    Navigator.of(
      tester.element(
        find.text(
          'أضف تفاصيل واضحة عن الضرر أو الاحتياج المدني لمساعدتنا في تنظيم ومتابعة البلاغات.',
        ),
      ),
    ).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('أنقاض تغلق مدخل شارع سكني'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('سيتم ربط خريطة البلاغات لاحقاً'), findsOneWidget);

    await tester.tap(find.byTooltip('إضافة بلاغ'));
    await tester.pumpAndSettle();
    expect(find.text('إضافة بلاغ'), findsOneWidget);
    expect(find.byKey(const Key('submit-report')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('يعرض الكل ويجمع البحث مع تصفية الحالة', (tester) async {
    tester.view.physicalSize = const Size(430, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BalleghApp());

    await tester.ensureVisible(find.text('عرض الكل'));
    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  الصرف الصحي  ');
    await tester.pump();
    expect(find.text('انقطاع مياه عن منطقة سكنية'), findsOneWidget);
    expect(find.text('أنقاض تغلق مدخل شارع سكني'), findsNothing);

    await tester.enterText(find.byType(TextField), 'بلاغ غير موجود');
    await tester.pump();
    expect(find.text('لا توجد بلاغات مطابقة'), findsOneWidget);
    expect(
      find.text('جرّب تغيير عبارة البحث أو اختيار حالة أخرى'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('مسح البحث'));
    await tester.pump();
    final resolvedFilter = find.widgetWithText(ChoiceChip, 'تم الحل');
    await tester.drag(
      find.byKey(const Key('report-status-filters')),
      const Offset(180, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(resolvedFilter);
    await tester.pump();
    expect(find.text('تراكم نفايات في منطقة سكنية'), findsOneWidget);
    expect(find.text('لوحة إرشادية ساقطة في الطريق'), findsOneWidget);
    expect(find.text('أنقاض تغلق مدخل شارع سكني'), findsNothing);

    await tester.enterText(find.byType(TextField), 'الصحة العامة');
    await tester.pump();
    expect(find.text('تراكم نفايات في منطقة سكنية'), findsOneWidget);
    expect(find.text('لوحة إرشادية ساقطة في الطريق'), findsNothing);

    await tester.tap(find.text('تراكم نفايات في منطقة سكنية'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل البلاغ'), findsOneWidget);
    expect(
      find.text('سيتم بناء تفاصيل البلاغ كاملة في المرحلة التالية'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
