import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/product_image_file.dart';
import '../../../../utils/result.dart';
import 'seller_product_detail_screen.dart';
import 'seller_products_view_model.dart';
import 'widgets/product_form_sheet.dart';
import 'widgets/product_list_view.dart';
import 'widgets/product_search_bar.dart';
import 'widgets/product_theme.dart';

class SellerProductsScreen extends StatefulWidget {
  final String ownerId;

  const SellerProductsScreen({super.key, required this.ownerId});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  late final SellerProductsViewModel _viewModel = GetIt.I<SellerProductsViewModel>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load(ownerId: widget.ownerId);
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearch)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSearch() {
    _viewModel.search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerProductsViewModel>.value(
      value: _viewModel,
      child: Consumer<SellerProductsViewModel>(
        builder: (_, vm, __) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: sellerBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF7A30), Color(0xFFFFA852)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Quản lý sản phẩm',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (vm.storeName != null)
                                Text(
                                  vm.storeName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(
                          icon: Icons.refresh,
                          onTap: vm.isLoading ? null : vm.refresh,
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(
                          icon: Icons.add,
                          onTap: vm.hasStore && !vm.isProcessing ? () => _openProductForm(vm) : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (vm.isProcessing) const LinearProgressIndicator(minHeight: 3, color: sellerAccent),
                  if (vm.hasStore)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: ProductSearchBar(
                        controller: _searchController,
                        onClear: () {
                          _searchController.clear();
                          _viewModel.search('');
                        },
                      ),
                    ),
                  if (vm.categoryError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _InlineInfoBanner(
                        message: vm.categoryError!,
                        icon: Icons.info_outline,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 12,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: _buildBody(vm),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SellerProductsViewModel vm) {
    if (!vm.hasStore) {
      if (vm.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _StoreMissingState(onRetry: () => vm.load(ownerId: widget.ownerId, force: true));
    }

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return _ErrorState(
        message: vm.error!,
        onRetry: () => vm.load(ownerId: widget.ownerId, force: true),
      );
    }

    return ProductListView(
      products: vm.products,
      onRefresh: vm.refresh,
      isProcessing: vm.isProcessing,
      onTap: _openProductDetail,
      onEdit: (product) => _openProductForm(vm, initial: product),
      onDelete: (product) => _confirmDelete(vm, product),
    );
  }

  void _openProductDetail(ProductViewData product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerProductDetailScreen(
          product: product,
          onAddProduct: () => _openProductForm(_viewModel),
          onEditProduct: (selected) => _openProductForm(_viewModel, initial: selected),
          onDeleteProduct: (selected) => _confirmDelete(_viewModel, selected),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SellerProductsViewModel vm, ProductViewData product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa san pham'),
        content: Text('Ban chac chan muon xoa "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    final result = await vm.deleteProduct(product.id);
    result.when(
      ok: (_) => _showMessage('Da xoa "${product.name}"'),
      err: (message) => _showMessage(message),
    );
  }

  Future<void> _openProductForm(
    SellerProductsViewModel vm, {
    ProductViewData? initial,
  }) async {
    final result = await ProductFormSheet.show(
      context,
      initial: initial,
      storeCategories: vm.storeCategoryOptions,
    );

    if (result == null) return;

    final ProductFormInput input = result.input;
    final List<ProductImageFile> images = result.images;

    Result<ProductViewData> response;
    if (initial == null) {
      response = await vm.addProduct(form: input, images: images);
    } else {
      response = await vm.updateProduct(
        productId: initial.id,
        form: input,
        newImages: images,
        replaceImages: result.replaceExistingImages,
      );
    }

    response.when(
      ok: (product) => _showMessage(initial == null ? 'Da them "${product.name}"' : 'Da cap nhat "${product.name}"'),
      err: (message) => _showMessage(message),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}



class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(onTap == null ? 0.4 : 1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

class _InlineInfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const _InlineInfoBanner({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: sellerAccentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: sellerAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMissingState extends StatelessWidget {
  final VoidCallback onRetry;

  const _StoreMissingState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 56, color: sellerAccent),
            const SizedBox(height: 12),
            const Text(
              'Ban chua co cua hang. Tao cua hang truoc khi quan ly san pham.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: onRetry,
              child: const Text('Tai lai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: onRetry,
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }
}
