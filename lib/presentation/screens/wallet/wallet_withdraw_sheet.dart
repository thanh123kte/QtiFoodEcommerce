import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showWithdrawSheet(
  BuildContext context, {
  required bool isProcessing,
}) async {
  final amountController = TextEditingController();
  final accountController = TextEditingController();
  final bankController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rút tiền',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền muốn rút (VND)',
                        hintText: 'Nhập số tiền',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        final amt = double.tryParse(raw);
                        if (amt == null || amt <= 0) return 'Vui lòng nhập số tiền hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: accountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản ngân hàng',
                        hintText: 'Vd: 01412.....',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return 'Vui lòng nhập số tài khoản';
                        if (!RegExp(r'^\d+$').hasMatch(raw)) {
                          return 'Số tài khoản chỉ được chứa chữ số';
                        }
                        if (raw.length < 8 || raw.length > 15) {
                          return 'Số tài khoản không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bankController,
                      decoration: const InputDecoration(
                        labelText: 'Tên ngân hàng',
                        hintText: 'Vd: MBBANK, VIETINBANK, AGRIBANK',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return 'Vui lòng chọn ngân hàng';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                final amt = double.parse(amountController.text.trim());
                                final account = accountController.text.trim();
                                final bank = bankController.text.trim();
                                Navigator.of(ctx).pop({
                                  'amount': amt,
                                  'bankAccount': account,
                                  'bankName': bank,
                                });
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Tiếp tục'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Huỷ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
