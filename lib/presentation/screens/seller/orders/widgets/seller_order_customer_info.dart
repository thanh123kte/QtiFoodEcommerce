import 'package:flutter/material.dart';

import '../seller_order_detail_view_model.dart';
import '../../products/widgets/product_theme.dart';

class SellerOrderCustomerInfo extends StatelessWidget {
  final SellerOrderDetailViewModel vm;

  const SellerOrderCustomerInfo({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingAddress) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Đang tải địa chỉ...'),
          ],
        ),
      );
    }

    if (vm.addressError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sellerAccentSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.addressError!, style: const TextStyle(color: sellerAccent)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: vm.loadAddress,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final address = vm.address;
    if (address == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: const Text('Không có địa chỉ giao hàng'),
      );
    }

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
          const Text('Thông tin người nhận', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _Row(icon: Icons.person, text: address.receiver),
          _Row(icon: Icons.phone, text: address.phone),
          _Row(icon: Icons.location_on, text: address.address, multiline: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool multiline;

  const _Row({required this.icon, required this.text, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: sellerAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
