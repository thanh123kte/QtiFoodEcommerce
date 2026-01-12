import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/store/customer_store_detail_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/wishlist/widgets/favorite_store_card.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/wishlist/widgets/favorite_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../addresses/widgets/address_theme.dart';
import 'favorite_stores_view_model.dart';

class FavoriteStoresScreen extends StatefulWidget {
  const FavoriteStoresScreen({super.key});

  @override
  State<FavoriteStoresScreen> createState() => _FavoriteStoresScreenState();
}

class _FavoriteStoresScreenState extends State<FavoriteStoresScreen> {
  late final FavoriteStoresViewModel _viewModel = GetIt.I<FavoriteStoresViewModel>();
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        _viewModel.load(uid);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<FavoriteStoresViewModel>(
        builder: (_, vm, __) {
          final uid = _firebaseAuth.currentUser?.uid;

          return Scaffold(
            backgroundColor: AddressTheme.background,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                child: Column(
                  children: [
                    const Header(title: 'Cửa hàng yêu thích'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: FavoriteHeroCard(count: vm.stores.length),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AddressTheme.primary,
                        onRefresh: () => uid == null ? Future.value() : vm.refresh(uid),
                        child: _FavoriteBody(
                          vm: vm,
                          uid: uid,
                          onOpenStore: _openStore,
                          onRemove: (storeId) => _removeStore(vm, uid, storeId),
                          onExplore: _openStoreList,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeStore(FavoriteStoresViewModel vm, String? uid, int storeId) async {
    if (uid == null) return;
    final success = await vm.remove(uid, storeId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể bỏ khỏi danh sách yêu thích')),
      );
    }
  }

  void _openStore(int storeId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerStoreDetailScreen(storeId: storeId),
      ),
    );
  }

  void _openStoreList() {
    Navigator.of(context).pop();
  }
}

class _FavoriteBody extends StatelessWidget {
  final FavoriteStoresViewModel vm;
  final String? uid;
  final ValueChanged<int> onOpenStore;
  final ValueChanged<int> onRemove;
  final VoidCallback onExplore;

  const _FavoriteBody({
    required this.vm,
    required this.uid,
    required this.onOpenStore,
    required this.onRemove,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) return const FavoriteSkeletonList();

    if (vm.error != null) {
      return FavoriteErrorView(
        message: vm.error!,
        onRetry: () {
          if (uid != null) vm.refresh(uid!);
        },
      );
    }

    if (vm.stores.isEmpty) {
      return FavoriteEmptyView(onExplore: onExplore);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: vm.stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final store = vm.stores[index];
        final isRemoving = vm.removingStoreIds.contains(store.id);

        return FavoriteStoreCard(
          store: store,
          isRemoving: isRemoving,
          onTap: () => onOpenStore(store.id),
          onRemove: () => onRemove(store.id),
        );
      },
    );
  }
}
