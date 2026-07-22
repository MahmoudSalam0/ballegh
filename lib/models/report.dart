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
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    this.imagePath,
    required this.createdAt,
    required this.status,
  });

  final int? id;
  final String title;
  final String description;
  final ReportCategory category;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final DateTime createdAt;
  final ReportStatus status;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Report.fromMap(Map<String, Object?> map) {
    return Report(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      category: ReportCategory.values.byName(map['category'] as String),
      location: map['location'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: ReportStatus.values.byName(map['status'] as String),
    );
  }
}
