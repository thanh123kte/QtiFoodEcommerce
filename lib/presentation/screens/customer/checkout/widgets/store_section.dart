import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';
import '../../../seller/products/widgets/product_theme.dart';
import '../checkout_ui_state.dart';

class StoreSection extends StatelessWidget {
  final StoreGroupUiModel data;
  final double discountAmount;
  final double payableAmount;
  final VoidCallback onVoucherTap;
  final VoidCallback onReloadVouchers;
  final FocusNode? noteFocusNode;

  const StoreSection({
    super.key,
    required this.data,
    required this.discountAmount,
    required this.payableAmount,
    required this.onVoucherTap,
    required this.onReloadVouchers,
    this.noteFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sellerAccentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_mall_directory_outlined, color: sellerAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cửa hàng ${data.storeId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: data.vouchersLoading ? null : onVoucherTap,
                child: Text(
                  data.selectedVoucher == null ? 'Chọn voucher' : 'Voucher: ${data.selectedVoucher!.code}',
                  style: const TextStyle(color: sellerAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _VoucherInfo(
            data: data,
            onReload: onReloadVouchers,
          ),
          const SizedBox(height: 12),
          ...data.items.map((item) => _CheckoutItemTile(
                name: item.name,
                imageUrl: item.imageUrl,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice,
              )),
          const SizedBox(height: 12),
          _StoreCostSummary(
            subtotal: data.subtotal,
            discount: discountAmount,
            shipping: data.shippingFee,
            total: payableAmount + data.shippingFee,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: data.noteController,
            focusNode: noteFocusNode,
            decoration: InputDecoration(
              labelText: 'Lưu ý cho shop',
              hintText: 'Nhập lời nhắn cho shop',
              filled: true,
              fillColor: sellerBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _VoucherInfo extends StatelessWidget {
  final StoreGroupUiModel data;
  final VoidCallback onReload;

  const _VoucherInfo({required this.data, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    if (data.vouchersLoading) {
      return Text('Đang tải voucher...', style: textStyle);
    }
    if (data.voucherError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              data.voucherError!,
              style: textStyle?.copyWith(color: sellerAccent),
            ),
          ),
          TextButton(onPressed: onReload, child: const Text('Thử lại')),
        ],
      );
    }
    if (data.vouchers.isEmpty) {
      return Text('Cửa hàng chưa có voucher', style: textStyle);
    }
    return Text('${data.vouchers.length} voucher khả dụng', style: textStyle);
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const _CheckoutItemTile({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl == null
                ? Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported_outlined),
                  )
                : Image.network(
                    imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  '$quantity x ${formatCurrency(unitPrice)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
                ),
              ],
            ),
          ),
          Text(formatCurrency(totalPrice), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StoreCostSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final double shipping;

  const _StoreCostSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.shipping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sellerAccentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        children: [
          _CostRow(label: 'Tạm tính', value: formatCurrency(subtotal)),
          const SizedBox(height: 4),
          _CostRow(
            label: 'Giảm voucher',
            value: discount > 0 ? '-${formatCurrency(discount)}' : formatCurrency(0),
            valueStyle: TextStyle(color: discount > 0 ? Colors.green.shade700 : null, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          _CostRow(label: 'Phí ship', value: formatCurrency(shipping)),
          const Divider(height: 16),
          _CostRow(label: 'Thanh tiền', value: formatCurrency(total), valueStyle: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _CostRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: valueStyle),
      ],
    );
  }
}
