import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/entities/store.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import '../../../../domain/usecases/store/get_store.dart';
import '../../../../domain/usecases/cart/add_product_to_cart.dart';
import '../../../../utils/currency_formatter.dart';
import '../cart/cart_sync_notifier.dart';
import '../store/customer_store_detail_screen.dart';
import 'customer_dashboard_view_model.dart';
import '../../seller/products/widgets/product_theme.dart';

class CustomerProductDetailScreen extends StatefulWidget {
  final DashboardProductTile product;
  final String? customerId;

  const CustomerProductDetailScreen({super.key, required this.product, this.customerId});

  @override
  State<CustomerProductDetailScreen> createState() => _CustomerProductDetailScreenState();
}

class _CustomerProductDetailScreenState extends State<CustomerProductDetailScreen> {
  late final PageController _pageController;
  late final GetStore _getStore = GetIt.I<GetStore>();
  late final GetProducts _getProducts = GetIt.I<GetProducts>();
  late final AddProductToCart _addProductToCart = GetIt.I<AddProductToCart>();
  late final CartSyncNotifier _cartSyncNotifier = GetIt.I<CartSyncNotifier>();

  late final ScrollController _scrollController;
  bool _collapsed = false;

  Store? _store;
  bool _isStoreLoading = false;
  String? _storeError;
  int _current = 0;
  int _quantity = 1;
  bool _isAddingToCart = false;
  String? _addToCartError;
  bool _isCheckingProduct = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController()
    ..addListener(() {
      final isCollapsedNow = _scrollController.hasClients && _scrollController.offset > 220;
      if (isCollapsedNow != _collapsed) {
        setState(() => _collapsed = isCollapsedNow);
      }
    });

