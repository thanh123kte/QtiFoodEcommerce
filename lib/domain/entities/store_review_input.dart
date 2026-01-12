class StoreReviewInput {
  final int orderId;
  final int storeId;
  final String customerId;
  final int rating;
  final String? comment;
  final bool anonymous;

  const StoreReviewInput({
    required this.orderId,
    required this.storeId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.anonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'storeId': storeId,
      'customerId': customerId,
      'rating': rating,
      'comment': comment ?? '',
      'anonymous': anonymous,
    };
  }
}