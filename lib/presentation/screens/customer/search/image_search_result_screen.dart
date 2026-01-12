import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/currency_formatter.dart';
import '../dashboard/customer_dashboard_view_model.dart';
import '../dashboard/customer_product_detail_screen.dart';
import 'image_search_result_view_model.dart';

const Color _searchAccent = Color(0xFFFF8A3D);
const Color _searchBackground = Color(0xFFFFF8F2);
const Color _searchSurface = Colors.white;
const Color _searchBorder = Color(0xFFFFE3CF);
const Color _searchMuted = Color(0xFF8B8B8B);

class ImageSearchResultScreen extends StatelessWidget {
  final String imagePath;
  final ImageSearchResultViewModel viewModel;
  final String? customerId;

  const ImageSearchResultScreen({
    super.key,
    required this.imagePath,
    required this.viewModel,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImageSearchResultViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: _searchBackground,
        appBar: AppBar(
          backgroundColor: _searchBackground,
          surfaceTintColor: _searchBackground,
          foregroundColor: _searchAccent,
          elevation: 0,
          title: const Text('Kết quả tìm kiếm', style: TextStyle(fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // Image preview
            Container(
              height: 120,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _searchBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6)),
                ],
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Results
            Expanded(
              child: Consumer<ImageSearchResultViewModel>(
                builder: (_, vm, __) {
                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _searchAccent),
                    );
                  }

                  if (vm.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              vm.error!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vm.loadProducts(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _searchAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (vm.results.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: _searchAccent,
                          ),
                          SizedBox(height: 8),
                          Text('Không tìm thấy sản phẩm phù hợp', style: TextStyle(color: _searchMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final product = vm.results[index];
                      return _ProductResultTile(
                        product: product,
                        customerId: customerId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  final DashboardProductTile product;
  final String? customerId;

  const _ProductResultTile({
    required this.product,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final status = product.status.trim().toUpperCase();
    final isUnavailable = status.contains('UNAVAILABLE');
    return Opacity(
      opacity: isUnavailable ? 0.5 : 1,
      child: GestureDetector(
        onTap: isUnavailable
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomerProductDetailScreen(
                      product: product,
                      customerId: customerId,
                    ),
                  ),
                );
              },
        child: Card(
          margin: EdgeInsets.zero,
          color: _searchSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _searchBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  color: _searchBackground,
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (product.description != null)
                        Text(
                          product.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _searchMuted,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            formatCurrency(product.discountPrice ?? product.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _searchAccent,
                            ),
                          ),
                          if (product.discountPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                formatCurrency(product.price),
                                style: const TextStyle(
                                  color: _searchMuted,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: _searchAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
