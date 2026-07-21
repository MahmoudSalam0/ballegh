enum ReportCategory {
  roadsAndRubble,
  waterAndSanitation,
  electricity,
  buildingDamage,
  reliefNeeds,
  wasteAndPublicHealth,
  other,
}

enum ReportStatus { newReport, inProgress, resolved }

extension ReportCategoryLabel on ReportCategory {
  String get label => switch (this) {
    ReportCategory.roadsAndRubble => 'الطرق والأنقاض',
    ReportCategory.waterAndSanitation => 'المياه والصرف الصحي',
    ReportCategory.electricity => 'الكهرباء',
    ReportCategory.buildingDamage => 'أضرار المباني',
    ReportCategory.reliefNeeds => 'احتياجات إغاثية',
    ReportCategory.wasteAndPublicHealth => 'النفايات والصحة العامة',
    ReportCategory.other => 'أخرى',
  };
}

extension ReportStatusLabel on ReportStatus {
  String get label => switch (this) {
    ReportStatus.newReport => 'جديد',
    ReportStatus.inProgress => 'قيد المعالجة',
    ReportStatus.resolved => 'تم الحل',
  };
}

class Report {
  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final String location;
  final DateTime createdAt;
  final ReportStatus status;
}
