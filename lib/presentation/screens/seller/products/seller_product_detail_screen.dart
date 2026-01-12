import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:datn_foodecommerce_flutter_app/utils/resolve_image_url.dart';
import 'package:flutter/material.dart';

import 'seller_products_view_model.dart';
import 'widgets/product_theme.dart';

class SellerProductDetailScreen extends StatefulWidget {
  final ProductViewData product;
  final VoidCallback? onAddProduct;
  final ValueChanged<ProductViewData>? onEditProduct;
  final ValueChanged<ProductViewData>? onDeleteProduct;

  const SellerProductDetailScreen({
    super.key,
    required this.product,
    this.onAddProduct,
    this.onEditProduct,
    this.onDeleteProduct,
  });

  @override
  State<SellerProductDetailScreen> createState() => _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: sellerBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProductImageCarousel(
              images: product.images,
              controller: _pageController,
              currentIndex: _currentImageIndex,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  _PrimaryInfoCard(product: product),
                  const SizedBox(height: 12),
                  _ManagementActions(
                    product: product,
                    onAddProduct: widget.onAddProduct,
                    onEditProduct: widget.onEditProduct,
                    onDeleteProduct: widget.onDeleteProduct,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImageCarousel extends StatelessWidget {
  final List<ProductImageViewData> images;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ProductImageCarousel({
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.05,
            child: Stack(
              children: [
                if (images.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                  )
                else
                  PageView.builder(
                    controller: controller,
                    onPageChanged: onPageChanged,
                    itemCount: images.length,
                    itemBuilder: (_, index) {
                      final url = images[index].url;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x15000000),
                              blurRadius: 16,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          resolveImageUrl(url)!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (images.length > 1)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == index ? sellerAccent : sellerAccentSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryInfoCard extends StatelessWidget {
  final ProductViewData product;

  const _PrimaryInfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusChip(status: product.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(product.price),
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Mo ta',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: sellerBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              (product.description?.isNotEmpty ?? false)
                  ? product.description!
                 : 'Sản phẩm chưa có mô tả. Thêm mô tả ngắn để khách dễ hiểu hơn.',
              style: theme.textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == ProductStatus.inactive ? Colors.grey : sellerAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ProductStatus.label(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ManagementActions extends StatelessWidget {
  final ProductViewData product;
  final VoidCallback? onAddProduct;
  final ValueChanged<ProductViewData>? onEditProduct;
  final ValueChanged<ProductViewData>? onDeleteProduct;

  const _ManagementActions({
    required this.product,
    this.onAddProduct,
    this.onEditProduct,
    this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tac vu quan ly',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onAddProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sellerAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Thêm sản phẩm mới'),
              ),
              OutlinedButton.icon(
                onPressed: onEditProduct == null ? null : () => onEditProduct!(product),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: const BorderSide(color: sellerAccent),
                ),
                icon: const Icon(Icons.edit_outlined, color: sellerAccent),
                label: const Text('Chỉnh sửa', style: TextStyle(color: sellerAccent)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: onDeleteProduct == null ? null : () => onDeleteProduct!(product),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text('Xóa sản phẩm', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
