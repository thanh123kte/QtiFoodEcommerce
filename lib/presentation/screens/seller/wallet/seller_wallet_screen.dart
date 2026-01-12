import 'package:datn_foodecommerce_flutter_app/domain/entities/wallet_transaction.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../customer/wallet/customer_wallet_ui_state.dart';
import 'seller_wallet_view_model.dart';
import '../../wallet/wallet_payment_qr_screen.dart';
import '../../wallet/wallet_withdraw_sheet.dart';

class SellerWalletScreen extends StatefulWidget {
  const SellerWalletScreen({super.key});

  @override
  State<SellerWalletScreen> createState() => _SellerWalletScreenState();
}

class _SellerWalletScreenState extends State<SellerWalletScreen> {
  late final SellerWalletViewModel _viewModel = GetIt.I<SellerWalletViewModel>();
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
      child: Consumer<SellerWalletViewModel>(
        builder: (_, vm, __) {
          final uiState = vm.state;
          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _bg,
              elevation: 0,
              title: const Text('Ví của tôi', style: TextStyle(fontWeight: FontWeight.w700)),
              centerTitle: true,
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: vm.onLoadWallet,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _BalanceCard(state: uiState, onRetry: vm.onRetry),
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
                      onTransactionTap: (tx) => context.pushNamed('walletTransaction', extra: tx),
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

  Future<void> _openTopUpFlow(SellerWalletViewModel vm) async {
    final amount = await _showTopUpSheet(context, isProcessing: vm.state.isProcessing);
    if (amount != null) {
      await vm.onTopupClicked(amount);
      final paymentUrl = vm.state.paymentUrl;
      if (paymentUrl != null && mounted) {
        await _showPaymentQr(context, paymentUrl, amount: amount, onConfirmed: vm.onPaymentConfirmed);
      }
    }
  }

  Future<void> _openWithdrawFlow(SellerWalletViewModel vm, BuildContext context) async {
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
          BoxShadow(color: _primary.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8)),
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
                  child: Text(state.errorMessage ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                TextButton(onPressed: state.isLoading ? null : () => onRetry(), child: const Text('Thu lai', style: TextStyle(color: Colors.white))),
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
            onPressed: disabled ? null : onTopUp,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.outbond_outlined,
            label: 'Rút tiền',
            color: Colors.grey[800]!,
            onPressed: disabled ? null : onWithdraw,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: disabled ? null : () => onRefreshHistory(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700))],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CustomerWalletUiState state;
  final Future<void> Function() onRefresh;
  final void Function(WalletTransaction) onTransactionTap;

  const _HistoryCard({required this.state, required this.onRefresh, required this.onTransactionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Text('Lịch sử giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(onPressed: state.isProcessing ? null : () => onRefresh(), icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 8),
        if (state.isLoadingHistory) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (state.transactions.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Chưa có giao dịch'))
        else ...[
          for (final tx in state.transactions)
            InkWell(
              onTap: () => onTransactionTap(tx),
              child: _TransactionRow(tx: tx),
            ),
        ],
      ]),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(tx.transactionType);
    final icon = _statusIcon(tx.transactionType, tx.amount);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${tx.createdAt}', style: TextStyle(color: Colors.grey[600])),
        ])),
        Text(formatCurrency(tx.amount), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

Future<double?> _showTopUpSheet(BuildContext context, {required bool isProcessing}) async {
  final controller = TextEditingController();
  return showModalBottomSheet<double>(
    context: context,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nạp tiền vào ví', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền (VND)')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: isProcessing ? null : () => Navigator.of(ctx).pop(double.tryParse(controller.text)), child: const Text('Tiếp tục')),
          ],
        ),
      );
    },
  );
}

Future<void> _showPaymentQr(BuildContext context, String paymentUrl, {required double amount, required Future<void> Function() onConfirmed}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WalletPaymentQrScreen(
      paymentUrl: paymentUrl,
      amount: amount,
    ),
  );
  if (confirmed == true) {
    await onConfirmed();
  }
}

Color _statusColor(String type) {
  final upper = type.toUpperCase();
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Colors.green;
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return Colors.blue;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Colors.red;
  if (upper.contains('REFUND')) return Colors.teal;
  if (upper.contains('PAY')) return const Color(0xFFFF7A45);
  return Colors.blueGrey;
}

IconData _statusIcon(String type, double amount) {
  final upper = type.toUpperCase();
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Icons.arrow_downward_rounded;
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return Icons.trending_up_rounded;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Icons.call_made_rounded;
  if (upper.contains('REFUND')) return Icons.reply;
  if (upper.contains('PAY')) return Icons.shopping_bag_outlined;
  return amount >= 0 ? Icons.call_received : Icons.call_made;
}
