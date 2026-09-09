import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../database/database_helper.dart';
import '../models/report.dart';
import '../models/report_coordinates.dart';
import '../services/report_image_storage.dart';
import '../widgets/category_select_card.dart';
import '../widgets/report_image_picker_card.dart';
import '../widgets/report_location_card.dart';
import 'location_picker_screen.dart';

class EditReportScreen extends StatefulWidget {
  const EditReportScreen({super.key, required this.report});

  final Report report;

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late ReportCategory _selectedCategory;
  late String? _imagePath;
  late double? _latitude;
  late double? _longitude;

  bool _showCategoryError = false;
  bool _isSaving = false;
  bool _isProcessingImage = false;
  bool _isSelectingLocation = false;
  bool _imageChangesWereCommitted = false;

  bool get _isBusy => _isSaving || _isProcessingImage || _isSelectingLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
    _locationController = TextEditingController(text: widget.report.location);
    _selectedCategory = widget.report.category;
    _imagePath = widget.report.imagePath;
    _latitude = widget.report.latitude;
    _longitude = widget.report.longitude;
  }

  @override
  void dispose() {
    if (!_imageChangesWereCommitted && _imagePath != widget.report.imagePath) {
      unawaited(ReportImageStorage.instance.deleteManagedImage(_imagePath));
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectCategory(ReportCategory category) {
    if (_isBusy) {
      return;
    }

    setState(() {
      _selectedCategory = category;
      _showCategoryError = false;
    });
  }

  Future<void> _chooseImage() async {
    if (_isBusy) {
      return;
    }

    final source = await showReportImageSourceSheet(context);
    if (!mounted || source == null) {
      return;
    }

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final newImagePath = await ReportImageStorage.instance.pickAndStore(
        source,
      );
      if (newImagePath == null) {
        return;
      }

      if (!mounted) {
        await ReportImageStorage.instance.deleteManagedImage(newImagePath);
        return;
      }

      final previousImagePath = _imagePath;
      setState(() {
        _imagePath = newImagePath;
      });

      if (previousImagePath != widget.report.imagePath) {
        await ReportImageStorage.instance.deleteManagedImage(previousImagePath);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر اختيار الصورة أو حفظها، يرجى المحاولة مرة أخرى',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  void _removeImage() {
    if (_isBusy) {
      return;
    }

    final imagePath = _imagePath;
    setState(() {
      _imagePath = null;
    });

    if (imagePath != widget.report.imagePath) {
      unawaited(ReportImageStorage.instance.deleteManagedImage(imagePath));
    }
  }

  Future<void> _chooseLocation() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isSelectingLocation = true;
    });

    try {
      final coordinates = await Navigator.of(context).push<ReportCoordinates>(
        MaterialPageRoute<ReportCoordinates>(
          builder: (context) => LocationPickerScreen(
            initialLatitude: _latitude,
            initialLongitude: _longitude,
          ),
        ),
      );

      if (!mounted || coordinates == null) {
        return;
      }

      setState(() {
        _latitude = coordinates.latitude;
        _longitude = coordinates.longitude;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingLocation = false;
        });
      }
    }
  }

  void _removeLocation() {
    if (_isBusy) {
      return;
    }

    setState(() {
      _latitude = null;
      _longitude = null;
    });
  }

  Future<void> _save() async {
    if (_isBusy) {
      return;
    }

    FocusScope.of(context).unfocus();

    final fieldsAreValid = _formKey.currentState?.validate() ?? false;
    final categoryIsValid = ReportCategory.values.contains(_selectedCategory);

    setState(() {
      _showCategoryError = !categoryIsValid;
    });

    if (!fieldsAreValid || !categoryIsValid) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedReport = Report(
      id: widget.report.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      imagePath: _imagePath,
      createdAt: widget.report.createdAt,
      status: widget.report.status,
    );

    try {
      final updatedRows = await DatabaseHelper.instance.updateReport(
        updatedReport,
      );

      if (updatedRows != 1) {
        throw StateError('لم يتم تحديث صف واحد');
      }

      _imageChangesWereCommitted = true;
      if (widget.report.imagePath != _imagePath) {
        await ReportImageStorage.instance.deleteManagedImage(
          widget.report.imagePath,
        );
      }

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 36,
            ),
            title: const Text('تم تحديث البلاغ', textAlign: TextAlign.center),
            content: const Text(
              'تم حفظ التعديلات بنجاح.',
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

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updatedReport);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تعذر تحديث البلاغ، يرجى المحاولة مرة أخرى'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل البلاغ')),
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
                      'حدّث بيانات البلاغ ثم احفظ التغييرات.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _EditCategorySection(
                      selectedCategory: _selectedCategory,
                      showError: _showCategoryError,
                      enabled: !_isBusy,
                      onSelected: _selectCategory,
                    ),
                    const SizedBox(height: 16),
                    ReportImagePickerCard(
                      imagePath: _imagePath,
                      isLoading: _isProcessingImage,
                      enabled: !_isSaving,
                      onChoose: _chooseImage,
                      onRemove: _removeImage,
                    ),
                    const SizedBox(height: 16),
                    _EditFieldsSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      locationController: _locationController,
                      enabled: !_isBusy,
                    ),
                    const SizedBox(height: 16),
                    ReportLocationCard(
                      latitude: _latitude,
                      longitude: _longitude,
                      isLoading: _isSelectingLocation,
                      enabled: !_isSaving && !_isProcessingImage,
                      onOpen: _chooseLocation,
                      onRemove: _removeLocation,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('save-report-changes'),
                      onPressed: _isBusy ? null : _save,
                      icon: _isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving ? 'جارٍ حفظ التعديلات...' : 'حفظ التعديلات',
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

class _EditCategorySection extends StatelessWidget {
  const _EditCategorySection({
    required this.selectedCategory,
    required this.showError,
    required this.enabled,
    required this.onSelected,
  });

  final ReportCategory selectedCategory;
  final bool showError;
  final bool enabled;
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
                        child: CategorySelectCard(
                          key: Key('edit-category-${category.name}'),
                          category: category,
                          selected: selectedCategory == category,
                          enabled: enabled,
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

class _EditFieldsSection extends StatelessWidget {
  const _EditFieldsSection({
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.enabled,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool enabled;

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
              key: const Key('edit-report-title-field'),
              controller: titleController,
              enabled: enabled,
              maxLength: 70,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'عنوان البلاغ'),
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return 'يرجى إدخال عنوان البلاغ';
                if (title.length < 5) {
                  return 'يجب ألا يقل عنوان البلاغ عن 5 أحرف';
                }
                if (title.length > 70) {
                  return 'يجب ألا يزيد عنوان البلاغ عن 70 حرفًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('edit-report-description-field'),
              controller: descriptionController,
              enabled: enabled,
              minLines: 4,
              maxLines: 5,
              maxLength: 500,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'وصف المشكلة',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final description = value?.trim() ?? '';
                if (description.isEmpty) return 'يرجى إدخال وصف المشكلة';
                if (description.length < 15) {
                  return 'يجب ألا يقل وصف المشكلة عن 15 حرفًا';
                }
                if (description.length > 500) {
                  return 'يجب ألا يزيد وصف البلاغ عن 500 حرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('edit-report-location-field'),
              controller: locationController,
              enabled: enabled,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'اسم الموقع',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
