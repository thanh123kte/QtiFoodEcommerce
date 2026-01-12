import 'package:flutter/material.dart';

import '../../../../../../domain/entities/voucher.dart';
import '../../../seller/products/widgets/product_theme.dart';

class PlatformVoucherSection extends StatelessWidget {
  final Voucher? selectedVoucher;
  final int totalVouchers;
  final bool isLoading;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const PlatformVoucherSection({
    super.key,
    required this.selectedVoucher,
    required this.totalVouchers,
    required this.isLoading,
    required this.error,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: isLoading ? null : onTap,
        title: const Text('Voucher sàn'),
        subtitle: _buildSubtitle(),
        trailing: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSubtitle() {
    if (isLoading) return const Text('Đang tải...');
    if (error != null) {
      return Row(
        children: [
          Expanded(child: Text(error!, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      );
    }
    if (selectedVoucher != null) {
      return Text('Đang áp dụng: ${selectedVoucher!.code}', style: const TextStyle(color: sellerAccent));
    }
    if (totalVouchers == 0) {
      return const Text('Chưa có voucher khả dụng');
    }
    return Text('$totalVouchers voucher khả dụng');
  }
}
