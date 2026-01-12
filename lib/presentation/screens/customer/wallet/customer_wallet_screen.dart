import 'package:datn_foodecommerce_flutter_app/domain/entities/wallet_transaction.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:datn_foodecommerce_flutter_app/router/app_router.dart';

import 'customer_wallet_ui_state.dart';
import 'customer_wallet_view_model.dart';
import '../../wallet/wallet_payment_qr_screen.dart';
import '../../wallet/wallet_withdraw_sheet.dart';

class CustomerWalletScreen extends StatefulWidget {
  const CustomerWalletScreen({super.key});

  @override
  State<CustomerWalletScreen> createState() => _CustomerWalletScreenState();
}

class _CustomerWalletScreenState extends State<CustomerWalletScreen> {
  late final CustomerWalletViewModel _viewModel = GetIt.I<CustomerWalletViewModel>();
  static const Color _bg = Color(0xFFFFF8F2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.onLoadWallet());
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
      child: Consumer<CustomerWalletViewModel>(
        builder: (_, vm, __) {
          final uiState = vm.state;
          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _bg,
              elevation: 0,
              title: const Text('VÍ - QTI', style: TextStyle(fontWeight: FontWeight.w700)),
              centerTitle: true,
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: vm.onLoadWallet,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _BalanceCard(
                      state: uiState,
                      onRetry: vm.onRetry,
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      state: uiState,
                      onTopUp: () => _openTopUpFlow(vm),
                      onWithdraw: () => _openWithdrawFlow(vm, context),
                      onRefreshHistory: vm.onRefreshHistory,
                    ),
                    const SizedBox(height: 12),
                    _HistoryCard(
                      state: uiState,
                      onRefresh: vm.onRefreshHistory,
                      onTransactionTap: (tx) => context.pushNamed(AppRoute.walletTransaction.name, extra: tx),
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

  Future<void> _openTopUpFlow(CustomerWalletViewModel vm) async {
    final amount = await _showTopUpSheet(
      context,
      isProcessing: vm.state.isProcessing,
    );
    if (amount != null) {
      await vm.onTopupClicked(amount);
      final paymentUrl = vm.state.paymentUrl;
      if (paymentUrl != null && mounted) {
        await _showPaymentQr(
          context,
          paymentUrl,
          amount: amount,
          onConfirmed: vm.onPaymentConfirmed,
        );
      }
    }
  }

  Future<void> _openWithdrawFlow(CustomerWalletViewModel vm, BuildContext context) async {
    final withdrawData = await showWithdrawSheet(
      context,
      isProcessing: vm.state.isProcessing,
    );
    if (withdrawData != null) {
      final success = await vm.onWithdrawRequested(
        amount: withdrawData['amount'] as double,
        bankAccount: withdrawData['bankAccount'] as String,
        bankName: withdrawData['bankName'] as String,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yêu cầu rút tiền đã được gửi')),
        );
      } else if (!success && mounted && vm.state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.state.errorMessage ?? 'Lỗi khi rút tiền')),
        );
      }
    }
  }
}

class _BalanceCard extends StatelessWidget {
  final CustomerWalletUiState state;
  final Future<void> Function() onRetry;
  static const Color _primary = Color(0xFFFF7A45);

  const _BalanceCard({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withOpacity(0.9), _primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Số dư ví', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.3,
                    ),
                  ),
                ),
              Text(
                state.isLoading ? 'Dang tai...' : formatCurrency(state.balance),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (state.hasError) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.errorMessage ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: state.isLoading ? null : () => onRetry(),
                  child: const Text('Thu lai', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final CustomerWalletUiState state;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;
  final Future<void> Function() onRefreshHistory;
  static const Color _primary = Color(0xFFFF7A45);

  const _ActionRow({
    required this.state,
    required this.onTopUp,
    required this.onWithdraw,
    required this.onRefreshHistory,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = state.isProcessing;
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Nạp tiền',
            color: _primary,
            onTap: disabled ? null : () => onTopUp(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.south_west_rounded,
            label: 'Rút tiền',
            color: Colors.deepPurple,
            onTap: disabled ? null : () => onWithdraw(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Lịch sử',
            color: Colors.teal,
            onTap: () => onRefreshHistory(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CustomerWalletUiState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<WalletTransaction> onTransactionTap;
  static const Color _primary = Color(0xFFFF7A45);

  const _HistoryCard({
    required this.state,
    required this.onRefresh,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Lịch sử giao dịch', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                onPressed: () => onRefresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Chưa có giao dịch. Khi nạp/rút/thanh toán, lịch sử sẽ hiển thị tại đây.',
                style: TextStyle(color: Colors.black87),
              ),
            )
          else
            Column(
              children: state.transactions
                  .map(
                    (tx) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(tx.transactionType).withOpacity(0.12),
                        child: Icon(
                          _statusIcon(tx.transactionType, tx.amount),
                          color: _statusColor(tx.transactionType),
                        ),
                      ),
                        title: Text(_localizedType(tx.transactionType)),
                      subtitle: Text(
                        _shortDesc(tx.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _displayAmount(tx.amount, tx.transactionType),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: _statusColor(tx.transactionType),
                        ),
                      ),
                      onTap: () => onTransactionTap(tx),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

Future<double?> _showTopUpSheet(
  BuildContext context, {
  required bool isProcessing,
}) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<double>(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nhập số tiền muốn nạp',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VND)',
                      hintText: 'Nhập số tiền muốn nạp',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final raw = value?.trim() ?? '';
                      final amt = double.tryParse(raw);
                      if (amt == null || amt <= 0) return 'Vui long nhap so tien hop le';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                              if (!formKey.currentState!.validate()) return;
                              final amt = double.parse(controller.text.trim());
                              Navigator.of(ctx).pop(amt);
                            },
                      child: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Nạp tiền'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showPaymentQr(
  BuildContext context,
  String url, {
  required double amount,
  required Future<void> Function() onConfirmed,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WalletPaymentQrScreen(
      paymentUrl: url,
      amount: amount,
    ),
  );
  if (confirmed == true) {
    await onConfirmed();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nap tien thanh cong (cho doi doi soat neu can)')),
      );
    }
  }
}

String _localizedType(String type) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return 'Doanh thu';
  if (upper.contains('PAY')) return 'Thanh toán';
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return 'Nạp tiền';
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return 'Rút tiền';
  if (upper.contains('REFUND')) return 'Hoàn tiền';
  return 'Giao dịch';
}

String _shortDesc(String? desc) {
  if (desc == null || desc.isEmpty) return 'Khong co mo ta';
  return desc;
}

String _displayAmount(double amount, String type) {
  final outflow = _isOutflow(type, amount);
  final prefix = outflow ? '-' : '+';
  return '$prefix${formatCurrency(amount.abs())}';
}

bool _isOutflow(String type, double amount) {
  final upper = type.toUpperCase();
  if (upper.contains('PAY')) return true;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return true;
  if (amount < 0) return true;
  return false;
}

Color _statusColor(String type) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return Colors.blue;
  if (upper.contains('PAY')) return const Color(0xFFFF7A45);
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Colors.green;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Colors.red;
  if (upper.contains('REFUND')) return Colors.teal;
  return Colors.blueGrey;
}

IconData _statusIcon(String type, double amount) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return Icons.trending_up_rounded;
  if (upper.contains('PAY')) return Icons.shopping_bag_outlined;
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Icons.arrow_downward_rounded;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Icons.call_made_rounded;
  if (upper.contains('REFUND')) return Icons.reply;
  return amount >= 0 ? Icons.call_received : Icons.call_made;
}
