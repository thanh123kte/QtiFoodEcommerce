import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/dashboard/customer_dashboard_view_model.dart'
    show DashboardProductTile;
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/dashboard/customer_product_detail_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/dashboard/widgets/dashboard_product_grid.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/dashboard/widgets/dashboard_states.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../seller/products/widgets/product_theme.dart';

import '../../../../domain/usecases/cart/add_product_to_cart.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import '../cart/cart_sync_notifier.dart';
import '../../../../domain/entities/store.dart';
import 'customer_store_detail_view_model.dart';
import 'customer_store_ui_state.dart';

class CustomerStoreDetailScreen extends StatefulWidget {
  final int storeId;
  final String? customerId;

  const CustomerStoreDetailScreen({
    super.key,
    required this.storeId,
    this.customerId,
  });

  @override
  State<CustomerStoreDetailScreen> createState() => _CustomerStoreDetailScreenState();
}

class _CustomerStoreDetailScreenState extends State<CustomerStoreDetailScreen> {
  late final CustomerStoreDetailViewModel _viewModel = GetIt.I<CustomerStoreDetailViewModel>();
  late final AddProductToCart _addProductToCart = GetIt.I<AddProductToCart>();
  late final GetProducts _getProducts = GetIt.I<GetProducts>();
  late final CartSyncNotifier _cartSyncNotifier = GetIt.I<CartSyncNotifier>();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _addingProductIds = {};

