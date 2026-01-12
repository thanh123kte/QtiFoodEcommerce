import 'package:flutter/material.dart';

import '../../products/widgets/product_theme.dart';

class VoucherEmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onCreate;
  final bool isProcessing;

  const VoucherEmptyState({
    super.key,
    required this.hasSearch,
    required this.onCreate,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.local_offer_outlined, size: 64, color: Colors.orange[200]),
        const SizedBox(height: 16),
        Text(
          hasSearch ? 'Không tìm thấy voucher phù hợp' : 'Chưa có voucher nào',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          hasSearch ? 'Thử điều chỉnh từ khóa tìm kiếm.' : 'Tạo voucher đầu tiên cho shop của bạn!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: sellerTextMuted),
        ),
        if (!hasSearch)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sellerAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tạo voucher mới'),
              ),
            ),
          ),
      ],
    );
  }
}
