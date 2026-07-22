import '../models/report.dart';

final sampleReports = <Report>[
  Report(
    id: 1,
    title: 'أنقاض تغلق مدخل شارع سكني',
    description:
        'تمنع الأنقاض مرور المركبات والخدمات عبر المدخل الرئيسي للشارع.',
    category: ReportCategory.roadsAndRubble,
    location: 'حي الأمل، مدينة النور',
    createdAt: DateTime(2026, 7, 20, 9, 30),
    status: ReportStatus.newReport,
  ),
  Report(
    id: 2,
    title: 'انقطاع مياه عن منطقة سكنية',
    description: 'تعاني عدة مبانٍ سكنية من انقطاع المياه منذ ساعات الصباح.',
    category: ReportCategory.waterAndSanitation,
    location: 'منطقة الوادي، بلدة الندى',
    createdAt: DateTime(2026, 7, 19, 16, 15),
    status: ReportStatus.inProgress,
  ),
  Report(
    id: 3,
    title: 'أسلاك كهرباء مكشوفة قرب الرصيف',
    description: 'توجد أسلاك كهربائية ظاهرة بجانب ممر عام وتحتاج إلى تأمين.',
    category: ReportCategory.electricity,
    location: 'حي السلام، مدينة النور',
    createdAt: DateTime(2026, 7, 18, 11),
    status: ReportStatus.newReport,
  ),
  Report(
    id: 4,
    title: 'مبنى متضرر يحتاج إلى تقييم',
    description:
        'تظهر أضرار واضحة في واجهة مبنى مدني وتلزم معاينته للتأكد من سلامته.',
    category: ReportCategory.buildingDamage,
    location: 'شارع البستان، بلدة الندى',
    createdAt: DateTime(2026, 7, 17, 13, 40),
    status: ReportStatus.inProgress,
  ),
  Report(
    id: 5,
    title: 'حاجة إلى مياه شرب ومواد أساسية',
    description:
        'تحتاج المنطقة إلى إمدادات مياه شرب وبعض المواد المنزلية الأساسية.',
    category: ReportCategory.reliefNeeds,
    location: 'حي التعاون، مدينة الأمل',
    createdAt: DateTime(2026, 7, 16, 10, 20),
    status: ReportStatus.newReport,
  ),
  Report(
    id: 6,
    title: 'تراكم نفايات في منطقة سكنية',
    description:
        'تراكمت النفايات قرب المساكن وتحتاج إلى جمع للحفاظ على الصحة العامة.',
    category: ReportCategory.wasteAndPublicHealth,
    location: 'منطقة الساحة، بلدة الندى',
    createdAt: DateTime(2026, 7, 15, 8, 45),
    status: ReportStatus.resolved,
  ),
  Report(
    id: 7,
    title: 'لوحة إرشادية ساقطة في الطريق',
    description:
        'تعيق لوحة إرشادية ساقطة جزءاً من الممر العام وتحتاج إلى إزالتها.',
    category: ReportCategory.other,
    location: 'حي الروضة، مدينة الأمل',
    createdAt: DateTime(2026, 7, 14, 14, 20),
    status: ReportStatus.resolved,
  ),
];
