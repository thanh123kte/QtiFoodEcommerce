import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../common/cart_animation_registry.dart';
import '../cart/cart_sync_notifier.dart';
import '../../../../domain/usecases/cart/add_product_to_cart.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import 'customer_dashboard_view_model.dart';
import 'customer_product_detail_screen.dart';
import '../wallet/customer_wallet_screen.dart';
import 'dashboard_filter_screen.dart';
import 'dashboard_filter_view_model.dart';
import 'widgets/dashboard_banner_carousel.dart';
import 'widgets/dashboard_nearby_store_section.dart';
import 'widgets/dashboard_product_grid.dart';
import 'widgets/dashboard_product_section_header.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/dashboard_states.dart';
import 'widgets/wallet_shortcut_card.dart';
import '../search/customer_search_screen.dart';
import '../store/customer_store_detail_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});
  

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  late final CustomerDashboardViewModel _viewModel = GetIt.I<CustomerDashboardViewModel>();
  final ScrollController _scrollController = ScrollController();
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  late final AddProductToCart _addProductToCart = GetIt.I<AddProductToCart>();
  late final GetProducts _getProducts = GetIt.I<GetProducts>();
  late final CartSyncNotifier _cartSyncNotifier = GetIt.I<CartSyncNotifier>();
  final Set<String> _addingProductIds = {};
  static const Color _bgColor = Color(0xFFFFF8F2);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomerDashboardViewModel>.value(
      value: _viewModel,
      child: Consumer<CustomerDashboardViewModel>(
        builder: (_, vm, __) {
          return Scaffold(
            backgroundColor: _bgColor,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => vm.load(refresh: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: DashboardSearchBar(
                        onTap: () => _openSearch(context, vm),
                        onFilterTap: () => _openFilter(context, vm),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: WalletShortcutCard(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const CustomerWalletScreen())),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DashboardBannerCarousel(
                        banners: vm.banners,
                        isLoading: vm.isBannerLoading,
                        error: vm.bannerError,
                        onRetry: vm.refreshBanners,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DashboardNearbyStoreSection(
                        stores: vm.visibleNearbyStores,
                        isLoading: vm.isNearbyLoading,
                        error: vm.nearbyError,
                        showViewMore: vm.hasNearbyMore,
                        onRetry: vm.refreshNearbyStores,
                        onStoreTap: (store) => _openStoreDetail(
                          store.id,
                          _firebaseAuth.currentUser?.uid,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: DashboardProductSectionHeader()),
                    if (vm.isLoading && vm.products.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (vm.error != null && vm.products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: DashboardErrorState(
                          message: vm.error!,
                          onRetry: () => vm.load(refresh: true),
                        ),
                      )
                    else if (vm.visibleProducts.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: DashboardEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: DashboardProductGrid(
                          products: vm.visibleProducts,
                          onProductTap: (product) => _openProductDetail(product, _firebaseAuth.currentUser!.uid),
                          onQuickAdd: _handleQuickAdd,
                          addingProductIds: _addingProductIds,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: vm.isLoadingMore
                              ? const CircularProgressIndicator()
                              : vm.hasMore
                                  ? const SizedBox.shrink()
                                  : const Text(
                                      'Bạn đã xem hết sản phẩm.',
                                       style: TextStyle(color: Colors.grey),
                                    ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSearch(BuildContext context, CustomerDashboardViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerSearchScreen(initialQuery: vm.query),
      ),
    );
  }

  Future<void> _openFilter(BuildContext context, CustomerDashboardViewModel vm) async {
    final result = await Navigator.of(context).push<DashboardFilterResult>(
      MaterialPageRoute(
        builder: (_) => DashboardFilterScreen(
          categories: vm.categories,
          initialCategoryId: vm.selectedCategoryId,
          initialSort: vm.sortOption,
          minPrice: vm.minPriceFilter,
          maxPrice: vm.maxPriceFilter,
          priceBound: vm.maxProductPriceBound,
        ),
      ),
    );
    if (result == null) return;
    vm.applyFilterSelection(
      categoryId: result.categoryId,
      sortOption: result.sortOption,
      minPrice: result.minPrice,
      maxPrice: result.maxPrice,
    );
  }

  void _openProductDetail(DashboardProductTile product, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerProductDetailScreen(product: product, customerId: userId)),
    );
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
      _showSnack(errorMessage!);
      return false;
    }

    if (!exists) {
      _showSnack('San pham khong ton tai.');
      return false;
    }

    return true;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleQuickAdd(DashboardProductTile product, Rect? imageRect) async {
    final customerId = _firebaseAuth.currentUser?.uid;
    if (customerId == null || customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de them san pham.')),
      );
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

    _playAddToCartAnimation(product, imageRect);

    final result = await _addProductToCart(
      customerId: customerId,
      productId: product.id,
      quantity: 1,
    );

    if (!mounted) return;

    result.when(
      ok: (_) {
        _cartSyncNotifier.markDirty(customerId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da them san pham vao gio hang.')),
        );
      },
      err: (message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
    );

    if (mounted) {
      setState(() => _addingProductIds.remove(product.id));
    }
  }

  void _playAddToCartAnimation(DashboardProductTile product, Rect? imageRect) {
    if (imageRect == null) return;
    final targetRect = CartAnimationRegistry.getCartRect();
    if (targetRect == null) return;
    final overlay = Overlay.of(context);

    final imageUrl = product.imageUrl ?? (product.imageUrls.isNotEmpty ? product.imageUrls.first : null);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyToCartOverlay(
        startRect: imageRect,
        endRect: targetRect,
        imageUrl: imageUrl,
        onCompleted: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _openStoreDetail(int storeId, String? customerId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerStoreDetailScreen(
          storeId: storeId,
          customerId: customerId,
        ),
      ),
    );
  }
}

class _FlyToCartOverlay extends StatefulWidget {
  final Rect startRect;
  final Rect endRect;
  final String? imageUrl;
  final VoidCallback onCompleted;

  const _FlyToCartOverlay({
    required this.startRect,
    required this.endRect,
    required this.imageUrl,
    required this.onCompleted,
  });

  @override
  State<_FlyToCartOverlay> createState() => _FlyToCartOverlayState();
}

class _FlyToCartOverlayState extends State<_FlyToCartOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Rect?> _rectAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _rectAnimation = RectTween(begin: widget.startRect, end: widget.endRect).animate(curved);
    _fadeAnimation = Tween<double>(begin: 1, end: 0.2).animate(curved);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final rect = _rectAnimation.value ?? widget.endRect;
          return Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFFFF0E8),
                              child: const Icon(Icons.fastfood, color: Color(0xFFFF7A45)),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFFFF0E8),
                            child: const Icon(Icons.fastfood, color: Color(0xFFFF7A45)),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
