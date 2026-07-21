import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'add_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 124),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AppHeader(),
                  const SizedBox(height: 24),
                  _HeroCard(onAddReport: () => _openAddReport(context)),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'نظرة عامة'),
                  const SizedBox(height: 14),
                  const _StatisticsSection(),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'أحدث البلاغات'),
                  const SizedBox(height: 14),
                  const _LatestReportsPlaceholder(),
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
                    padding: const EdgeInsets.all(22),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لاحظت مشكلة في منطقتك؟',
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'أرسل بلاغاً وساهم في تحسين المكان من حولك',
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.surface,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 20),
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
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cards = [
          _StatisticCard(
            title: 'إجمالي البلاغات',
            value: '12',
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
          ),
          _StatisticCard(
            title: 'قيد المعالجة',
            value: '5',
            icon: Icons.schedule_rounded,
            color: AppColors.accent,
          ),
          _StatisticCard(
            title: 'تم الحل',
            value: '7',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ];

        if (constraints.maxWidth < 380) {
          return const Column(
            children: [
              _StatisticCard.horizontal(
                title: 'إجمالي البلاغات',
                value: '12',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
              ),
              SizedBox(height: 10),
              _StatisticCard.horizontal(
                title: 'قيد المعالجة',
                value: '5',
                icon: Icons.schedule_rounded,
                color: AppColors.accent,
              ),
              SizedBox(height: 10),
              _StatisticCard.horizontal(
                title: 'تم الحل',
                value: '7',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
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

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : horizontal = false;

  const _StatisticCard.horizontal({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : horizontal = true;

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 21),
    );
    final valueText = Text(
      value,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    );
    final titleText = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.35,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: horizontal
            ? Row(
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(child: titleText),
                  const SizedBox(width: 12),
                  valueText,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(height: 14),
                  valueText,
                  const SizedBox(height: 4),
                  titleText,
                ],
              ),
      ),
    );
  }
}

class _LatestReportsPlaceholder extends StatelessWidget {
  const _LatestReportsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: AppColors.primary,
                size: 27,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'ستظهر أحدث البلاغات هنا',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
