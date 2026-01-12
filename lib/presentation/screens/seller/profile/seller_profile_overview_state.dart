import '../../../../domain/entities/store.dart';

class SellerProfileViewData {
  final int storeId;
  final String name;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final String? address;
  final String? description;
  final StoreDayTime? openTime;
  final StoreDayTime? closeTime;

  const SellerProfileViewData({
    required this.storeId,
    required this.name,
    this.avatarUrl,
    this.email,
    this.phone,
    this.address,
    this.description,
    this.openTime,
    this.closeTime,
  });

  SellerProfileViewData copyWith({
    int? storeId,
    String? name,
    String? avatarUrl,
    String? email,
    String? phone,
    String? address,
    String? description,
    StoreDayTime? openTime,
    StoreDayTime? closeTime,
  }) {
    return SellerProfileViewData(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  factory SellerProfileViewData.fromStore(Store store) {
    return SellerProfileViewData(
      storeId: store.id,
      name: store.name.isNotEmpty ? store.name : 'Cua hang cua toi',
      avatarUrl: store.imageUrl.isNotEmpty ? store.imageUrl : null,
      email: store.email.isNotEmpty ? store.email : null,
      phone: store.phone.isNotEmpty ? store.phone : null,
      address: store.address.isNotEmpty ? store.address : null,
      description: store.description.isNotEmpty ? store.description : null,
      openTime: store.openTime,
      closeTime: store.closeTime,
    );
  }
}

class SellerStoreReviewViewData {
  final int id;
  final String initials;
  final String author;
  final String comment;
  final double rating;
  final String dateLabel;
  final String? reply;
  final String? replyDateLabel;
  final String? avatarUrl;
  final List<String> imageUrls;

  const SellerStoreReviewViewData({
    required this.id,
    required this.initials,
    required this.author,
    required this.comment,
    required this.rating,
    required this.dateLabel,
    this.reply,
    this.replyDateLabel,
    this.avatarUrl,
    this.imageUrls = const [],
  });

  SellerStoreReviewViewData copyWith({
    String? initials,
    String? author,
    String? comment,
    double? rating,
    String? dateLabel,
    String? reply,
    String? replyDateLabel,
    String? avatarUrl,
    List<String>? imageUrls,
  }) {
    return SellerStoreReviewViewData(
      id: id,
      initials: initials ?? this.initials,
      author: author ?? this.author,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      dateLabel: dateLabel ?? this.dateLabel,
      reply: reply ?? this.reply,
      replyDateLabel: replyDateLabel ?? this.replyDateLabel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

sealed class SellerProfileOverviewState {
  const SellerProfileOverviewState();
}

class SellerProfileOverviewInitial extends SellerProfileOverviewState {
  const SellerProfileOverviewInitial();
}

class SellerProfileOverviewLoading extends SellerProfileOverviewState {
  const SellerProfileOverviewLoading();
}

class SellerProfileOverviewLoaded extends SellerProfileOverviewState {
  final SellerProfileViewData data;
  final List<SellerStoreReviewViewData> reviews;

  const SellerProfileOverviewLoaded(this.data, {this.reviews = const []});

  SellerProfileOverviewLoaded copyWith({SellerProfileViewData? data, List<SellerStoreReviewViewData>? reviews}) {
    return SellerProfileOverviewLoaded(
      data ?? this.data,
      reviews: reviews ?? this.reviews,
    );
  }
}

class SellerProfileOverviewError extends SellerProfileOverviewState {
  final String message;

  const SellerProfileOverviewError(this.message);
}