  Color _primary(BuildContext context) => Theme.of(context).colorScheme.primary;
  Color _bg(BuildContext context) => Theme.of(context).colorScheme.background;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.onLoadStore(storeId: widget.storeId, customerId: widget.customerId);
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
    _viewModel.onSearchQueryChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final baseScheme = baseTheme.colorScheme;
    final brandScheme = baseScheme.copyWith(
      primary: sellerAccent,
      onPrimary: Colors.white,
      secondary: sellerAccent,
      onSecondary: Colors.white,
      surface: Colors.white,
      background: sellerBackground,
      surfaceVariant: sellerAccentSoft,
      outline: sellerBorder,
      outlineVariant: sellerBorder.withOpacity(0.7),
    );

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: brandScheme,
        scaffoldBackgroundColor: brandScheme.background,
      ),
      child: ChangeNotifierProvider<CustomerStoreDetailViewModel>.value(
        value: _viewModel,
        child: Consumer<CustomerStoreDetailViewModel>(
          builder: (_, vm, __) {
            final uiState = vm.state;
            return Scaffold(
              backgroundColor: _bg(context),
              body: SafeArea(
                child: RefreshIndicator(
                  color: _primary(context),
                  onRefresh: () async {
                    _searchController.clear();
                    await vm.onRefresh();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _StoreSliverAppBar(
                        title: uiState.store?.name ?? 'Cửa hàng',
                        coverUrl: uiState.store?.imageUrl,
                        isFavorited: uiState.isFavorited,
                        isDisabled: uiState.isFavoriteProcessing || uiState.store == null,
                        onToggleFavorite: () => _toggleWishlist(context, vm),
                        onMessageTap: () => _openChat(uiState),
                      ),
                      SliverToBoxAdapter(
                        child: _StoreHero(
                          store: uiState.store,
                          address: uiState.store?.address,
                          reviews: uiState.reviews,
                        ),
                      ),
                      SliverToBoxAdapter(child: _StoreSearchBar(controller: _searchController)),
                      SliverToBoxAdapter(
                        child: _StoreCategoryStrip(
                          state: uiState,
                          onCategorySelected: (id) => _handleCategorySelection(context, vm, id),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sản phẩm',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              if (uiState.reviews.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatAverageRating(uiState.reviews),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('(${uiState.reviews.length})', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (uiState.productError != null && uiState.visibleProducts.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(uiState.productError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ),
                        ),
                      if (uiState.visibleProducts.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: DashboardEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: DashboardProductGrid(
                          products: uiState.visibleProducts,
                          onProductTap: _openProductDetail,
                          onQuickAdd: _handleQuickAdd,
                          addingProductIds: _addingProductIds,
                        ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Đánh giá cửa hàng',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final review = uiState.reviews[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: index == uiState.reviews.length - 1 ? 12 : 12),
                              child: _ReviewTile(review: review),
                            );
                          },
                          childCount: uiState.reviews.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleWishlist(BuildContext context, CustomerStoreDetailViewModel vm) async {
    if (widget.customerId == null || widget.customerId!.isEmpty) {
      _showSnack(context, 'Vui lòng đăng nhập');
      return;
    }
    final result = await vm.onToggleWishlist(widget.customerId!);
    result.when(
      ok: (_) => _showSnack(
        context,
        vm.state.isFavorited ? 'Đã thêm vào danh sách yêu thích' : 'Đã xóa khỏi danh sách yêu thích',
      ),
      err: (message) => _showSnack(context, message),
    );
  }

  Future<void> _handleCategorySelection(
    BuildContext context,
    CustomerStoreDetailViewModel vm,
    int? categoryId,
  ) async {
    final message = await vm.validateCategorySelection(categoryId);
    if (!mounted) return;
    if (message != null) {
      _showSnack(context, message);
      return;
    }
    vm.onCategorySelected(categoryId);
  }

  void _openProductDetail(DashboardProductTile product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerProductDetailScreen(
          product: product,
          customerId: widget.customerId,
        ),
      ),
    );
  }

  Future<void> _handleQuickAdd(DashboardProductTile product, Rect? _) async {
    final customerId = widget.customerId;
    if (customerId == null || customerId.isEmpty) {
      _showSnack(context, 'Vui long dang nhap de them san pham.');
      return;
    }
    if (_addingProductIds.contains(product.id)) return;
    setState(() => _addingProductIds.add(product.id));

    final isActive = await _ensureProductActive(product);
    if (!mounted) return;
    if (!isActive) {
      setState(() => _addingProductIds.remove(product.id));
      return;
    }

    final result = await _addProductToCart(
      customerId: customerId,
      productId: product.id,
      quantity: 1,
    );

    if (!mounted) return;

    result.when(
      ok: (_) {
        _cartSyncNotifier.markDirty(customerId);
        _showSnack(context, 'Đã thêm sản phẩm vào giỏ hàng.');
      },
      err: (message) => _showSnack(context, message),
    );

    if (mounted) {
      setState(() => _addingProductIds.remove(product.id));
    }
  }

  Future<bool> _ensureProductActive(DashboardProductTile product) async {
    final storeId = product.storeId;
    if (storeId <= 0) return true;
    final result = await _getProducts(storeId: storeId);
    if (!mounted) return false;

    bool exists = false;
    String? errorMessage;
    result.when(
      ok: (items) {
        for (final item in items) {
          if (item.id == product.id) {
            exists = item.isDeleted != true;
            break;
          }
        }
      },
      err: (message) {
        errorMessage = message;
      },
    );

    if (errorMessage != null) {
      _showSnack(context, errorMessage!);
      return false;
    }

    if (!exists) {
      _showSnack(context, 'San pham khong ton tai.');
      return false;
    }

    return true;
  }

  void _openChat(CustomerStoreUiState uiState) {
    final customerId = widget.customerId ?? '';
    if (customerId.isEmpty) {
      _showSnack(context, 'Vui long dang nhap');
      return;
    }
    final sellerId = uiState.store?.ownerId ?? '';
    if (sellerId.isEmpty) {
      _showSnack(context, 'Khong tim thay nguoi ban');
      return;
    }
    context.push(
      '/messenger/chat',
      extra: {
        'sellerId': sellerId,
        'storeName': uiState.store?.name,
        'avatar': uiState.store?.imageUrl,
      },
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatAverageRating(List<StoreReviewViewData> reviews) {
    if (reviews.isEmpty) return '';
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    final avg = total / reviews.length;
    return avg.toStringAsFixed(1);
  }
}
class _StoreSliverAppBar extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final bool isFavorited;
  final bool isDisabled;
  final VoidCallback onToggleFavorite;

  const _StoreSliverAppBar({
    required this.title,
    required this.coverUrl,
    required this.isFavorited,
    required this.isDisabled,
    required this.onToggleFavorite,
    required this.onMessageTap,
  });

  final VoidCallback onMessageTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: cs.surface,
      foregroundColor: cs.primary,
      expandedHeight: 160,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: isDisabled ? null : onMessageTap,
          icon: Icon(Icons.chat_bubble_outline, color: cs.primary),
        ),
        IconButton(
          onPressed: isDisabled ? null : onToggleFavorite,
          icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, color: cs.primary),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null && coverUrl!.isNotEmpty)
              Image.network(coverUrl!, fit: BoxFit.cover)
            else
              Container(color: cs.primary.withOpacity(0.12)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withOpacity(0.12),
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StoreHero extends StatelessWidget {
  final Store? store;
  final String? address;
  final List<StoreReviewViewData> reviews;

  const _StoreHero({required this.store, required this.address, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avg = _avgRating(reviews);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 64,
              color: cs.primary.withOpacity(0.08),
              child: (store?.imageUrl.isNotEmpty ?? false)
                  ? Image.network(store!.imageUrl, fit: BoxFit.cover)
                  : Icon(Icons.storefront, color: cs.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store?.name ?? 'Cửa hàng',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(address ?? store?.address ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.65))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(avg, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text('• ${reviews.length} đánh giá', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _avgRating(List<StoreReviewViewData> reviews) {
    if (reviews.isEmpty) return '0.0';
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return (total / reviews.length).toStringAsFixed(1);
  }
}

class _StoreSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _StoreSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          final hasText = value.text.trim().isNotEmpty;
          return TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: Icon(Icons.search, color: cs.primary),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clear(),
                    )
                  : null,
              filled: true,
              fillColor: cs.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: cs.primary, width: 1.4),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoreCategoryStrip extends StatelessWidget {
  final CustomerStoreUiState state;
  final Future<void> Function(int?) onCategorySelected;

  const _StoreCategoryStrip({required this.state, required this.onCategorySelected});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (state.categories.isEmpty) {
      if (state.categoryError != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(state.categoryError!, style: TextStyle(color: cs.error)),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final bool selected;
          final String label;
          final int? id;

          if (index == 0) {
            selected = state.selectedCategoryId == null;
            label = 'Tất cả';
            id = null;
          } else {
            final c = state.categories[index - 1];
            selected = state.selectedCategoryId == c.id;
            label = c.name;
            id = c.id;
          }

          return ChoiceChip(
            selected: selected,
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            onSelected: (_) async => onCategorySelected(id),
            selectedColor: sellerAccentSoft,
            backgroundColor: cs.surface,
            shape: StadiumBorder(side: BorderSide(color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.4))),
            labelStyle: TextStyle(color: selected ? cs.primary : cs.onSurface),
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final StoreReviewViewData review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final replyText = review.reply?.trim() ?? '';
    final hasReply = replyText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  backgroundImage: (review.avatarUrl?.isNotEmpty ?? false) ? NetworkImage(review.avatarUrl!) : null,
                  child: (review.avatarUrl?.isNotEmpty ?? false) ? null : Text(review.initials, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.author, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(review.dateLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(review.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
            if (review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final url = review.imageUrls[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, width: 96, height: 96, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ],
            if (hasReply) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Phan hoi tu cua hang',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                        ),
                        if (review.replyDateLabel != null && review.replyDateLabel!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${review.replyDateLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      replyText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
