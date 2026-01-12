class WalletTransaction {
  final String id;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String referenceId;
  final String referenceType;
  final String? status;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.referenceId,
    required this.referenceType,
    this.status,
    this.createdAt,
  });
}
