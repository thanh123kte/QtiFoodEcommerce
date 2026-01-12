import 'package:flutter/material.dart';

import '../cart_view_model.dart';
import 'cart_empty_state.dart';
import 'cart_error_state.dart';
import 'cart_item_tile.dart';
import 'cart_select_all_tile.dart';

class CartBody extends StatelessWidget {
  final CartViewModel viewModel;

  const CartBody({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.items.isEmpty) {
      return CartErrorState(
        message: viewModel.error!,
        onRetry: viewModel.refresh,
      );
    }
    if (viewModel.items.isEmpty) {
      return const CartEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CartSelectAllTile(
              totalCount: viewModel.items.length,
              selectedCount: viewModel.selectedCount,
              onSelectAll: viewModel.selectAll,
            );
          }
          final item = viewModel.items[index - 1];
          return CartItemTile(
            item: item,
            selected: viewModel.isSelected(item.id),
            onToggleSelect: () => viewModel.toggleSelection(item.id),
            onRemove: () => viewModel.removeItem(item.id),
            onIncrease: () => viewModel.updateQuantity(item.id, item.quantity + 1),
            onDecrease: () => viewModel.updateQuantity(item.id, item.quantity - 1),
            isUpdating: viewModel.isUpdating(item.id),
            isRemoving: viewModel.isRemoving(item.id),
          );
        },
        itemCount: viewModel.items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
      ),
    );
  }
}
