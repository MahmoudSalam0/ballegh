import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'add_report_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _screens = [HomeScreen(), ReportsScreen(), MapScreen()];

  void _openAddReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddReport,
        tooltip: 'إضافة بلاغ',
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'بلاغ جديد',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'البلاغات',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'الخريطة',
            ),
          ],
        ),
      ),
    );
  }
}
