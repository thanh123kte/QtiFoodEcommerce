class StoreCategory {
  final int id;
  final int storeId;
  final String name;
  final String? description;
  final int? parentCategoryId;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoreCategory({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    this.parentCategoryId,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });
}
