import '../../../utils/result.dart';
import '../../entities/wallet_withdraw_request.dart';
import '../../repositories/wallet_repository.dart';

class WithdrawWallet {
  final WalletRepository repository;

  WithdrawWallet(this.repository);

  Future<Result<bool>> call({
    required String userId,
    required double amount,
    required String bankAccount,
    required String bankName,
  }) {
    final request = WalletWithdrawRequest(
      userId: userId,
      amount: amount,
      bankAccount: bankAccount,
      bankName: bankName,
    );
    return repository.withdraw(request);
  }
}
