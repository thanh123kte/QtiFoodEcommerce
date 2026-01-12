class WalletWithdrawRequest {
  final String userId;
  final double amount;
  final String bankAccount;
  final String bankName;

  WalletWithdrawRequest({
    required this.userId,
    required this.amount,
    required this.bankAccount,
    required this.bankName,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'bankAccount': bankAccount,
    'description': bankName,
  };
}
