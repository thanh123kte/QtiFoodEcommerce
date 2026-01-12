class CreateProductInput {
  final int storeId;
  final String? categoryId;
  final String? storeCategoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String status;

  const CreateProductInput({
    required this.storeId,
    this.categoryId,
    this.storeCategoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'categoryId': _encodeId(categoryId),
      'storeCategoryId': _encodeId(storeCategoryId),
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'status': status,
    }..removeWhere((key, value) => value == null);
  }

  dynamic _encodeId(String? source) {
    if (source == null) return null;
    final trimmed = source.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    return parsed ?? trimmed;
  }
}
