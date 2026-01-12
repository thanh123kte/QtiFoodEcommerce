import '../../../../domain/entities/wallet_transaction.dart';

enum WalletAction { topUp, withdraw }
enum WalletStatus { idle, loading, success, error }

/// Immutable state for the customer wallet screen.
class CustomerWalletUiState {
  static const _noChange = Object();

  final double balance;
  final List<WalletTransaction> transactions;
  final WalletStatus status;
  final bool isLoadingHistory;
  final bool isProcessing;
  final WalletAction? processingAction;
  final String? paymentUrl;
  final String? errorMessage;

  const CustomerWalletUiState({
    required this.balance,
    required this.transactions,
    required this.status,
    required this.isLoadingHistory,
    required this.isProcessing,
    required this.processingAction,
    required this.paymentUrl,
    required this.errorMessage,
  });

  factory CustomerWalletUiState.initial() {
    return const CustomerWalletUiState(
      balance: 0,
      transactions: <WalletTransaction>[],
      status: WalletStatus.idle,
      isLoadingHistory: false,
      isProcessing: false,
      processingAction: null,
      paymentUrl: null,
      errorMessage: null,
    );
  }

  bool get isLoading => status == WalletStatus.loading;
  bool get hasError => status == WalletStatus.error && errorMessage != null && errorMessage!.isNotEmpty;

  CustomerWalletUiState copyWith({
    double? balance,
    List<WalletTransaction>? transactions,
    WalletStatus? status,
    bool? isLoadingHistory,
    bool? isProcessing,
    Object? processingAction = _noChange,
    Object? paymentUrl = _noChange,
    Object? errorMessage = _noChange,
  }) {
    return CustomerWalletUiState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isProcessing: isProcessing ?? this.isProcessing,
      processingAction:
          processingAction == _noChange ? this.processingAction : processingAction as WalletAction?,
      paymentUrl: paymentUrl == _noChange ? this.paymentUrl : paymentUrl as String?,
      errorMessage: errorMessage == _noChange ? this.errorMessage : errorMessage as String?,
    );
  }
}
