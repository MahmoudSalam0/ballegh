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
    expect(find.text('لاحظت مشكلة في منطقتك؟'), findsOneWidget);
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
    expect(find.text('سيتم بناء نموذج البلاغ في مرحلة لاحقة'), findsOneWidget);

    Navigator.of(
      tester.element(find.text('سيتم بناء نموذج البلاغ في مرحلة لاحقة')),
    ).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(
      find.text('سيتم إضافة قائمة البلاغات في المرحلة التالية'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('سيتم ربط خريطة البلاغات لاحقاً'), findsOneWidget);

    await tester.tap(find.byTooltip('إضافة بلاغ'));
    await tester.pumpAndSettle();
    expect(find.text('إضافة بلاغ'), findsOneWidget);
    expect(find.text('سيتم بناء نموذج البلاغ في مرحلة لاحقة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
