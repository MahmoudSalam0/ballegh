import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'add_report_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'reports_screen.dart';
import '../database/database_helper.dart';
import '../models/report.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  List<Report> _homeReports = [];
  bool _isHomeLoading = true;
  int _reportsRefreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadHomeReports();
  }

  Future<void> _loadHomeReports() async {
    try {
      final reports = await DatabaseHelper.instance.getAllReports();

      if (!mounted) {
        return;
      }

      setState(() {
        _homeReports = reports;
        _isHomeLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isHomeLoading = false;
      });
    }
  }

  void _showReports() {
    setState(() => _selectedIndex = 1);
  }

  Future<void> _openAddReport() async {
    final reportWasSaved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const AddReportScreen()),
    );

    if (reportWasSaved != true) {
      return;
    }

    await _refreshReportScreens(false);
  }

  Future<void> _refreshReportScreens(bool reportWasDeleted) async {
    if (reportWasDeleted && mounted) {
      setState(() {
        _isHomeLoading = true;
      });
    }

    await _loadHomeReports();

    if (!mounted) {
      return;
    }

    setState(() {
      _reportsRefreshVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onViewAllReports: _showReports,
        onAddReport: _openAddReport,
        onReportDetailsClosed: _refreshReportScreens,
        reports: _homeReports,
        isLoading: _isHomeLoading,
      ),
      ReportsScreen(key: ValueKey(_reportsRefreshVersion)),
      const MapScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
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
