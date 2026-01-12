import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'cart_sync_notifier.dart';
import 'cart_view_model.dart';
import 'widgets/cart_body.dart';
import 'widgets/cart_summary_bar.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartViewModel _viewModel = GetIt.I<CartViewModel>();
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  late final CartSyncNotifier _cartSyncNotifier = GetIt.I<CartSyncNotifier>();
  static const Color _bgColor = Color(0xFFFFF8F2);

  String? _missingUserMessage;

  @override
  void initState() {
    super.initState();
    _cartSyncNotifier.addListener(_handleCartSync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart(initial: true));
  }

  Future<void> _loadCart({bool initial = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      setState(() => _missingUserMessage = 'Please sign in to view your cart.');
      return;
    }
    await _viewModel.load(
      user.uid,
      refresh: !initial,
      forceRemote: true,
    );
  }

  void _handleCartSync() {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;
    if (_cartSyncNotifier.takeIfDirty(userId)) {
      _viewModel.load(userId, refresh: true, forceRemote: true);
    }
  }

  @override
  void dispose() {
    _cartSyncNotifier.removeListener(_handleCartSync);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider<CartViewModel>.value(
      value: _viewModel,
      child: Consumer<CartViewModel>(
        builder: (_, vm, __) {
          return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              elevation: 0,
              title: const Text('Giỏ hàng', style: TextStyle(fontWeight: FontWeight.w700)),
              centerTitle: true,
              actions: [
                if (vm.items.isNotEmpty)
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: vm.isLoading ? null : vm.refresh,
                  ),
              ],
            ),
            body: SafeArea(
              child: _missingUserMessage != null
                  ? Center(child: Text(_missingUserMessage!, style: theme.textTheme.bodyLarge))
                  : CartBody(viewModel: vm),
            ),
            bottomNavigationBar: vm.items.isEmpty
                ? null
                : CartSummaryBar(
                    total: vm.selectedTotal,
                    selectedCount: vm.selectedCount,
                    hasSelection: vm.hasSelection,
                    onDelete: () => _handleRemoveSelected(vm),
                    onCheckout: () => _handleCheckout(vm),
                    isProcessing: vm.isRemovingItems,
                    isAllSelected: vm.selectedIds.length == vm.items.length && vm.items.isNotEmpty,
                    onSelectAll: vm.selectAll,
                  ),
          );
        },
      ),
    );
  }

  Future<void> _handleRemoveSelected(CartViewModel vm) async {
    if (!vm.hasSelection) return;
    await vm.removeSelectedItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected items have been removed.')),
      );
    }
  }

  Future<void> _handleCheckout(CartViewModel vm) async {
    if (!vm.hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items before checkout.')),
      );
      return;
    }
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not available for checkout.')),
      );
      return;
    }
    final selectedItems = vm.items.where((item) => vm.isSelected(item.id)).toList();
    final success = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          items: selectedItems,
          customerId: userId,
        ),
      ),
    );
    if (mounted && success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thành công')),
      );
    }
  }
}
