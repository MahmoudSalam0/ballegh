import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report.dart';
import '../widgets/category_icon.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReportCategory? _selectedCategory;
  bool _showCategoryError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectCategory(ReportCategory category) {
    setState(() {
      _selectedCategory = category;
      _showCategoryError = false;
    });
  }

  void _showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final fieldsAreValid = _formKey.currentState?.validate() ?? false;
    final categoryIsValid = _selectedCategory != null;

    setState(() => _showCategoryError = !categoryIsValid);

    if (!fieldsAreValid || !categoryIsValid) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          title: const Text('البيانات جاهزة', textAlign: TextAlign.center),
          content: const Text(
            'تم التحقق من بيانات البلاغ، وسيتم حفظها بعد ربط قاعدة البيانات.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة بلاغ')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20, 12, 20, keyboardInset + 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'أضف تفاصيل واضحة عن الضرر أو الاحتياج المدني لمساعدتنا في تنظيم ومتابعة البلاغات.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _CivilianUseNotice(),
                    const SizedBox(height: 18),
                    _CategorySection(
                      selectedCategory: _selectedCategory,
                      showError: _showCategoryError,
                      onSelected: _selectCategory,
                    ),
                    const SizedBox(height: 16),
                    _ImagePlaceholder(
                      onCameraPressed: () => _showPlaceholderMessage(
                        'سيتم ربط الصور في مرحلة لاحقة',
                      ),
                      onGalleryPressed: () => _showPlaceholderMessage(
                        'سيتم ربط الصور في مرحلة لاحقة',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailsSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                    ),
                    const SizedBox(height: 16),
                    _LocationPlaceholder(
                      onPressed: () => _showPlaceholderMessage(
                        'سيتم ربط الموقع في مرحلة لاحقة',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('submit-report'),
                        onPressed: _submit,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('إرسال البلاغ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CivilianUseNotice extends StatelessWidget {
  const _CivilianUseNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيه مهم',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'التطبيق مخصص لتنظيم البلاغات المدنية، وليس بديلاً عن خدمات الطوارئ. عند وجود خطر مباشر تواصل مع الجهات المتاحة.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.selectedCategory,
    required this.showError,
    required this.onSelected,
  });

  final ReportCategory? selectedCategory;
  final bool showError;
  final ValueChanged<ReportCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ما نوع المشكلة؟',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = constraints.maxWidth >= 520 ? 3 : 2;
                const spacing = 10.0;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columnCount - 1)) /
                    columnCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in ReportCategory.values)
                      SizedBox(
                        width: itemWidth,
                        child: _CategoryChoice(
                          category: category,
                          selected: selectedCategory == category,
                          onTap: () => onSelected(category),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (showError) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'يرجى اختيار نوع المشكلة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ReportCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.07)
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('category-${category.name}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CategoryIcon(category: category),
                const SizedBox(height: 8),
                Text(
                  category.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 29,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'أضف صورة للمشكلة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'الصورة تساعد في توضيح البلاغ',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final cameraButton = OutlinedButton.icon(
                  key: const Key('camera-placeholder'),
                  onPressed: onCameraPressed,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('التقاط صورة'),
                );
                final galleryButton = OutlinedButton.icon(
                  key: const Key('gallery-placeholder'),
                  onPressed: onGalleryPressed,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('اختيار من المعرض'),
                );

                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cameraButton,
                      const SizedBox(height: 10),
                      galleryButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: cameraButton),
                    const SizedBox(width: 10),
                    Expanded(child: galleryButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل المشكلة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('report-title-field'),
              controller: titleController,
              maxLength: 70,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'عنوان البلاغ',
                hintText: 'مثال: حفرة كبيرة في الشارع',
              ),
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return 'يرجى إدخال عنوان البلاغ';
                if (title.length < 5) {
                  return 'يجب ألا يقل عنوان البلاغ عن 5 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('report-description-field'),
              controller: descriptionController,
              minLines: 4,
              maxLines: 5,
              maxLength: 500,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'وصف المشكلة',
                hintText: 'اشرح المشكلة بوضوح وما الذي لاحظته في الموقع',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final description = value?.trim() ?? '';
                if (description.isEmpty) return 'يرجى إدخال وصف المشكلة';
                if (description.length < 15) {
                  return 'يجب ألا يقل وصف المشكلة عن 15 حرفًا';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPlaceholder extends StatelessWidget {
  const _LocationPlaceholder({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'موقع المشكلة',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'لم يتم تحديد الموقع',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('location-placeholder'),
              onPressed: onPressed,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('تحديد موقعي الحالي'),
            ),
          ],
        ),
      ),
    );
  }
}
