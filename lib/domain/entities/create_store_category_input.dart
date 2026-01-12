class CreateStoreCategoryInput {
  final int storeId;
  final String name;
  final String? description;
  final int parentCategoryId;

  const CreateStoreCategoryInput({
    required this.storeId,
    required this.name,
    this.description,
    required this.parentCategoryId,
  });

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'name': name,
        'description': description,
        'categoryId': parentCategoryId,
      };
}

class UpdateStoreCategoryInput {
  final String name;
  final String? description;
  final int parentCategoryId;

  const UpdateStoreCategoryInput({
    required this.name,
    this.description,
    required this.parentCategoryId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'categoryId': parentCategoryId,
      };
}
