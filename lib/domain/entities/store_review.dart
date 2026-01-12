class StoreReview {
  final int id;
  final int orderId;
  final int storeId;
  final String storeName;
  final String customerId;
  final String customerName;
  final int rating;
  final String comment;
  final List<StoreReviewImage> images;
  final String? reply;
  final String? customerAvatar;
  final DateTime? repliedAt;
  final DateTime? createdAt;

  const StoreReview({
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
}

class StoreReviewImage {
  final int id;
  final String imageUrl;
  final DateTime? createdAt;

  const StoreReviewImage({
    required this.id,
    required this.imageUrl,
    this.createdAt,
  });
}
