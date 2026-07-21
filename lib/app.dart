import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'screens/main_shell.dart';

class BalleghApp extends StatelessWidget {
  const BalleghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بلّغ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainShell(),
    );
  }
}
