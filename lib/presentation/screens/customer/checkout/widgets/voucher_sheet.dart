import 'package:flutter/material.dart';

import '../../../../../domain/entities/voucher.dart';
import '../../../../../utils/currency_formatter.dart';

class VoucherOption {
  final Voucher voucher;
  final bool enabled;
  final String? message;

  const VoucherOption({
    required this.voucher,
    required this.enabled,
    this.message,
  });
}

class VoucherSheet extends StatelessWidget {
  final List<VoucherOption> options;
  final int? selectedId;

  const VoucherSheet({
    super.key,
    required this.options,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Chọn voucher'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final voucher = option.voucher;
                    return RadioListTile<int>(
                      value: voucher.id,
                      groupValue: selectedId,
                      onChanged: option.enabled ? (_) => Navigator.of(context).pop(voucher) : null,
                      title: Text('${voucher.code} - ${_discountLabel(voucher)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (voucher.title.isNotEmpty) Text(voucher.title),
                          if (voucher.minOrderValue != null)
                            Text('Đơn tối thiểu: ${formatCurrency(voucher.minOrderValue!)}'),
                          if (voucher.maxDiscount != null && voucher.discountType == VoucherDiscountType.percentage)
                            Text('Giảm tối đa: ${formatCurrency(voucher.maxDiscount!)}'),
                          if (voucher.endDate != null) Text('Hết hạn: ${_formatVoucherDate(voucher.endDate!)}'),
                          if (option.message != null)
                            Text(
                              option.message!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _discountLabel(Voucher voucher) {
  switch (voucher.discountType) {
    case VoucherDiscountType.percentage:
      return '${voucher.discountValue.toStringAsFixed(0)}%';
    case VoucherDiscountType.fixedAmount:
    case VoucherDiscountType.unknown:
      return formatCurrency(voucher.discountValue);
  }
}

String _formatVoucherDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
