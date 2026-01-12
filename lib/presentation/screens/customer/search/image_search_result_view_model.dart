import 'package:flutter/material.dart';

import '../dashboard/customer_dashboard_view_model.dart';
import '../../../../domain/usecases/product/get_products.dart';

class ImageSearchResultViewModel extends ChangeNotifier {
  final GetFeaturedProducts _getFeaturedProducts;
  final List<String> _productIds;

  List<DashboardProductTile> _results = const [];
  bool _isLoading = false;
  String? _error;

  List<DashboardProductTile> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ImageSearchResultViewModel(
    this._getFeaturedProducts,
    this._productIds,
  ) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_productIds.isEmpty) {
      _results = const [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getFeaturedProducts(page: 1, limit: 100);
    result.when(
      ok: (items) {
        final matchedProducts = items
            .where((product) => _productIds.contains(product.id))
            .map((product) {
              String? imageUrl;
              if (product.images.isNotEmpty) {
                final primaryImage = product.images.firstWhere(
                  (img) => img.isPrimary == true,
                  orElse: () => product.images.first,
                );
                imageUrl = primaryImage.imageUrl;
              }

              return DashboardProductTile(
                id: product.id,
                name: product.name,
                imageUrl: imageUrl,
                description: product.description,
                price: product.price,
                discountPrice: product.discountPrice,
                status: product.status,
                imageUrls: product.images.map((img) => img.imageUrl).toList(),
                storeId: product.storeId,
                rating: 0.0,
                reviewCount: 0,
              );
            })
            .toList();
        _results = List.unmodifiable(matchedProducts);
        _error = null;
      },
      err: (message) {
        _results = const [];
        _error = message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
