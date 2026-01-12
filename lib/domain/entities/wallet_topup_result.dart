class WalletTopUpResult {
  final String paymentUrl;
  final String? providerTransactionId;

  const WalletTopUpResult({
    required this.paymentUrl,
    this.providerTransactionId,
  });
}
