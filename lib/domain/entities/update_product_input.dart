class UpdateProductInput {
  final String? categoryId;
  final String? storeCategoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String status;

  const UpdateProductInput({
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
      'categoryId': _encodeId(categoryId),
      'storeCategoryId': _encodeId(storeCategoryId),
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'status': status,
    }..removeWhere((key, value) => value == null);
  }

  dynamic _encodeId(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    return parsed ?? trimmed;
  }
}
