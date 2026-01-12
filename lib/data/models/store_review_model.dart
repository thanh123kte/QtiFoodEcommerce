import '../../domain/entities/store_review.dart';

class StoreReviewModel {
  final int id;
  final int orderId;
  final int storeId;
  final String storeName;
  final String customerId;
  final String customerName;
  final int rating;
  final String comment;
  final List<StoreReviewImageModel> images;
  final String? reply;
  final String? customerAvatar;
  final DateTime? repliedAt;
  final DateTime? createdAt;

  const StoreReviewModel({
    required this.id,
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.images,
    this.reply,
    this.customerAvatar,
    this.repliedAt,
    this.createdAt,
  });

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: (json['id'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      storeId: (json['storeId'] as num).toInt(),
      storeName: (json['storeName'] ?? '') as String,
      customerId: (json['customerId'] ?? '') as String,
      customerName: (json['customerName'] ?? '') as String,
      rating: (json['rating'] as num).toInt(),
      comment: (json['comment'] ?? '') as String,
        images: (json['images'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => StoreReviewImageModel.fromJson(e))
            .toList() ??
          const <StoreReviewImageModel>[],
      reply: json['reply'] as String?,
      customerAvatar: json['customerAvatar'] as String?,
      repliedAt: _parseDate(json['repliedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  StoreReview toEntity() {
    return StoreReview(
      id: id,
      orderId: orderId,
      storeId: storeId,
      storeName: storeName,
      customerId: customerId,
      customerName: customerName,
      rating: rating,
      comment: comment,
      images: images.map((e) => e.toEntity()).toList(),
      reply: reply,
      customerAvatar: customerAvatar,
      repliedAt: repliedAt,
      createdAt: createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class StoreReviewImageModel {
  final int id;
  final String imageUrl;
  final DateTime? createdAt;

  const StoreReviewImageModel({
    required this.id,
    required this.imageUrl,
    this.createdAt,
  });

  factory StoreReviewImageModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewImageModel(
      id: (json['id'] as num).toInt(),
      imageUrl: (json['imageUrl'] ?? '') as String,
      createdAt: StoreReviewModel._parseDate(json['createdAt']),
    );
  }

  StoreReviewImage toEntity() {
    return StoreReviewImage(
      id: id,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
