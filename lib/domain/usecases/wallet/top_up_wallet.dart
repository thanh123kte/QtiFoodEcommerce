import '../../../utils/result.dart';
import '../../entities/wallet_topup_result.dart';
import '../../repositories/wallet_repository.dart';

class TopUpWallet {
  final WalletRepository repository;

  TopUpWallet(this.repository);

  Future<Result<WalletTopUpResult>> call({
    required String userId,
    required double amount,
    required String currency,
    required String returnUrl,
  }) {
    return repository.topUp(
      userId: userId,
      amount: amount,
      currency: currency,
      returnUrl: returnUrl,
    );
  }
}
