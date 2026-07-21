import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/sample_reports.dart';
import '../models/report.dart';
import '../widgets/report_card.dart';
import 'report_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ReportStatus? _selectedStatus;

  List<Report> get _filteredReports {
    final normalizedQuery = _query.trim().toLowerCase();

    return sampleReports.where((report) {
      final matchesStatus =
          _selectedStatus == null || report.status == _selectedStatus;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          report.title.toLowerCase().contains(normalizedQuery) ||
          report.description.toLowerCase().contains(normalizedQuery) ||
          report.category.label.toLowerCase().contains(normalizedQuery) ||
          report.location.toLowerCase().contains(normalizedQuery);
      return matchesStatus && matchesSearch;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(Report report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReportDetailsScreen(report: report),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final reports = _filteredReports;

    return Scaffold(
      appBar: AppBar(title: const Text('البلاغات')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'ابحث في البلاغات',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: _clearSearch,
                              tooltip: 'مسح البحث',
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ListView(
                    key: const Key('report-status-filters'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        selected: _selectedStatus == null,
                        onSelected: () =>
                            setState(() => _selectedStatus = null),
                      ),
                      const SizedBox(width: 8),
                      for (final status in ReportStatus.values) ...[
                        _FilterChip(
                          label: status.label,
                          selected: _selectedStatus == status,
                          onSelected: () =>
                              setState(() => _selectedStatus = status),
                        ),
                        if (status != ReportStatus.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: reports.isEmpty
                      ? const _EmptyReportsState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 152),
                          itemCount: reports.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return ReportCard(
                              report: report,
                              onTap: () => _openDetails(report),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyReportsState extends StatelessWidget {
  const _EmptyReportsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 152),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد بلاغات مطابقة',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تغيير عبارة البحث أو اختيار حالة أخرى',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
