class BannerEntity {
  final int id;
  final String title;
  final String imageUrl;
  final String description;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });
}
