import '../../../utils/result.dart';
import '../../entities/wallet_transaction.dart';
import '../../repositories/wallet_repository.dart';

class GetWalletTransactions {
  final WalletRepository repository;

  GetWalletTransactions(this.repository);

  Future<Result<List<WalletTransaction>>> call(String userId) {
    return repository.getTransactions(userId);
  }
}
