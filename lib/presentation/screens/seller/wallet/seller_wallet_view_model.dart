import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../customer/wallet/customer_wallet_ui_state.dart';
import '../../../../domain/entities/wallet_transaction.dart';
import '../../../../domain/usecases/wallet/get_wallet_balance.dart';
import '../../../../domain/usecases/wallet/get_wallet_transactions.dart';
import '../../../../domain/usecases/wallet/top_up_wallet.dart';
import '../../../../domain/usecases/wallet/withdraw_wallet.dart';
import '../../../../utils/result.dart';

class SellerWalletViewModel extends ChangeNotifier {
  final GetWalletBalance _getWalletBalance;
  final GetWalletTransactions _getWalletTransactions;
  final TopUpWallet _topUpWallet;
  final WithdrawWallet _withdrawWallet;
  final FirebaseAuth _auth;

  CustomerWalletUiState _state = CustomerWalletUiState.initial();

  SellerWalletViewModel(
    this._getWalletBalance,
    this._getWalletTransactions,
    this._topUpWallet,
    this._withdrawWallet,
    this._auth,
  );

  CustomerWalletUiState get state => _state;

  Future<void> onLoadWallet() async {
    final uid = _requireUser();
    if (uid == null) return;

    _updateState((s) => s.copyWith(isLoadingHistory: true, errorMessage: null));
    await onRefreshHistory();

    final Result<double> result = await _getWalletBalance(uid);
    result.when(
      ok: (value) => _updateState(
        (s) => s.copyWith(balance: value, errorMessage: null),
      ),
      err: (message) => _updateState(
        (s) => s.copyWith(errorMessage: message),
      ),
    );

    _updateState((s) => s.copyWith(isLoadingHistory: false));
  }

  Future<void> onRefreshHistory() async {
    final uid = _requireUser();
    if (uid == null) return;

    _updateState((s) => s.copyWith(isLoadingHistory: true, errorMessage: null));
    final result = await _getWalletTransactions(uid);
    result.when(
      ok: (items) => _updateState(
        (s) => s.copyWith(
          transactions: List<WalletTransaction>.unmodifiable(items),
          errorMessage: null,
        ),
      ),
      err: (message) => _updateState(
        (s) => s.copyWith(errorMessage: message),
      ),
    );
    _updateState((s) => s.copyWith(isLoadingHistory: false));
  }

  Future<void> onTopupClicked(
    double amount, {
    String currency = 'VND',
    String? returnUrl,
  }) async {
    final uid = _requireUser();
    if (uid == null) return;
    final url = returnUrl ?? 'https://example.com/qti-wallet-return-seller';

    _updateState(
      (s) => s.copyWith(
        isProcessing: true,
        processingAction: WalletAction.topUp,
        paymentUrl: null,
        errorMessage: null,
      ),
    );

    final result = await _topUpWallet(
      userId: uid,
      amount: amount,
      currency: currency,
      returnUrl: url,
    );

    result.when(
      ok: (value) => _updateState(
        (s) => s.copyWith(paymentUrl: value.paymentUrl, errorMessage: null),
      ),
      err: (message) => _updateState(
        (s) => s.copyWith(errorMessage: message, paymentUrl: null),
      ),
    );

    _updateState(
      (s) => s.copyWith(isProcessing: false, processingAction: null),
    );
  }

  Future<void> onWithdrawClicked(double amount) async {
    final uid = _requireUser();
    if (uid == null) return;

    _updateState(
      (s) => s.copyWith(
        isProcessing: true,
        processingAction: WalletAction.withdraw,
        errorMessage: null,
      ),
    );

    // TODO: hook up withdraw API/use case when available.
    await Future.delayed(const Duration(milliseconds: 300));
    _updateState(
      (s) => s.copyWith(
        balance: (s.balance - amount).clamp(0, double.infinity),
      ),
    );

    _updateState(
      (s) => s.copyWith(isProcessing: false, processingAction: null),
    );
  }

  Future<bool> onWithdrawRequested({
    required double amount,
    required String bankAccount,
    required String bankName,
  }) async {
    final uid = _requireUser();
    if (uid == null) return false;

    _updateState(
      (s) => s.copyWith(
        isProcessing: true,
        processingAction: WalletAction.withdraw,
        errorMessage: null,
      ),
    );

    final result = await _withdrawWallet(
      userId: uid,
      amount: amount,
      bankAccount: bankAccount,
      bankName: bankName,
    );

    return result.when(
      ok: (_) async {
        _updateState(
          (s) => s.copyWith(
            isProcessing: false,
            processingAction: null,
          ),
        );
        await onLoadWallet();
        return true;
      },
      err: (message) {
        _updateState(
          (s) => s.copyWith(
            isProcessing: false,
            processingAction: null,
            errorMessage: message,
          ),
        );
        return false;
      },
    );
  }

  Future<void> onPaymentConfirmed() async {
    clearPaymentUrl();
    await onLoadWallet();
  }

  Future<void> onRetry() {
    return onLoadWallet();
  }

  void clearPaymentUrl() {
    _updateState((s) => s.copyWith(paymentUrl: null));
  }

  String? _requireUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _updateState(
        (s) => s.copyWith(errorMessage: 'Please sign in to use wallet'),
      );
    }
    return uid;
  }

  void _updateState(CustomerWalletUiState Function(CustomerWalletUiState) builder) {
    _state = builder(_state);
    notifyListeners();
  }
}