    if (widget.product.storeId != 0) _fetchStore();
    _ensureProductActive(popOnDeleted: true);
  }

  Future<void> _fetchStore() async {
    setState(() {
      _isStoreLoading = true;
      _storeError = null;
    });
    final result = await _getStore(widget.product.storeId);
    result.when(
      ok: (store) {
        setState(() {
          _store = store;
          _isStoreLoading = false;
        });
      },
      err: (message) {
        setState(() {
          _storeError = message;
          _isStoreLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _ensureProductActive({bool popOnDeleted = false, bool allowOnError = true}) async {
    if (_isCheckingProduct) return false;
    final storeId = widget.product.storeId;
    if (storeId <= 0) return true;

    _isCheckingProduct = true;
    final result = await _getProducts(storeId: storeId);
    if (!mounted) return false;

    _isCheckingProduct = false;
    bool exists = false;
    String? errorMessage;
    result.when(
      ok: (items) {
        for (final item in items) {
          if (item.id == widget.product.id) {
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
      return allowOnError;
    }

    if (!exists) {
      _showSnack('San pham khong ton tai.');
      if (popOnDeleted && mounted) {
        Navigator.of(context).pop();
      }
      return false;
    }

    return true;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

    @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.imageUrls.isEmpty && product.imageUrl != null
        ? [product.imageUrl!]
        : product.imageUrls;
    return Scaffold(
      backgroundColor: sellerBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: _collapsed ? Colors.white : Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: _collapsed ? Colors.black87 : Colors.white,
            pinned: true,
            iconTheme: IconThemeData(color: _collapsed ? Colors.black87 : Colors.white),
            actionsIconTheme: IconThemeData(color: _collapsed ? Colors.black87 : Colors.white),
            expandedHeight: 340,
            elevation: 0,
            

            title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: sellerAccent),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ImageHero(
                controller: _pageController,
                images: images,
                current: _current,
                onPageChanged: (i) => setState(() => _current = i),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, -2))],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // chừa chỗ cho bottom bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderModern(product: product),
                    const SizedBox(height: 14),
                    _PriceModern(product: product),
                    const SizedBox(height: 18),

                    _SectionTitle('Mô tả'),
                    const SizedBox(height: 8),
                    Text(
                      product.description?.isNotEmpty == true ? product.description! : 'Không có mô tả.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted, height: 1.35),
                    ),

                    const SizedBox(height: 18),
                    _StoreInfoSection(
                      store: _store,
                      isLoading: _isStoreLoading,
                      error: _storeError,
                      onRetry: _fetchStore,
                      onViewStore: widget.product.storeId == 0
                          ? null
                          : () => _openStoreDetail(widget.product.storeId, widget.customerId),
                    ),

                    if (_addToCartError != null) ...[
                      const SizedBox(height: 12),
                      Text(_addToCartError!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ✅ bottom bar giống app thực tế
      bottomNavigationBar: _BottomAddToCartBar(
        priceText: formatCurrency(product.discountPrice ?? product.price),
        isLoading: _isAddingToCart,
        quantity: _quantity,
        onDecrease: _isAddingToCart || _quantity <= 1 ? null : _decrementQuantity,
        onIncrease: _isAddingToCart ? null : _incrementQuantity,
        onAdd: _isAddingToCart ? null : _handleAddToCart,
      ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += 1;
    });
  }

  void _decrementQuantity() {
    if (_quantity <= 1) return;
    setState(() {
      _quantity -= 1;
    });
  }

  Future<void> _handleAddToCart() async {
    final customerId = widget.customerId;
    if (customerId == null || customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thêm sản phẩm.')),
      );
      return;
    }
    if (_isAddingToCart) return;
    setState(() {
      _isAddingToCart = true;
      _addToCartError = null;
    });

    final isActive = await _ensureProductActive(popOnDeleted: true, allowOnError: false);
    if (!mounted) return;
    if (!isActive) {
      setState(() {
        _isAddingToCart = false;
      });
      return;
    }

    final result = await _addProductToCart(
      customerId: customerId,
      productId: widget.product.id,
      quantity: _quantity,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    String? errorMessage;
    result.when(
      ok: (_) {
        _cartSyncNotifier.markDirty(customerId);
        messenger.showSnackBar(const SnackBar(content: Text('Đã thêm sản phẩm vào giỏ hàng.')));
      },
      err: (message) {
        errorMessage = message;
      },
    );

    setState(() {
      _isAddingToCart = false;
      _addToCartError = errorMessage;
    });
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

class _ImageHero extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final int current;
  final ValueChanged<int> onPageChanged;

  const _ImageHero({
    required this.controller,
    required this.images,
    required this.current,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final headerH = topPad + kToolbarHeight + 8;

    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 72)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: images.length,
          itemBuilder: (_, i) => Image.network(
            images[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
          ),
        ),

        // ✅ Scrim TOP để header nổi lên
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // indicator (giữ nguyên)
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${current + 1}/${images.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeaderModern extends StatelessWidget {
  final DashboardProductTile product;
  const _HeaderModern({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Pill(
              icon: Icons.star_rounded,
              text: '${product.rating} • ${product.reviewCount} đánh giá',
            ),
            const SizedBox(width: 10),
            const _Pill(icon: Icons.local_fire_department_rounded, text: 'Bán chạy'),
          ],
        ),
      ],
    );
  }
}

class _PriceModern extends StatelessWidget {
  final DashboardProductTile product;
  const _PriceModern({required this.product});

  @override
  Widget build(BuildContext context) {
    final sale = product.discountPrice;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(238, 255, 235, 221),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sellerBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                formatCurrency(sale ?? product.price),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900, color: sellerAccent, fontSize: 24),
              ),
              if (sale != null) ...[
                const SizedBox(height: 4),
                Text(
                  formatCurrency(product.price),
                  style: const TextStyle(decoration: TextDecoration.lineThrough, color: sellerTextMuted),
                ),
              ],
            ]),
          ),
          const _Pill(icon: Icons.local_shipping_outlined, text: 'Giao nhanh'),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: sellerBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: sellerAccent),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _BottomAddToCartBar extends StatelessWidget {
  final String priceText;
  final bool isLoading;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onAdd;

  const _BottomAddToCartBar({
    required this.priceText,
    required this.isLoading,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giá', style: TextStyle(color: sellerTextMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(priceText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
            ),

            _QtyStepper(
              quantity: quantity,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
            ),

            const SizedBox(width: 12),

            SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sellerAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: onAdd,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text('Thêm', key: ValueKey('idle'), style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const _QtyStepper({
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sellerBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),
          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
          IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}



class _StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const _StoreCard({
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = onTap != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sellerBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar / icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: sellerAccent.withOpacity(0.10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: store.imageUrl.isNotEmpty
                      ? Image.network(
                          store.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.store_mall_directory_outlined,
                            color: sellerAccent,
                          ),
                        )
                      : const Icon(
                          Icons.store_mall_directory_outlined,
                          color: sellerAccent,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: sellerTextMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: sellerTextMuted,
                                  height: 1.25,
                                ),
                          ),
                        ),
                      ],
                    ),

                    if (store.phone.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _InfoChip(
                        icon: Icons.call_outlined,
                        text: store.phone,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Trailing
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: canTap ? 1 : 0.35,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(color: sellerBorder),
                  ),
                  child: const Icon(Icons.chevron_right, color: sellerTextMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: sellerBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: sellerAccent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}


class _StoreInfoSection extends StatelessWidget {
  final Store? store;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onViewStore;

  const _StoreInfoSection({
    required this.store,
    required this.isLoading,
    required this.error,
    this.onRetry,
    this.onViewStore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: sellerAccent),
        ),
      );
    }

    // Error
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cửa hàng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sellerAccentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.store_mall_directory_outlined, color: sellerAccent),
                const SizedBox(width: 12),
                Expanded(child: Text(error!, style: const TextStyle(color: sellerAccent))),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Thử lại'),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    final bool clickable = onViewStore != null;

    // Empty
    if (store == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cửa hàng',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          _StoreCard(
            store: store!,
            onTap: clickable ? onViewStore : null,
          ),
        ],
      );
    }
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cửa hàng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: clickable ? onViewStore : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: store!.imageUrl.isEmpty ? null : NetworkImage(store!.imageUrl),
                    backgroundColor: Colors.grey.shade200,
                    child: store!.imageUrl.isEmpty
                        ? const Icon(Icons.store_mall_directory_outlined, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store!.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store!.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: sellerTextMuted),
                        ),
                        if (store!.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Điện thoại: ${store!.phone}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // icon gợi ý có thể bấm
                  if (clickable) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: sellerTextMuted),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
