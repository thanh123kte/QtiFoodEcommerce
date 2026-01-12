import 'package:flutter/material.dart';

import '../seller_order_detail_view_model.dart';
import '../../products/widgets/product_theme.dart';

class SellerOrderStatusAction extends StatelessWidget {
  final SellerOrderDetailViewModel vm;
  final VoidCallback? onStatusChanged;

  const SellerOrderStatusAction({
    super.key,
    required this.vm,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final next = vm.nextStatus;
    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trang thai don hang', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(vm.order?.status ?? 'Hoan tat'),
          ],
        ),
      );
    }

    final isAssignDriver = next == 'ASSIGN_DRIVER';
    final keyValue = 'status-${vm.order?.id}-${vm.order?.status}';
    final color = _statusColor(next);

    return Column(
      children: [
        if (vm.statusError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(vm.statusError!, style: const TextStyle(color: sellerAccent)),
          ),
        Dismissible(
          key: ValueKey(keyValue),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            if (isAssignDriver) {
              await vm.assignDriverNow();
            } else {
              await vm.advanceStatus();
            }
            if (vm.statusError == null) {
              onStatusChanged?.call();
            }
            return false;
          },
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: color.withOpacity(0.08),
            child: Row(
              children: [
                Icon(Icons.swipe, color: color),
                const SizedBox(width: 8),
                Text('Vuot sang trai de nhan don $next', style: TextStyle(color: color)),
              ],
            ),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Keo de cap nhat -> $next', style: TextStyle(color: color)),
                const SizedBox(width: 8),
                Icon(Icons.chevron_left, color: color),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sellerBorder),
            ),
            child: ListTile(
              title: Text(isAssignDriver ? 'Kéo sang trái để sẵn sàng giao hàng' : 'Keo tu phai sang trai de nhan don'),
              subtitle: Text(isAssignDriver ? 'Gán tài xế cho đơn' : 'Trang thai tiep theo: $next'),
              trailing: vm.isUpdatingStatus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.swipe_left, color: sellerAccent),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String next) {
    switch (next.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.blue;
      case 'PREPARING':
        return Colors.deepPurple;
      case 'PREPARED':
        return Colors.green;
      case 'ASSIGN_DRIVER':
        return Colors.teal;
      case 'PENDING':
        return Colors.orange;
      default:
        return sellerAccent;
    }
  }
}
