import '../../../utils/result.dart';
import '../../repositories/wallet_repository.dart';

class GetWalletBalance {
  final WalletRepository repository;

  GetWalletBalance(this.repository);

  Future<Result<double>> call(String userId) {
    return repository.getBalance(userId);
  }
}
