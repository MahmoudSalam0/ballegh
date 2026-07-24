import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report.dart';
import '../widgets/report_card.dart';
import '../widgets/statistic_card.dart';
import 'report_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onViewAllReports,
    required this.onAddReport,
    required this.reports,
    required this.isLoading,
  });

  final VoidCallback onViewAllReports;
  final VoidCallback onAddReport;
  final List<Report> reports;
  final bool isLoading;

  void _openReportDetails(BuildContext context, Report report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReportDetailsScreen(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inProgressCount = reports
        .where((report) => report.status == ReportStatus.inProgress)
        .length;
    final resolvedCount = reports
        .where((report) => report.status == ReportStatus.resolved)
        .length;
    final latestReports = [...reports]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 152),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AppHeader(),
                  const SizedBox(height: 24),
                  _HeroCard(onAddReport: onAddReport),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'نظرة عامة'),
                  const SizedBox(height: 14),
                  _StatisticsSection(
                    total: reports.length,
                    inProgress: inProgressCount,
                    resolved: resolvedCount,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(title: 'أحدث البلاغات'),
                      ),
                      TextButton(
                        onPressed: onViewAllReports,
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (latestReports.isEmpty)
                    const _NoReportsYet()
                  else
                    _LatestReportsList(
                      reports: latestReports.take(3).toList(),
                      onReportTap: (report) =>
                          _openReportDetails(context, report),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/ballegh.jpeg',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            semanticLabel: 'شعار بلّغ',
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: AppColors.primary,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.place_rounded,
                    color: AppColors.surface,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بلّغ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'معاً لمكان أفضل',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onAddReport});

  final VoidCallback onAddReport;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth * 0.72).clamp(260.0, 290.0);
        final compact = constraints.maxWidth < 360;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/ballegh2.jpeg',
                    width: double.infinity,
                    height: height,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    semanticLabel: 'شخص يرسل بلاغاً عن مشكلة في الشارع',
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(color: AppColors.primary);
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.64),
                          AppColors.primary.withValues(alpha: 0.42),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(compact ? 18 : 22),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'شاهدت ضرراً أو احتياجاً في منطقتك؟',
                              textAlign: TextAlign.right,
                              style:
                                  (compact
                                          ? Theme.of(
                                              context,
                                            ).textTheme.titleMedium
                                          : Theme.of(
                                              context,
                                            ).textTheme.titleLarge)
                                      ?.copyWith(
                                        color: AppColors.surface,
                                        fontWeight: FontWeight.w800,
                                        height: 1.35,
                                      ),
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            Text(
                              'أرسل بلاغاً مدنياً وساهم في تنظيم احتياجات مجتمعك.',
                              textAlign: TextAlign.right,
                              style:
                                  (compact
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodySmall
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium)
                                      ?.copyWith(
                                        color: AppColors.surface,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                            ),
                            SizedBox(height: compact ? 16 : 20),
                            FilledButton.icon(
                              onPressed: onAddReport,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              label: const Text('أضف بلاغاً'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({
    required this.total,
    required this.inProgress,
    required this.resolved,
  });

  final int total;
  final int inProgress;
  final int resolved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          StatisticCard(
            title: 'إجمالي البلاغات',
            value: total.toString(),
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
          ),
          StatisticCard(
            title: 'قيد المعالجة',
            value: inProgress.toString(),
            icon: Icons.schedule_rounded,
            color: AppColors.accent,
          ),
          StatisticCard(
            title: 'تم الحل',
            value: resolved.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ];

        if (constraints.maxWidth < 380) {
          return Column(
            children: [
              StatisticCard(
                title: 'إجمالي البلاغات',
                value: total.toString(),
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
                horizontal: true,
              ),
              const SizedBox(height: 10),
              StatisticCard(
                title: 'قيد المعالجة',
                value: inProgress.toString(),
                icon: Icons.schedule_rounded,
                color: AppColors.accent,
                horizontal: true,
              ),
              const SizedBox(height: 10),
              StatisticCard(
                title: 'تم الحل',
                value: resolved.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                horizontal: true,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
            const SizedBox(width: 10),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class _LatestReportsList extends StatelessWidget {
  const _LatestReportsList({required this.reports, required this.onReportTap});

  final List<Report> reports;
  final ValueChanged<Report> onReportTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < reports.length; index++) ...[
          ReportCard(
            report: reports[index],
            onTap: () => onReportTap(reports[index]),
          ),
          if (index < reports.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _NoReportsYet extends StatelessWidget {
  const _NoReportsYet();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد بلاغات حتى الآن',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'أضف أول بلاغ ليظهر هنا',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
